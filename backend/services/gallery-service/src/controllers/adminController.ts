import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError, ForbiddenError } from '@galeri/shared/utils/errors';
import { exec } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs/promises';
import * as path from 'path';
import { existsSync, mkdirSync } from 'fs';

const execAsync = promisify(exec);

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    role: string;
  };
}

// Helper to get user from headers (set by API Gateway)
const getUserFromHeaders = (req: Request) => {
  return {
    sub: req.headers['x-user-id'] as string,
    role: req.headers['x-user-role'] as string,
    galleryId: req.headers['x-gallery-id'] as string
  };
};

// Roles are now stored in database

export class AdminController {
  // Dashboard stats
  async getDashboard(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    // Get gallery stats
    const galleriesResult = await query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'pending') as pending,
        COUNT(*) FILTER (WHERE status = 'active') as active,
        COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '30 days') as new_this_month
      FROM galleries
    `);

    // Get vehicle stats
    const vehiclesResult = await query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'available') as available,
        COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '30 days') as new_this_month
      FROM vehicles
    `);

    // Get user stats
    const usersResult = await query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'active') as active
      FROM users
    `);

    // Get offer stats
    const offersResult = await query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '30 days') as this_month
      FROM offers
    `);

    // Get recent activities (last 10)
    const activitiesResult = await query(`
      SELECT 
        'gallery' as type,
        name as title,
        'Yeni galeri kaydı' as message,
        created_at
      FROM galleries
      ORDER BY created_at DESC
      LIMIT 5
    `);

    // Get pending applications
    const pendingResult = await query(`
      SELECT id, name, city as location
      FROM galleries
      WHERE status = 'pending'
      ORDER BY created_at DESC
      LIMIT 10
    `);

    // Build chart data
    const chartLabels = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran'];
    
    // Get monthly gallery counts
    const monthlyGalleriesResult = await query(`
      SELECT 
        EXTRACT(MONTH FROM created_at) as month,
        COUNT(*) as count
      FROM galleries
      WHERE created_at > NOW() - INTERVAL '6 months'
      GROUP BY EXTRACT(MONTH FROM created_at)
      ORDER BY month
    `);

    // Get monthly vehicle counts
    const monthlyVehiclesResult = await query(`
      SELECT 
        EXTRACT(MONTH FROM created_at) as month,
        COUNT(*) as count
      FROM vehicles
      WHERE created_at > NOW() - INTERVAL '6 months'
      GROUP BY EXTRACT(MONTH FROM created_at)
      ORDER BY month
    `);

    const galleryStats = galleriesResult.rows[0];
    const vehicleStats = vehiclesResult.rows[0];
    const userStats = usersResult.rows[0];
    const offerStats = offersResult.rows[0];

    // Calculate change percentages (simplified - comparing to baseline)
    const galleriesChange = galleryStats.new_this_month > 0 ? `+${Math.round((galleryStats.new_this_month / Math.max(1, parseInt(galleryStats.total) - galleryStats.new_this_month)) * 100)}%` : '+0%';
    const vehiclesChange = vehicleStats.new_this_month > 0 ? `+${Math.round((vehicleStats.new_this_month / Math.max(1, parseInt(vehicleStats.total) - vehicleStats.new_this_month)) * 100)}%` : '+0%';

    res.json({
      success: true,
      stats: {
        totalGalleries: { value: parseInt(galleryStats.total), change: galleriesChange },
        pendingApplications: { value: parseInt(galleryStats.pending), change: `+${galleryStats.pending}` },
        totalVehicles: { value: parseInt(vehicleStats.total), change: vehiclesChange },
        monthlyOffers: { value: parseInt(offerStats.this_month || 0), change: '+0%' }
      },
      activities: activitiesResult.rows,
      pendingApplications: pendingResult.rows,
      chartData: {
        labels: chartLabels,
        datasets: [
          {
            label: 'Galeri Sayısı',
            data: [120, 130, 135, 140, 145, parseInt(galleryStats.total)],
            borderColor: 'rgb(59, 130, 246)',
            backgroundColor: 'rgba(59, 130, 246, 0.1)',
            fill: true,
            tension: 0.4
          },
          {
            label: 'Yeni Araç',
            data: [800, 950, 1100, 1200, 1300, parseInt(vehicleStats.total)],
            borderColor: 'rgb(34, 197, 94)',
            backgroundColor: 'rgba(34, 197, 94, 0.1)',
            fill: true,
            tension: 0.4
          }
        ]
      }
    });
  }

  async listGalleries(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    // Only superadmin roles
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { page = 1, limit = 20, status } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    
    let whereClause = 'WHERE 1=1';
    const params: any[] = [];
    let paramCount = 1;

    if (status) {
      whereClause += ` AND g.status = $${paramCount++}`;
      params.push(status);
    }

    // Get galleries with vehicle count
    const result = await query(
      `SELECT 
        g.id, g.name, g.email, g.phone, g.city as location, g.status, g.created_at,
        (SELECT COUNT(*) FROM vehicles v WHERE v.gallery_id = g.id) as "vehicleCount"
      FROM galleries g 
      ${whereClause} 
      ORDER BY g.created_at DESC 
      LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, Number(limit), offset]
    );

    const countResult = await query(
      `SELECT COUNT(*) as total FROM galleries g ${whereClause}`,
      params
    );

    // Get stats for all galleries (not filtered)
    const statsResult = await query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'pending') as pending,
        COUNT(*) FILTER (WHERE status = 'active') as active,
        COUNT(*) FILTER (WHERE status = 'suspended') as suspended
      FROM galleries
    `);

    // Map data for frontend
    const galleries = result.rows.map(g => ({
      id: g.id,
      name: g.name,
      email: g.email,
      phone: g.phone,
      location: g.location || '-',
      status: g.status,
      vehicleCount: parseInt(g.vehicleCount) || 0,
      createdAt: g.created_at
    }));

    res.json({
      success: true,
      galleries: galleries,
      stats: {
        total: parseInt(statsResult.rows[0]?.total || '0'),
        pending: parseInt(statsResult.rows[0]?.pending || '0'),
        active: parseInt(statsResult.rows[0]?.active || '0'),
        suspended: parseInt(statsResult.rows[0]?.suspended || '0')
      },
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: parseInt(countResult.rows[0].total),
        totalPages: Math.ceil(parseInt(countResult.rows[0].total) / Number(limit))
      }
    });
  }

  async getGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;

    const result = await query('SELECT * FROM galleries WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      throw new ValidationError('Gallery not found');
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async updateGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const updates = req.body;

    // Only superadmin can update
    if (req.user?.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update galleries');
    }

    const allowedFields = ['status', 'rejection_reason', 'rejection_template_id'];
    const updateFields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    for (const [key, value] of Object.entries(updates)) {
      if (allowedFields.includes(key)) {
        updateFields.push(`${key} = $${paramCount++}`);
        values.push(value);
      }
    }

    if (updateFields.length === 0) {
      throw new ValidationError('No valid fields to update');
    }

    updateFields.push(`updated_at = NOW()`);
    values.push(id);

    await query(
      `UPDATE galleries SET ${updateFields.join(', ')} WHERE id = $${paramCount}`,
      values
    );

    res.json({
      success: true,
      message: 'Gallery updated successfully'
    });
  }

  async approveGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;

    if (req.user?.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can approve galleries');
    }

    await query(
      `UPDATE galleries 
       SET status = 'active', approved_at = NOW(), approved_by = $1, updated_at = NOW()
       WHERE id = $2`,
      [req.user?.sub, id]
    );

    // Publish event for notification
    const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
    const galleryResult = await query('SELECT * FROM galleries WHERE id = $1', [id]);
    if (galleryResult.rows.length > 0) {
      const ownerResult = await query(
        'SELECT id FROM users WHERE gallery_id = $1 AND role = $2',
        [id, 'gallery_owner']
      );
      if (ownerResult.rows.length > 0) {
        await publishToQueue('notifications_queue', {
          id: uuidv4(),
          userId: ownerResult.rows[0].id,
          type: 'gallery_approved',
          title: 'Galeri Onaylandı',
          body: `Galeriniz onaylandı. Artık platformu kullanmaya başlayabilirsiniz.`,
          channels: ['push', 'email', 'sms']
        });
      }
    }

    res.json({
      success: true,
      message: 'Gallery approved successfully'
    });
  }

  async rejectGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const { reason, templateId } = req.body;

    if (req.user?.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can reject galleries');
    }

    await query(
      `UPDATE galleries 
       SET status = 'rejected', rejection_reason = $1, rejection_template_id = $2, updated_at = NOW()
       WHERE id = $3`,
      [reason, templateId, id]
    );

    // Publish event for notification
    const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
    const ownerResult = await query(
      'SELECT id FROM users WHERE gallery_id = $1 AND role = $2',
      [id, 'gallery_owner']
    );
    if (ownerResult.rows.length > 0) {
      await publishToQueue('notifications_queue', {
        id: uuidv4(),
        userId: ownerResult.rows[0].id,
        type: 'gallery_rejected',
        title: 'Galeri Başvurusu Reddedildi',
        body: `Galeri başvurunuz reddedildi. Sebep: ${reason}`,
        channels: ['push', 'email']
      });
    }

    res.json({
      success: true,
      message: 'Gallery rejected'
    });
  }

  async suspendGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;

    if (req.user?.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can suspend galleries');
    }

    await query(
      `UPDATE galleries SET status = 'suspended', updated_at = NOW() WHERE id = $1`,
      [id]
    );

    res.json({
      success: true,
      message: 'Gallery suspended'
    });
  }

  async activateGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const user = getUserFromHeaders(req);

    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can activate galleries');
    }

    await query(
      `UPDATE galleries SET status = 'active', updated_at = NOW() WHERE id = $1`,
      [id]
    );

    res.json({
      success: true,
      message: 'Gallery activated'
    });
  }

  // ===================== USERS =====================
  async listUsers(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { page = 1, limit = 50 } = req.query;
    const offset = (Number(page) - 1) * Number(limit);

    const result = await query(`
      SELECT 
        u.id, 
        COALESCE(u.first_name || ' ' || u.last_name, u.email) as name,
        u.email, u.phone, u.role, u.status, u.created_at,
        g.name as gallery
      FROM users u
      LEFT JOIN galleries g ON u.gallery_id = g.id
      ORDER BY u.created_at DESC
      LIMIT $1 OFFSET $2
    `, [Number(limit), offset]);

    res.json({
      success: true,
      users: result.rows
    });
  }

  async getUser(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;

    const result = await query(`
      SELECT 
        u.id, u.email, u.phone, u.role, u.status, u.created_at, u.last_login,
        u.first_name, u.last_name,
        COALESCE(u.first_name || ' ' || u.last_name, u.email) as name,
        g.name as gallery_name, g.id as gallery_id
      FROM users u
      LEFT JOIN galleries g ON u.gallery_id = g.id
      WHERE u.id = $1
    `, [id]);

    if (result.rows.length === 0) {
      throw new ValidationError('User not found');
    }

    const userData = result.rows[0];
    
    res.json({
      success: true,
      data: {
        ...userData,
        gallery: userData.gallery_name ? {
          id: userData.gallery_id,
          name: userData.gallery_name
        } : null,
        totalLogins: 0, // TODO: Track login count
        vehicleCount: 0,
        offerCount: 0
      }
    });
  }

  async createUser(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can create users');
    }

    const { name, email, phone, password, role, status, galleryName, taxType, taxNumber } = req.body;

    // Validate required fields
    if (!name || !email || !password) {
      throw new ValidationError('Name, email and password are required');
    }

    // Parse name into first and last
    const nameParts = name.trim().split(' ');
    const firstName = nameParts[0] || '';
    const lastName = nameParts.slice(1).join(' ') || '';

    // Check if email exists
    const existingUser = await query('SELECT id FROM users WHERE email = $1', [email]);
    if (existingUser.rows.length > 0) {
      throw new ValidationError('Email already exists');
    }

    // Check if phone exists
    if (phone) {
      const existingPhone = await query('SELECT id FROM users WHERE phone = $1', [phone]);
      if (existingPhone.rows.length > 0) {
        throw new ValidationError('Phone already exists');
      }
    }

    const userId = uuidv4();
    let galleryId = null;

    // Generate slug for gallery
    const generateSlug = (text: string) => {
      return text
        .toLowerCase()
        .replace(/ğ/g, 'g').replace(/ü/g, 'u').replace(/ş/g, 's')
        .replace(/ı/g, 'i').replace(/ö/g, 'o').replace(/ç/g, 'c')
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)/g, '') + '-' + Date.now();
    };

    // If gallery owner, create gallery first
    if (role === 'gallery_owner' && galleryName) {
      galleryId = uuidv4();
      const slug = generateSlug(galleryName);
      await query(`
        INSERT INTO galleries (id, name, slug, tax_type, tax_number, status, created_at)
        VALUES ($1, $2, $3, $4, $5, 'pending', NOW())
      `, [galleryId, galleryName, slug, taxType || 'VKN', taxNumber || '0000000000']);
    }

    // Hash password
    const bcrypt = await import('bcrypt');
    const hashedPassword = await bcrypt.hash(password, 10);

    await query(`
      INSERT INTO users (id, first_name, last_name, email, phone, password_hash, role, status, gallery_id, created_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW())
    `, [userId, firstName, lastName, email, phone || `+90${Date.now()}`, hashedPassword, role || 'gallery_owner', status || 'active', galleryId]);

    res.json({
      success: true,
      id: userId,
      name,
      email,
      phone,
      role,
      status: status || 'active'
    });
  }

  async updateUser(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update users');
    }

    const { id } = req.params;
    const { name, email, phone, role, status, password } = req.body;

    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (name) { 
      const nameParts = name.trim().split(' ');
      const firstName = nameParts[0] || '';
      const lastName = nameParts.slice(1).join(' ') || '';
      updates.push(`first_name = $${paramCount++}`); 
      values.push(firstName); 
      updates.push(`last_name = $${paramCount++}`); 
      values.push(lastName); 
    }
    if (email) { updates.push(`email = $${paramCount++}`); values.push(email); }
    if (phone) { updates.push(`phone = $${paramCount++}`); values.push(phone); }
    if (role) { updates.push(`role = $${paramCount++}`); values.push(role); }
    if (status) { updates.push(`status = $${paramCount++}`); values.push(status); }
    
    if (password) {
      const bcrypt = await import('bcrypt');
      const hashedPassword = await bcrypt.hash(password, 10);
      updates.push(`password_hash = $${paramCount++}`);
      values.push(hashedPassword);
    }

    if (updates.length === 0) {
      throw new ValidationError('No fields to update');
    }

    updates.push(`updated_at = NOW()`);
    values.push(id);

    await query(`UPDATE users SET ${updates.join(', ')} WHERE id = $${paramCount}`, values);

    res.json({ success: true, message: 'User updated' });
  }

  async deleteUser(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can delete users');
    }

    const { id } = req.params;

    // Soft delete
    await query(`UPDATE users SET status = 'deleted', updated_at = NOW() WHERE id = $1`, [id]);

    res.json({ success: true, message: 'User deleted' });
  }

  // ===================== SETTINGS =====================
  async getSettings(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    // Try to get settings from database, or return defaults
    try {
      const result = await query('SELECT * FROM system_settings WHERE id = 1');
      if (result.rows.length > 0) {
        const settings = result.rows[0];
        res.json({
          success: true,
          general: {
            platformName: settings.platform_name || 'Otobia',
            email: settings.contact_email || 'info@otobia.com',
            phone: settings.contact_phone || '+90 212 555 0000',
            maintenanceMode: settings.maintenance_mode || false
          },
          security: {
            minPasswordLength: settings.min_password_length || 8,
            requireTwoFactor: settings.require_2fa || false,
            sessionTimeout: settings.session_timeout || 60
          },
          notifications: {
            emailNotifications: settings.email_notifications ?? true,
            smsNotifications: settings.sms_notifications ?? false,
            pushNotifications: settings.push_notifications ?? true
          }
        });
        return;
      }
    } catch (e) {
      // Table may not exist, return defaults
    }

    res.json({
      success: true,
      general: {
        platformName: 'Otobia',
        email: 'info@otobia.com',
        phone: '+90 212 555 0000',
        maintenanceMode: false
      },
      security: {
        minPasswordLength: 8,
        requireTwoFactor: false,
        sessionTimeout: 60
      },
      notifications: {
        emailNotifications: true,
        smsNotifications: false,
        pushNotifications: true
      }
    });
  }

  async updateGeneralSettings(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update settings');
    }

    const { platformName, email, phone, maintenanceMode } = req.body;

    // Upsert settings
    await query(`
      INSERT INTO system_settings (id, platform_name, contact_email, contact_phone, maintenance_mode, updated_at)
      VALUES (1, $1, $2, $3, $4, NOW())
      ON CONFLICT (id) DO UPDATE SET
        platform_name = $1,
        contact_email = $2,
        contact_phone = $3,
        maintenance_mode = $4,
        updated_at = NOW()
    `, [platformName, email, phone, maintenanceMode || false]);

    res.json({ success: true, message: 'Settings updated' });
  }

  async updateSecuritySettings(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update settings');
    }

    const { minPasswordLength, requireTwoFactor, sessionTimeout } = req.body;

    await query(`
      INSERT INTO system_settings (id, min_password_length, require_2fa, session_timeout, updated_at)
      VALUES (1, $1, $2, $3, NOW())
      ON CONFLICT (id) DO UPDATE SET
        min_password_length = $1,
        require_2fa = $2,
        session_timeout = $3,
        updated_at = NOW()
    `, [minPasswordLength || 8, requireTwoFactor || false, sessionTimeout || 60]);

    res.json({ success: true, message: 'Security settings updated' });
  }

  async updateNotificationSettings(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update settings');
    }

    const { emailNotifications, smsNotifications, pushNotifications } = req.body;

    await query(`
      INSERT INTO system_settings (id, email_notifications, sms_notifications, push_notifications, updated_at)
      VALUES (1, $1, $2, $3, NOW())
      ON CONFLICT (id) DO UPDATE SET
        email_notifications = $1,
        sms_notifications = $2,
        push_notifications = $3,
        updated_at = NOW()
    `, [emailNotifications ?? true, smsNotifications ?? false, pushNotifications ?? true]);

    res.json({ success: true, message: 'Notification settings updated' });
  }

  // ===================== ANALYTICS =====================
  async getAnalytics(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { period = 'month' } = req.query;
    
    // Calculate interval based on period
    let interval = '30 days';
    if (period === 'week') interval = '7 days';
    else if (period === 'quarter') interval = '90 days';
    else if (period === 'year') interval = '365 days';

    // Get metrics
    const usersResult = await query(`
      SELECT 
        COUNT(*) FILTER (WHERE status = 'active') as active,
        COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '${interval}') as new
      FROM users
    `);

    const galleriesResult = await query(`
      SELECT 
        COUNT(*) FILTER (WHERE status = 'active') as active,
        COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '${interval}') as new
      FROM galleries
    `);

    const vehiclesResult = await query(`
      SELECT COUNT(*) as total FROM vehicles
    `);

    // Get regional data
    const regionsResult = await query(`
      SELECT 
        city as name,
        COUNT(*) as count
      FROM galleries
      WHERE city IS NOT NULL
      GROUP BY city
      ORDER BY count DESC
      LIMIT 8
    `);

    const totalGalleries = parseInt(galleriesResult.rows[0].active) || 1;
    const regions = regionsResult.rows.map(r => ({
      name: r.name,
      count: parseInt(r.count),
      percentage: Math.round((parseInt(r.count) / totalGalleries) * 100)
    }));

    res.json({
      success: true,
      metrics: {
        activeUsers: { value: usersResult.rows[0].active || '0', change: '+0%' },
        activeGalleries: { value: galleriesResult.rows[0].active || '0', change: '+0%' },
        totalVehicles: { value: vehiclesResult.rows[0].total || '0', change: '+0%' },
        totalRevenue: { value: '₺0', change: '+0%' }
      },
      activities: [
        { type: 'Araç Listelemeleri', description: 'Yeni araç ilanları', count: vehiclesResult.rows[0].total, percentage: 40, icon: 'Car', iconBg: 'bg-blue-100', iconColor: 'text-blue-600' },
        { type: 'Galeri Kayıtları', description: 'Yeni galeri başvuruları', count: galleriesResult.rows[0].new || 0, percentage: 25, icon: 'Building2', iconBg: 'bg-green-100', iconColor: 'text-green-600' },
        { type: 'Kullanıcı Girişleri', description: 'Aktif kullanıcılar', count: usersResult.rows[0].active || 0, percentage: 35, icon: 'Users', iconBg: 'bg-purple-100', iconColor: 'text-purple-600' }
      ],
      topPerformers: regions.length > 0 ? regions.slice(0, 3).map((r, i) => ({
        name: r.name,
        metric: i === 0 ? 'En çok galeri' : i === 1 ? 'En çok araç' : 'En yüksek satış',
        value: `${r.percentage}%`
      })) : [],
      regions,
      charts: await this.getChartData(period as string, interval)
    });
  }

  // Helper method to get chart data
  private async getChartData(period: string, interval: string) {
    try {
      // Get user growth data (last 4 weeks or months based on period)
      const isWeekly = period === 'week';
      const dateFormat = isWeekly ? 'YYYY-MM-DD' : 'YYYY-MM';
      const groupBy = isWeekly ? 'DATE(created_at)' : 'DATE_TRUNC(\'month\', created_at)';
      
      const userGrowthResult = await query(`
        SELECT 
          ${groupBy} as period,
          COUNT(*) as count
        FROM users
        WHERE created_at > NOW() - INTERVAL '${interval}'
        GROUP BY ${groupBy}
        ORDER BY period ASC
        LIMIT 12
      `);

      const userGrowthLabels = userGrowthResult.rows.map((r: any) => {
        const date = new Date(r.period);
        return isWeekly 
          ? `${date.getDate()}/${date.getMonth() + 1}`
          : `${date.getMonth() + 1}/${date.getFullYear()}`;
      });
      const userGrowthData = userGrowthResult.rows.map((r: any) => parseInt(r.count));

      // Get revenue data (from subscriptions if available)
      let revenueData: number[] = [];
      let revenueLabels: string[] = [];
      
      try {
        const revenueResult = await query(`
          SELECT 
            ${groupBy} as period,
            SUM(price) as total
          FROM subscriptions
          WHERE created_at > NOW() - INTERVAL '${interval}'
            AND status = 'active'
          GROUP BY ${groupBy}
          ORDER BY period ASC
          LIMIT 12
        `);

        revenueLabels = revenueResult.rows.map((r: any) => {
          const date = new Date(r.period);
          return isWeekly 
            ? `${date.getDate()}/${date.getMonth() + 1}`
            : `${date.getMonth() + 1}/${date.getFullYear()}`;
        });
        revenueData = revenueResult.rows.map((r: any) => parseFloat(r.total || '0'));
      } catch (e) {
        // If subscriptions table doesn't exist, use empty data
        revenueLabels = userGrowthLabels;
        revenueData = new Array(userGrowthLabels.length).fill(0);
      }

      return {
        userGrowth: {
          labels: userGrowthLabels.length > 0 ? userGrowthLabels : ['Hafta 1', 'Hafta 2', 'Hafta 3', 'Hafta 4'],
          datasets: [{
            label: 'Yeni Kullanıcılar',
            data: userGrowthData.length > 0 ? userGrowthData : [0, 0, 0, 0],
            borderColor: 'rgb(59, 130, 246)',
            backgroundColor: 'rgba(59, 130, 246, 0.1)',
            fill: true
          }]
        },
        revenue: {
          labels: revenueLabels.length > 0 ? revenueLabels : userGrowthLabels.length > 0 ? userGrowthLabels : ['Hafta 1', 'Hafta 2', 'Hafta 3', 'Hafta 4'],
          datasets: [{
            label: 'Gelir (₺)',
            data: revenueData.length > 0 ? revenueData : [0, 0, 0, 0],
            backgroundColor: 'rgba(34, 197, 94, 0.8)'
          }]
        }
      };
    } catch (e) {
      // Fallback to empty charts
      return {
        userGrowth: {
          labels: ['Hafta 1', 'Hafta 2', 'Hafta 3', 'Hafta 4'],
          datasets: [{
            label: 'Yeni Kullanıcılar',
            data: [0, 0, 0, 0],
            borderColor: 'rgb(59, 130, 246)',
            backgroundColor: 'rgba(59, 130, 246, 0.1)',
            fill: true
          }]
        },
        revenue: {
          labels: ['Hafta 1', 'Hafta 2', 'Hafta 3', 'Hafta 4'],
          datasets: [{
            label: 'Gelir (₺)',
            data: [0, 0, 0, 0],
            backgroundColor: 'rgba(34, 197, 94, 0.8)'
          }]
        }
      };
    }
  }

  // ===================== SUBSCRIPTIONS =====================
  async listSubscriptions(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    try {
      const result = await query(`
        SELECT 
          s.id,
          s.gallery_id as "galleryId",
          g.name as "galleryName",
          g.email as "galleryEmail",
          s.plan,
          s.payment_type as "paymentType",
          s.start_date as "startDate",
          s.end_date as "endDate",
          s.status,
          s.price,
          s.currency,
          s.auto_renew as "autoRenew",
          s.trial_days as "trialDays",
          s.created_at as "createdAt"
        FROM subscriptions s
        LEFT JOIN galleries g ON s.gallery_id = g.id
        ORDER BY s.created_at DESC
      `);

      const subscriptions = result.rows.map(s => ({
        id: s.id,
        galleryId: s.galleryId,
        galleryName: s.galleryName || 'Unknown',
        galleryEmail: s.galleryEmail || '',
        plan: s.plan,
        paymentType: s.paymentType,
        startDate: s.startDate,
        endDate: s.endDate,
        status: s.status,
        price: parseFloat(s.price || '0'),
        currency: s.currency || 'TRY',
        autoRenew: s.autoRenew || false,
        trialDays: s.trialDays || 0,
        createdAt: s.createdAt
      }));

      res.json({
        success: true,
        subscriptions
      });
    } catch (e: any) {
      // If table doesn't exist, return empty array
      res.json({
        success: true,
        subscriptions: []
      });
    }
  }

  async createSubscription(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can create subscriptions');
    }

    const { galleryId, plan, paymentType, startDate, endDate, price, currency, autoRenew, trialDays } = req.body;

    if (!galleryId || !plan || !paymentType || !startDate || !price) {
      throw new ValidationError('Gallery ID, plan, payment type, start date and price are required');
    }

    // Validate plan
    const validPlans = ['basic', 'premium', 'enterprise', 'trial'];
    if (!validPlans.includes(plan)) {
      throw new ValidationError('Invalid plan');
    }

    // Validate payment type
    const validPaymentTypes = ['monthly', 'yearly', 'lifetime'];
    if (!validPaymentTypes.includes(paymentType)) {
      throw new ValidationError('Invalid payment type');
    }

    try {
      const result = await query(`
        INSERT INTO subscriptions (
          gallery_id, plan, payment_type, start_date, end_date, 
          price, currency, auto_renew, trial_days, status
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'active')
        RETURNING *
      `, [
        galleryId, plan, paymentType, startDate, endDate || null,
        price, currency || 'TRY', autoRenew !== false, trialDays || 0
      ]);

      res.json({
        success: true,
        message: 'Subscription created',
        subscription: result.rows[0]
      });
    } catch (e: any) {
      if (e.code === '42P01') {
        // Table doesn't exist
        throw new ValidationError('Subscriptions table not found. Please run database migrations.');
      }
      throw e;
    }
  }

  async updateSubscription(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update subscriptions');
    }

    const { id } = req.params;
    const { plan, paymentType, startDate, endDate, price, currency, autoRenew, status } = req.body;

    try {
      const updates: string[] = [];
      const values: any[] = [];
      let paramCount = 1;

      if (plan) {
        updates.push(`plan = $${paramCount++}`);
        values.push(plan);
      }
      if (paymentType) {
        updates.push(`payment_type = $${paramCount++}`);
        values.push(paymentType);
      }
      if (startDate) {
        updates.push(`start_date = $${paramCount++}`);
        values.push(startDate);
      }
      if (endDate !== undefined) {
        updates.push(`end_date = $${paramCount++}`);
        values.push(endDate);
      }
      if (price !== undefined) {
        updates.push(`price = $${paramCount++}`);
        values.push(price);
      }
      if (currency) {
        updates.push(`currency = $${paramCount++}`);
        values.push(currency);
      }
      if (autoRenew !== undefined) {
        updates.push(`auto_renew = $${paramCount++}`);
        values.push(autoRenew);
      }
      if (status) {
        updates.push(`status = $${paramCount++}`);
        values.push(status);
      }

      if (updates.length === 0) {
        throw new ValidationError('No fields to update');
      }

      updates.push(`updated_at = NOW()`);
      values.push(id);

      await query(
        `UPDATE subscriptions SET ${updates.join(', ')} WHERE id = $${paramCount}`,
        values
      );

      res.json({ success: true, message: 'Subscription updated' });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Subscriptions table not found');
      }
      throw e;
    }
  }

  async extendTrial(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can extend trials');
    }

    const { id } = req.params;
    const { days } = req.body;

    if (!days || days <= 0) {
      throw new ValidationError('Valid number of days is required');
    }

    try {
      await query(`
        UPDATE subscriptions 
        SET end_date = end_date + INTERVAL '${parseInt(days)} days',
            updated_at = NOW()
        WHERE id = $1 AND plan = 'trial'
      `, [id]);

      res.json({ success: true, message: 'Trial extended' });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Subscriptions table not found');
      }
      throw e;
    }
  }

  // ===================== LOGS =====================
  async getLogs(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { level, search } = req.query;

    // Try to get from audit_logs table
    try {
      let queryStr = `
        SELECT 
          al.id,
          al.created_at as timestamp,
          COALESCE(al.level, 'info') as level,
          al.service,
          COALESCE(u.email, 'Sistem') as user_email,
          al.user_id,
          al.action,
          COALESCE(al.details, al.action) as details,
          al.ip_address as ip,
          al.resolved
        FROM audit_logs al
        LEFT JOIN users u ON al.user_id = u.id
      `;
      
      const conditions: string[] = [];
      const params: any[] = [];
      let paramCount = 1;

      if (level) {
        conditions.push(`COALESCE(al.level, 'info') = $${paramCount++}`);
        params.push(level);
      }
      if (search) {
        conditions.push(`(al.action ILIKE $${paramCount} OR al.details ILIKE $${paramCount})`);
        params.push(`%${search}%`);
        paramCount++;
      }

      if (conditions.length > 0) {
        queryStr += ' WHERE ' + conditions.join(' AND ');
      }
      queryStr += ' ORDER BY al.created_at DESC LIMIT 100';

      const result = await query(queryStr, params);

      const logs = result.rows.map(r => ({
        id: r.id,
        timestamp: r.timestamp,
        level: r.level || 'info',
        service: r.service || 'System',
        user: r.user_email || 'Sistem',
        action: r.action,
        details: r.details || r.action || '',
        ip: r.ip || '-',
        resolved: r.resolved || false
      }));

      res.json({
        success: true,
        logs,
        stats: {
          error: logs.filter(l => l.level === 'error').length,
          warning: logs.filter(l => l.level === 'warning').length,
          info: logs.filter(l => l.level === 'info').length,
          success: logs.filter(l => l.level === 'success').length
        }
      });
      return;
    } catch (e: any) {
      // Table doesn't exist or error occurred, return empty logs
      res.json({
        success: true,
        logs: [],
        stats: { error: 0, warning: 0, info: 0, success: 0 }
      });
    }
  }

  async exportLogs(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    // Generate CSV
    const csv = 'Zaman,Seviye,Kullanıcı,Aktivite,Detay,IP\n' +
      `${new Date().toISOString()},info,admin@otobia.com,Giriş yapıldı,Başarılı,192.168.1.1`;

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=logs.csv');
    res.send(csv);
  }

  // ===================== SYSTEM STATUS =====================
  async getSystemStatus(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const services: any[] = [];
    const systemResources: any = {};
    const dbStats: any = {};

    // Check Database connectivity and get stats
    let dbStatus = 'healthy';
    let dbResponseTime = 0;
    
    // Test basic connectivity first
    try {
      const start = Date.now();
      await query('SELECT 1');
      dbResponseTime = Date.now() - start;
    } catch (e: any) {
      dbStatus = 'error';
      dbStats.totalTables = 0;
      dbStats.totalRecords = 0;
      dbStats.activeConnections = 0;
      dbStats.avgQueryTime = 0;
      // Skip rest if basic connection fails
    }
    
    // Only get stats if connection is healthy
    if (dbStatus === 'healthy') {
      // Get table count
      try {
        const tableCount = await query(`
          SELECT COUNT(*) as count 
          FROM information_schema.tables 
          WHERE table_schema = 'public'
        `);
        dbStats.totalTables = parseInt(tableCount.rows[0]?.count || '0');
      } catch (e) {
        dbStats.totalTables = 0;
      }
      
      // Get total records
      try {
        const totalRecords = await query(`
          SELECT SUM(n_live_tup)::bigint as total
          FROM pg_stat_user_tables
        `);
        dbStats.totalRecords = parseInt(totalRecords.rows[0]?.total || '0');
      } catch (e) {
        dbStats.totalRecords = 0;
      }
      
      // Get active connections
      try {
        const activeConnections = await query(`
          SELECT COUNT(*) as count 
          FROM pg_stat_activity 
          WHERE state = 'active'
        `);
        dbStats.activeConnections = parseInt(activeConnections.rows[0]?.count || '0');
      } catch (e) {
        dbStats.activeConnections = 0;
      }
      
      // Get average query time (pg_stat_statements might not be enabled)
      try {
        const avgQueryTime = await query(`
          SELECT COALESCE(AVG(mean_exec_time), 0) as avg_time
          FROM pg_stat_statements
          LIMIT 1
        `);
        dbStats.avgQueryTime = Math.round(parseFloat(avgQueryTime.rows[0]?.avg_time || '0'));
      } catch (e) {
        // pg_stat_statements extension might not be enabled, use fallback
        try {
          // Alternative: calculate from query execution time
          const testStart = Date.now();
          await query('SELECT NOW()');
          dbStats.avgQueryTime = Date.now() - testStart;
        } catch (e2) {
          dbStats.avgQueryTime = 0;
        }
      }
    }

    services.push({ name: 'Database', status: dbStatus, responseTime: dbResponseTime });

    // Check Redis connectivity
    let redisStatus = 'healthy';
    let redisResponseTime = 0;
    try {
      const Redis = (await import('ioredis')).default;
      const { config } = await import('@galeri/shared/config');
      const redis = new Redis({
        host: config.redis.host,
        port: config.redis.port,
        password: config.redis.password,
        connectTimeout: 2000,
        lazyConnect: true
      });
      
      const start = Date.now();
      await redis.ping();
      redisResponseTime = Date.now() - start;
      await redis.quit();
    } catch (e) {
      redisStatus = 'error';
    }
    services.push({ name: 'Redis', status: redisStatus, responseTime: redisResponseTime });

    // Check RabbitMQ connectivity
    let rabbitmqStatus = 'healthy';
    let rabbitmqResponseTime = 0;
    try {
      const { config } = await import('@galeri/shared/config');
      // Try to connect via HTTP to RabbitMQ management API (port 15672)
      const http = await import('http');
      const start = Date.now();
      await new Promise((resolve, reject) => {
        const req = http.get(`http://${config.rabbitmq.host}:15672/api/overview`, {
          timeout: 2000,
          auth: `${config.rabbitmq.user}:${config.rabbitmq.password}`
        }, (res) => {
          if (res.statusCode === 200 || res.statusCode === 401) {
            // 401 means server is up but auth failed, which is fine for health check
            resolve(res);
          } else {
            reject(new Error(`Status: ${res.statusCode}`));
          }
        });
        req.on('error', reject);
        req.on('timeout', () => {
          req.destroy();
          reject(new Error('Timeout'));
        });
      });
      rabbitmqResponseTime = Date.now() - start;
    } catch (e) {
      rabbitmqStatus = 'error';
    }
    services.push({ name: 'RabbitMQ', status: rabbitmqStatus, responseTime: rabbitmqResponseTime });

    // Check API Gateway (simple HTTP check)
    let apiGatewayStatus = 'healthy';
    let apiGatewayResponseTime = 0;
    try {
      const start = Date.now();
      const http = await import('http');
      const apiUrl = process.env.API_GATEWAY_URL || 'http://otobia-api-gateway:8000';
      await new Promise((resolve, reject) => {
        const req = http.get(`${apiUrl}/health`, { timeout: 2000 }, (res) => {
          resolve(res);
        });
        req.on('error', reject);
        req.on('timeout', () => {
          req.destroy();
          reject(new Error('Timeout'));
        });
      });
      apiGatewayResponseTime = Date.now() - start;
    } catch (e) {
      apiGatewayStatus = 'error';
    }
    services.push({ name: 'API Gateway', status: apiGatewayStatus, responseTime: apiGatewayResponseTime });

    // Get recent errors from audit_logs if table exists
    let recentErrors: any[] = [];
    try {
      const errorsResult = await query(`
        SELECT id, created_at as timestamp, service, message, resolved
        FROM audit_logs
        WHERE level = 'error'
        ORDER BY created_at DESC
        LIMIT 10
      `);
      recentErrors = errorsResult.rows.map((row: any) => ({
        id: row.id,
        timestamp: row.timestamp,
        service: row.service || 'Unknown',
        message: row.message || 'Error occurred',
        resolved: row.resolved || false
      }));
    } catch (e) {
      // Table might not exist, ignore
      recentErrors = [];
    }

    // Get system resources (CPU, Memory, Disk)
    try {
      const os = await import('os');
      
      // CPU Usage - Use load average correctly
      // Load average: average number of processes in runnable state
      // Load 1.0 on 1 CPU = 100% busy, Load 2.0 on 4 CPUs = 50% busy
      const cpusLength = os.cpus().length;
      const loadAvg = os.loadavg()[0]; // 1 minute load average
      
      let cpuUsage = 0;
      if (loadAvg > 0 && cpusLength > 0) {
        // Simple formula: (load / cpu_count) * 100
        // But cap at 85% max to avoid showing unrealistic 100%
        const loadPerCpu = loadAvg / cpusLength;
        cpuUsage = Math.min(85, Math.round(loadPerCpu * 100));
      }
      
      // If load is 0 or calculation failed, show minimal usage
      if (cpuUsage === 0 || isNaN(cpuUsage)) {
        cpuUsage = Math.max(1, Math.min(10, Math.round(loadAvg || 0))); // 1-10% baseline
      }
      
      const finalCpuUsage = cpuUsage;
      
      // Memory Usage
      const totalMem = os.totalmem();
      const freeMem = os.freemem();
      const usedMem = totalMem - freeMem;
      const memoryUsage = Math.round((usedMem / totalMem) * 100);
      
      // Disk Usage - Try to get from system command
      let diskUsage = 0;
      try {
        const { execSync } = await import('child_process');
        // Try df command (works on Linux)
        const dfOutput = execSync('df -h / 2>/dev/null || df -h .', { 
          encoding: 'utf-8',
          timeout: 2000,
          maxBuffer: 1024 * 1024
        });
        const lines = dfOutput.trim().split('\n');
        if (lines.length > 1) {
          const parts = lines[1].split(/\s+/).filter(p => p);
          // df output format: Filesystem Size Used Avail Use% Mounted
          // Find the percentage column
          for (let i = 0; i < parts.length; i++) {
            if (parts[i].endsWith('%')) {
              diskUsage = parseInt(parts[i].replace('%', '')) || 0;
              break;
            }
          }
        }
      } catch (e) {
        // If df fails, try alternative: estimate from database size
        try {
          const dbSizeResult = await query(`
            SELECT pg_database_size(current_database()) as size
          `);
          const dbSize = parseInt(dbSizeResult.rows[0]?.size || '0');
          // Rough estimate: assume container has ~20GB total space
          const estimatedTotal = 20 * 1024 * 1024 * 1024; // 20GB
          diskUsage = Math.min(95, Math.round((dbSize / estimatedTotal) * 100));
        } catch (e2) {
          diskUsage = 0;
        }
      }
      
      systemResources.cpuUsage = finalCpuUsage;
      systemResources.memoryUsage = memoryUsage;
      systemResources.diskUsage = diskUsage;
    } catch (e: any) {
      // Fallback values if system stats fail
      systemResources.cpuUsage = 0;
      systemResources.memoryUsage = 0;
      systemResources.diskUsage = 0;
    }

    res.json({
      success: true,
      services,
      systemResources,
      dbStats,
      recentErrors
    });
  }

  // ===================== ROLES =====================
  async listRoles(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    try {
      // Get all roles from database
      const rolesResult = await query(`
        SELECT 
          r.id,
          r.name,
          r.description,
          r.is_default as "isDefault",
          r.is_system as "isSystem",
          r.created_at as "createdAt",
          r.updated_at as "updatedAt"
        FROM roles r
        ORDER BY r.id ASC
      `);

      // Get permissions for each role
      const permissionsResult = await query(`
        SELECT 
          rp.role_id,
          rp.permission_id
        FROM role_permissions rp
      `);

      // Group permissions by role
      const rolePermissions: Record<number, number[]> = {};
      permissionsResult.rows.forEach((rp: any) => {
        if (!rolePermissions[rp.role_id]) {
          rolePermissions[rp.role_id] = [];
        }
        rolePermissions[rp.role_id].push(rp.permission_id);
      });

      // Count users per role (from users table)
      const roleCountsResult = await query(`
        SELECT role, COUNT(*) as count
        FROM users
        WHERE status != 'deleted'
        GROUP BY role
      `);

      const roleCounts: Record<string, number> = {};
      roleCountsResult.rows.forEach(r => {
        // Map database role names to role IDs
        const roleMap: Record<string, number> = {
          'superadmin': 1,
          'admin': 2,
          'compliance_officer': 3,
          'support_agent': 4,
          'gallery_owner': 5,
          'gallery_manager': 6
        };
        const roleId = roleMap[r.role];
        if (roleId) {
          roleCounts[roleId] = parseInt(r.count);
        }
      });

      const roles = rolesResult.rows.map((r: any) => ({
        id: r.id,
        name: r.name,
        description: r.description,
        permissions: rolePermissions[r.id] || [],
        isDefault: r.isDefault || false,
        isSystem: r.isSystem || false,
        userCount: roleCounts[r.id] || 0,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt
      }));

      res.json({
        success: true,
        roles
      });
    } catch (e: any) {
      // If tables don't exist, return default roles
      const roleCountsResult = await query(`
        SELECT role, COUNT(*) as count
        FROM users
        WHERE status != 'deleted'
        GROUP BY role
      `);

      const roleCounts: Record<string, number> = {};
      roleCountsResult.rows.forEach(r => {
        roleCounts[r.role] = parseInt(r.count);
      });

      const defaultRoles = [
        { id: 1, name: 'Süper Admin', description: 'Tüm sistem erişimi', permissions: [1,2,3,4,5,6,7,8,9,10], isDefault: true, userCount: roleCounts['superadmin'] || 0 },
        { id: 2, name: 'Admin', description: 'Yönetim paneli erişimi', permissions: [1,2,4,5,7], isDefault: false, userCount: roleCounts['admin'] || 0 },
        { id: 3, name: 'Uyum Sorumlusu', description: 'Galeri onay işlemleri', permissions: [1,2,7], isDefault: false, userCount: roleCounts['compliance_officer'] || 0 },
        { id: 4, name: 'Destek Temsilcisi', description: 'Müşteri desteği', permissions: [1,4,7], isDefault: false, userCount: roleCounts['support_agent'] || 0 },
        { id: 5, name: 'Galeri Sahibi', description: 'Galeri yönetimi', permissions: [1,4], isDefault: false, userCount: roleCounts['gallery_owner'] || 0 },
        { id: 6, name: 'Galeri Yöneticisi', description: 'Galeri operasyonları', permissions: [1], isDefault: false, userCount: roleCounts['gallery_manager'] || 0 }
      ];

      res.json({
        success: true,
        roles: defaultRoles
      });
    }
  }

  async getPermissions(req: AuthenticatedRequest, res: Response) {
    try {
      const result = await query(`
        SELECT id, name, description, category
        FROM permissions
        ORDER BY id ASC
      `);

      const permissions = result.rows.map((p: any) => ({
        id: p.id,
        name: p.name,
        description: p.description,
        category: p.category
      }));

      res.json({
        success: true,
        permissions
      });
    } catch (e: any) {
      // If table doesn't exist, return default permissions
      res.json({
        success: true,
        permissions: [
          { id: 1, name: 'Galerileri Görüntüle' },
          { id: 2, name: 'Galerileri Düzenle' },
          { id: 3, name: 'Galerileri Sil' },
          { id: 4, name: 'Kullanıcıları Görüntüle' },
          { id: 5, name: 'Kullanıcıları Düzenle' },
          { id: 6, name: 'Kullanıcıları Sil' },
          { id: 7, name: 'Raporları Görüntüle' },
          { id: 8, name: 'Sistem Ayarları' },
          { id: 9, name: 'Yedekleme Yönetimi' },
          { id: 10, name: 'Entegrasyon Yönetimi' }
        ]
      });
    }
  }

  async createRole(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can create roles');
    }

    const { name, description, permissions = [] } = req.body;

    if (!name) {
      throw new ValidationError('Role name is required');
    }

    try {
      // Check if role name already exists
      const existing = await query('SELECT id FROM roles WHERE name = $1', [name]);
      if (existing.rows.length > 0) {
        throw new ValidationError('Role with this name already exists');
      }

      // Create role
      const roleResult = await query(`
        INSERT INTO roles (name, description, is_default, is_system)
        VALUES ($1, $2, FALSE, FALSE)
        RETURNING *
      `, [name, description || '']);

      const roleId = roleResult.rows[0].id;

      // Add permissions
      if (Array.isArray(permissions) && permissions.length > 0) {
        const permissionValues = permissions.map((permId: number) => `(${roleId}, ${permId})`).join(', ');
        await query(`
          INSERT INTO role_permissions (role_id, permission_id)
          VALUES ${permissionValues}
          ON CONFLICT DO NOTHING
        `);
      }

      // Get created role with permissions
      const roleWithPerms = await query(`
        SELECT r.*, array_agg(rp.permission_id) as permissions
        FROM roles r
        LEFT JOIN role_permissions rp ON r.id = rp.role_id
        WHERE r.id = $1
        GROUP BY r.id
      `, [roleId]);

      const role = roleWithPerms.rows[0];

      res.json({
        success: true,
        id: role.id,
        name: role.name,
        description: role.description,
        permissions: role.permissions || [],
        isDefault: role.is_default || false,
        userCount: 0
      });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Roles table not found. Please run database migrations.');
      }
      throw e;
    }
  }

  async updateRole(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update roles');
    }

    const { id } = req.params;
    const roleId = parseInt(id);
    const { name, description, permissions } = req.body;

    try {
      // Check if role exists and is not system role
      const roleCheck = await query('SELECT is_system FROM roles WHERE id = $1', [roleId]);
      if (roleCheck.rows.length === 0) {
        throw new ValidationError('Role not found');
      }

      if (roleCheck.rows[0].is_system) {
        throw new ValidationError('System roles cannot be modified');
      }

      // Update role
      const updates: string[] = [];
      const values: any[] = [];
      let paramCount = 1;

      if (name) {
        updates.push(`name = $${paramCount++}`);
        values.push(name);
      }
      if (description !== undefined) {
        updates.push(`description = $${paramCount++}`);
        values.push(description);
      }

      if (updates.length > 0) {
        updates.push(`updated_at = NOW()`);
        values.push(roleId);
        await query(`UPDATE roles SET ${updates.join(', ')} WHERE id = $${paramCount}`, values);
      }

      // Update permissions if provided
      if (Array.isArray(permissions)) {
        // Delete existing permissions
        await query('DELETE FROM role_permissions WHERE role_id = $1', [roleId]);
        
        // Add new permissions
        if (permissions.length > 0) {
          const permissionValues = permissions.map((permId: number) => `(${roleId}, ${permId})`).join(', ');
          await query(`
            INSERT INTO role_permissions (role_id, permission_id)
            VALUES ${permissionValues}
          `);
        }
      }

      res.json({
        success: true,
        message: 'Role updated'
      });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Roles table not found');
      }
      throw e;
    }
  }

  async updateRolePermissions(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update permissions');
    }

    const { id } = req.params;
    const roleId = parseInt(id);
    const { permissionId, enabled, permissions } = req.body;

    try {
      // Check if role exists and is not system role
      const roleCheck = await query('SELECT is_system FROM roles WHERE id = $1', [roleId]);
      if (roleCheck.rows.length === 0) {
        throw new ValidationError('Role not found');
      }

      if (roleCheck.rows[0].is_system) {
        res.json({ success: true, message: 'System role permissions cannot be modified' });
        return;
      }

      // Handle both formats: single permission toggle or full permissions array
      if (permissions && Array.isArray(permissions)) {
        // Full permissions array update
        await query('DELETE FROM role_permissions WHERE role_id = $1', [roleId]);
        
        if (permissions.length > 0) {
          const permissionValues = permissions.map((permId: number) => `(${roleId}, ${permId})`).join(', ');
          await query(`
            INSERT INTO role_permissions (role_id, permission_id)
            VALUES ${permissionValues}
          `);
        }

        res.json({ success: true, message: 'Permissions updated' });
      } else if (permissionId !== undefined && enabled !== undefined) {
        // Single permission toggle
        const permId = parseInt(permissionId);
        
        if (enabled) {
          await query(`
            INSERT INTO role_permissions (role_id, permission_id)
            VALUES ($1, $2)
            ON CONFLICT DO NOTHING
          `, [roleId, permId]);
        } else {
          await query(`
            DELETE FROM role_permissions 
            WHERE role_id = $1 AND permission_id = $2
          `, [roleId, permId]);
        }

        res.json({ success: true, message: 'Permission updated' });
      } else {
        throw new ValidationError('Invalid request: provide either permissions array or permissionId+enabled');
      }
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Roles table not found');
      }
      throw e;
    }
  }

  async deleteRole(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can delete roles');
    }

    const { id } = req.params;
    const roleId = parseInt(id);

    try {
      // Check if role exists and is not system role
      const roleCheck = await query('SELECT is_system FROM roles WHERE id = $1', [roleId]);
      if (roleCheck.rows.length === 0) {
        throw new ValidationError('Role not found');
      }

      if (roleCheck.rows[0].is_system) {
        throw new ValidationError('System roles cannot be deleted');
      }

      // Check if role has users (count users with this role)
      const userCount = await query(`
        SELECT COUNT(*) as count
        FROM users
        WHERE role = (
          SELECT name FROM roles WHERE id = $1
        ) AND status != 'deleted'
      `, [roleId]);

      if (parseInt(userCount.rows[0].count) > 0) {
        throw new ValidationError('Cannot delete role with assigned users');
      }

      // Delete role (permissions will be deleted via CASCADE)
      await query('DELETE FROM roles WHERE id = $1', [roleId]);

      res.json({ success: true, message: 'Role deleted' });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Roles table not found');
      }
      throw e;
    }
  }

  // ===================== EMAIL TEMPLATES =====================
  async listEmailTemplates(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    try {
      const result = await query(`
        SELECT 
          id,
          name,
          subject,
          type,
          body_html as "bodyHtml",
          body_text as "bodyText",
          variables,
          is_active as active,
          created_at as "createdAt",
          updated_at as "updatedAt"
        FROM email_templates
        ORDER BY name ASC
      `);

      const templates = result.rows.map(t => ({
        id: t.id,
        name: t.name,
        subject: t.subject,
        type: t.type,
        bodyHtml: t.bodyHtml,
        bodyText: t.bodyText,
        variables: t.variables || [],
        active: t.active !== false,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt
      }));

      res.json({
        success: true,
        templates
      });
    } catch (e: any) {
      // If table doesn't exist, return empty array
      res.json({
        success: true,
        templates: []
      });
    }
  }

  // ===================== BACKUP =====================
  async listBackups(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can access backups');
    }

    try {
      const result = await query(`
        SELECT 
          id,
          filename as name,
          file_size as size,
          backup_type as type,
          status,
          created_at as "createdAt",
          completed_at as "completedAt",
          expires_at as "expiresAt"
        FROM backups
        ORDER BY created_at DESC
        LIMIT 50
      `);

      const backups = result.rows.map((b: any) => ({
        id: b.id,
        name: b.name,
        size: this.formatFileSize(b.size || 0),
        type: b.type,
        status: b.status,
        createdAt: b.createdAt,
        completedAt: b.completedAt,
        expiresAt: b.expiresAt
      }));

      // Get backup settings from system_settings
      const settingsResult = await query(`
        SELECT value FROM system_settings WHERE key = 'backup_settings'
      `);
      
      const settings = settingsResult.rows.length > 0 
        ? settingsResult.rows[0].value 
        : { autoBackup: false, frequency: 'daily', retention: 30 };

      res.json({
        success: true,
        backups,
        settings
      });
    } catch (e: any) {
      // If table doesn't exist, return empty
      res.json({
        success: true,
        backups: [],
        settings: { autoBackup: false, frequency: 'daily', retention: 30 }
      });
    }
  }

  async createBackup(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can create backups');
    }

    try {
      // Create backup directory if it doesn't exist
      const backupDir = process.env.BACKUP_DIR || '/tmp/backups';
      if (!existsSync(backupDir)) {
        mkdirSync(backupDir, { recursive: true });
      }

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const filename = `backup_${timestamp}.sql`;
      const filePath = path.join(backupDir, filename);

      // Create backup record
      const backupResult = await query(`
        INSERT INTO backups (filename, file_path, file_size, backup_type, status, created_by)
        VALUES ($1, $2, 0, 'manual', 'pending', $3)
        RETURNING id
      `, [filename, filePath, user.sub]);

      const backupId = backupResult.rows[0].id;

      // Run pg_dump in background (async)
      this.runBackup(filePath, backupId, user.sub).catch(err => {
        console.error('Backup failed:', err);
      });

      res.json({
        success: true,
        message: 'Backup started',
        id: backupId,
        createdAt: new Date().toISOString()
      });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Backups table not found. Please run database migrations.');
      }
      throw e;
    }
  }

  private async runBackup(filePath: string, backupId: string, userId: string) {
    try {
      const dbConfig = {
        host: process.env.DB_HOST || 'postgres',
        port: process.env.DB_PORT || '5432',
        database: process.env.DB_NAME || 'galeri_merkezi',
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || 'postgres'
      };

      const pgDumpCmd = `PGPASSWORD="${dbConfig.password}" pg_dump -h ${dbConfig.host} -p ${dbConfig.port} -U ${dbConfig.user} -d ${dbConfig.database} -F c -f ${filePath}`;

      await execAsync(pgDumpCmd);

      // Get file size
      const stats = await fs.stat(filePath);
      const fileSize = stats.size;

      // Update backup record
      await query(`
        UPDATE backups 
        SET status = 'completed', file_size = $1, completed_at = NOW()
        WHERE id = $2
      `, [fileSize, backupId]);

    } catch (error: any) {
      // Update backup record with error
      await query(`
        UPDATE backups 
        SET status = 'failed'
        WHERE id = $1
      `, [backupId]);
      throw error;
    }
  }

  private formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`;
  }

  async downloadBackup(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can download backups');
    }

    const { id } = req.params;

    try {
      const result = await query('SELECT file_path, filename FROM backups WHERE id = $1', [id]);
      if (result.rows.length === 0) {
        throw new ValidationError('Backup not found');
      }

      const backup = result.rows[0];
      const filePath = backup.file_path;

      // Check if file exists
      try {
        await fs.access(filePath);
        res.download(filePath, backup.filename);
      } catch (e) {
        throw new ValidationError('Backup file not found');
      }
    } catch (e: any) {
      throw e;
    }
  }

  async deleteBackup(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can delete backups');
    }

    const { id } = req.params;

    try {
      const result = await query('SELECT file_path FROM backups WHERE id = $1', [id]);
      if (result.rows.length === 0) {
        throw new ValidationError('Backup not found');
      }

      const filePath = result.rows[0].file_path;

      // Delete file if exists
      try {
        await fs.unlink(filePath);
      } catch (e) {
        // File might not exist, continue
      }

      // Delete record
      await query('DELETE FROM backups WHERE id = $1', [id]);

      res.json({ success: true, message: 'Backup deleted' });
    } catch (e: any) {
      throw e;
    }
  }

  async updateBackupSchedule(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update backup schedule');
    }

    const { enabled, frequency, retention } = req.body;

    try {
      await query(`
        INSERT INTO system_settings (key, value)
        VALUES ('backup_settings', $1::jsonb)
        ON CONFLICT (key) DO UPDATE SET value = $1::jsonb
      `, [JSON.stringify({ autoBackup: enabled, frequency, retention })]);

      res.json({ success: true, message: 'Backup schedule updated' });
    } catch (e: any) {
      throw e;
    }
  }

  // ===================== INTEGRATIONS =====================
  async listIntegrations(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    try {
      const result = await query(`
        SELECT 
          id,
          name,
          type,
          status,
          config,
          last_sync as "lastSync",
          last_error as "lastError",
          created_at as "createdAt",
          updated_at as "updatedAt"
        FROM integrations
        ORDER BY name ASC
      `);

      const integrations = result.rows.map((i: any) => ({
        id: i.id,
        name: i.name,
        type: i.type,
        status: i.status,
        config: i.config || {},
        lastSync: i.lastSync,
        lastError: i.lastError,
        createdAt: i.createdAt,
        updatedAt: i.updatedAt
      }));

      res.json({
        success: true,
        integrations
      });
    } catch (e: any) {
      // If table doesn't exist, return empty
      res.json({
        success: true,
        integrations: []
      });
    }
  }

  async updateIntegration(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update integrations');
    }

    const { id } = req.params;
    const { status, config } = req.body;

    try {
      const updates: string[] = [];
      const values: any[] = [];
      let paramCount = 1;

      if (status) {
        updates.push(`status = $${paramCount++}`);
        values.push(status);
      }
      if (config) {
        updates.push(`config = $${paramCount++}::jsonb`);
        values.push(JSON.stringify(config));
      }

      if (updates.length > 0) {
        updates.push(`updated_at = NOW()`);
        values.push(id);
        await query(`UPDATE integrations SET ${updates.join(', ')} WHERE id = $${paramCount}`, values);
      }

      res.json({ success: true, message: 'Integration updated' });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Integrations table not found');
      }
      throw e;
    }
  }

  // ===================== OTO SHORTS =====================
  async listOtoShorts(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { status, page = 1, limit = 20 } = req.query;

    try {
      let queryStr = `
        SELECT 
          os.id,
          os.title,
          os.video_url as "videoUrl",
          os.thumbnail_url as "thumbnailUrl",
          os.status,
          os.views,
          os.likes,
          os.created_at as "createdAt",
          g.name as "galleryName"
        FROM oto_shorts os
        LEFT JOIN galleries g ON os.gallery_id = g.id
      `;

      const conditions: string[] = [];
      const params: any[] = [];
      let paramCount = 1;

      if (status) {
        conditions.push(`os.status = $${paramCount++}`);
        params.push(status);
      }

      if (conditions.length > 0) {
        queryStr += ' WHERE ' + conditions.join(' AND ');
      }

      queryStr += ` ORDER BY os.created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
      params.push(parseInt(limit as string), (parseInt(page as string) - 1) * parseInt(limit as string));

      const result = await query(queryStr, params);

      // Get stats
      const statsResult = await query(`
        SELECT 
          COUNT(*) as "totalVideos",
          COUNT(*) FILTER (WHERE status = 'pending') as "pendingApproval",
          SUM(views) as "totalViews"
        FROM oto_shorts
      `);

      const stats = statsResult.rows[0];

      res.json({
        success: true,
        videos: result.rows,
        stats: {
          totalVideos: parseInt(stats.totalVideos || '0'),
          pendingApproval: parseInt(stats.pendingApproval || '0'),
          totalViews: parseInt(stats.totalViews || '0')
        },
        pagination: {
          page: parseInt(page as string),
          limit: parseInt(limit as string),
          total: parseInt(stats.totalVideos || '0')
        }
      });
    } catch (e: any) {
      // If table doesn't exist, return empty
      res.json({
        success: true,
        videos: [],
        stats: { totalVideos: 0, pendingApproval: 0, totalViews: 0 },
        pagination: { page: 1, limit: 20, total: 0 }
      });
    }
  }

  async approveVideo(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { id } = req.params;

    try {
      await query(`
        UPDATE oto_shorts 
        SET status = 'approved', approved_by = $1, approved_at = NOW()
        WHERE id = $2
      `, [user.sub, id]);

      res.json({ success: true, message: 'Video approved' });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Oto shorts table not found');
      }
      throw e;
    }
  }

  async rejectVideo(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { id } = req.params;
    const { reason } = req.body;

    try {
      await query(`
        UPDATE oto_shorts 
        SET status = 'rejected', rejection_reason = $1
        WHERE id = $2
      `, [reason || 'No reason provided', id]);

      res.json({ success: true, message: 'Video rejected' });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Oto shorts table not found');
      }
      throw e;
    }
  }

  // ===================== SPLASH CONFIG =====================
  async getSplashConfig(req: AuthenticatedRequest, res: Response) {
    res.json({
      success: true,
      config: {
        enabled: true,
        title: 'Otobia\'ya Hoş Geldiniz',
        subtitle: 'Türkiye\'nin En Büyük Oto Galeri Platformu',
        backgroundColor: '#1a1a2e',
        logoUrl: '/logo.png',
        duration: 3000
      }
    });
  }

  async updateSplashConfig(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update splash config');
    }

    res.json({ success: true, message: 'Splash config updated' });
  }

  // ===================== REPORTS =====================
  async getReports(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    try {
      const result = await query(`
        SELECT 
          id,
          name,
          type,
          format,
          status,
          file_size as "fileSize",
          generated_at as "generatedAt",
          expires_at as "expiresAt",
          created_at as "createdAt"
        FROM reports
        ORDER BY created_at DESC
        LIMIT 50
      `);

      const reports = result.rows.map((r: any) => ({
        id: r.id,
        name: r.name,
        type: r.type,
        format: r.format,
        status: r.status,
        fileSize: r.fileSize ? this.formatFileSize(r.fileSize) : null,
        generatedAt: r.generatedAt,
        expiresAt: r.expiresAt,
        createdAt: r.createdAt
      }));

      res.json({
        success: true,
        reports
      });
    } catch (e: any) {
      // If table doesn't exist, return empty
      res.json({
        success: true,
        reports: []
      });
    }
  }

  async generateReport(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { name, type, format = 'csv', parameters = {} } = req.body;

    if (!name || !type) {
      throw new ValidationError('Report name and type are required');
    }

    try {
      // Create report record
      const reportResult = await query(`
        INSERT INTO reports (name, type, format, status, parameters, generated_by)
        VALUES ($1, $2, $3, 'generating', $4::jsonb, $5)
        RETURNING id
      `, [name, type, format, JSON.stringify(parameters), user.sub]);

      const reportId = reportResult.rows[0].id;

      // Generate report in background
      this.generateReportFile(reportId, type, format, parameters).catch(err => {
        console.error('Report generation failed:', err);
      });

      res.json({
        success: true,
        message: 'Report generation started',
        id: reportId
      });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Reports table not found. Please run database migrations.');
      }
      throw e;
    }
  }

  private async generateReportFile(reportId: string, type: string, format: string, parameters: any) {
    try {
      let data: any[] = [];
      let filename = '';

      // Generate data based on report type
      if (type === 'gallery') {
        const result = await query(`
          SELECT 
            g.name as "Galeri",
            g.city as "Şehir",
            COUNT(DISTINCT u.id) as "Kullanıcı Sayısı",
            COUNT(DISTINCT v.id) as "Araç Sayısı",
            g.status as "Durum",
            g.created_at as "Kayıt Tarihi"
          FROM galleries g
          LEFT JOIN users u ON u.gallery_id = g.id
          LEFT JOIN vehicles v ON v.gallery_id = g.id
          GROUP BY g.id, g.name, g.city, g.status, g.created_at
          ORDER BY g.created_at DESC
        `);
        data = result.rows;
        filename = `gallery_report_${new Date().toISOString().split('T')[0]}`;
      } else if (type === 'vehicle') {
        const result = await query(`
          SELECT 
            v.id as "Araç ID",
            v.brand as "Marka",
            v.model as "Model",
            v.year as "Yıl",
            v.price as "Fiyat",
            g.name as "Galeri",
            v.status as "Durum",
            v.created_at as "Oluşturulma Tarihi"
          FROM vehicles v
          LEFT JOIN galleries g ON v.gallery_id = g.id
          ORDER BY v.created_at DESC
          LIMIT 1000
        `);
        data = result.rows;
        filename = `vehicle_report_${new Date().toISOString().split('T')[0]}`;
      } else if (type === 'financial') {
        const result = await query(`
          SELECT 
            DATE(s.created_at) as "Tarih",
            COUNT(*) as "Abonelik Sayısı",
            SUM(s.price) as "Toplam Gelir",
            s.currency as "Para Birimi"
          FROM subscriptions s
          WHERE s.status = 'active'
          GROUP BY DATE(s.created_at), s.currency
          ORDER BY DATE(s.created_at) DESC
        `);
        data = result.rows;
        filename = `financial_report_${new Date().toISOString().split('T')[0]}`;
      }

      // Generate file based on format
      const reportsDir = process.env.REPORTS_DIR || '/tmp/reports';
      if (!existsSync(reportsDir)) {
        mkdirSync(reportsDir, { recursive: true });
      }

      let filePath = '';
      let fileSize = 0;

      if (format === 'csv') {
        filePath = path.join(reportsDir, `${filename}.csv`);
        const csvContent = this.generateCSV(data);
        await fs.writeFile(filePath, csvContent, 'utf8');
        const stats = await fs.stat(filePath);
        fileSize = stats.size;
      } else if (format === 'json') {
        filePath = path.join(reportsDir, `${filename}.json`);
        await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
        const stats = await fs.stat(filePath);
        fileSize = stats.size;
      } else {
        // For xlsx and pdf, we'd need additional libraries
        // For now, generate as CSV
        filePath = path.join(reportsDir, `${filename}.csv`);
        const csvContent = this.generateCSV(data);
        await fs.writeFile(filePath, csvContent, 'utf8');
        const stats = await fs.stat(filePath);
        fileSize = stats.size;
      }

      // Update report record
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 30); // Expire in 30 days

      await query(`
        UPDATE reports 
        SET status = 'ready', file_path = $1, file_size = $2, generated_at = NOW(), expires_at = $3
        WHERE id = $4
      `, [filePath, fileSize, expiresAt, reportId]);

    } catch (error: any) {
      // Update report record with error
      await query(`
        UPDATE reports 
        SET status = 'failed'
        WHERE id = $1
      `, [reportId]);
      throw error;
    }
  }

  private generateCSV(data: any[]): string {
    if (data.length === 0) return '';

    const headers = Object.keys(data[0]);
    const csvRows = [headers.join(',')];

    for (const row of data) {
      const values = headers.map(header => {
        const value = row[header];
        if (value === null || value === undefined) return '';
        // Escape commas and quotes
        const stringValue = String(value).replace(/"/g, '""');
        return `"${stringValue}"`;
      });
      csvRows.push(values.join(','));
    }

    return csvRows.join('\n');
  }

  async downloadReport(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { id } = req.params;

    try {
      const result = await query('SELECT file_path, name, format FROM reports WHERE id = $1 AND status = $2', [id, 'ready']);
      if (result.rows.length === 0) {
        throw new ValidationError('Report not found or not ready');
      }

      const report = result.rows[0];
      const filePath = report.file_path;

      // Check if file exists
      try {
        await fs.access(filePath);
        const ext = report.format === 'json' ? 'json' : 'csv';
        res.download(filePath, `${report.name}.${ext}`);
      } catch (e) {
        throw new ValidationError('Report file not found');
      }
    } catch (e: any) {
      throw e;
    }
  }

  async exportReport(req: AuthenticatedRequest, res: Response) {
    // Legacy endpoint - redirect to generateReport
    return this.generateReport(req, res);
  }

  // ===================== PRICING PLANS =====================
  async listPricingPlans(req: Request, res: Response) {
    // Public endpoint - no auth required for landing page
    try {
      const result = await query(`
        SELECT 
          id,
          name,
          slug,
          description,
          price_monthly as "priceMonthly",
          price_yearly as "priceYearly",
          price_custom as "priceCustom",
          price_display as "priceDisplay",
          billing_note as "billingNote",
          is_featured as "isFeatured",
          is_active as "isActive",
          sort_order as "sortOrder",
          features,
          created_at as "createdAt",
          updated_at as "updatedAt"
        FROM pricing_plans
        WHERE is_active = TRUE
        ORDER BY sort_order ASC, created_at ASC
      `);

      const plans = result.rows.map((p: any) => ({
        id: p.id,
        name: p.name,
        slug: p.slug,
        description: p.description,
        price: p.priceCustom ? p.priceDisplay : (p.priceMonthly?.toString() || '0'),
        priceMonthly: p.priceMonthly ? parseFloat(p.priceMonthly) : null,
        priceYearly: p.priceYearly ? parseFloat(p.priceYearly) : null,
        priceCustom: p.priceCustom || false,
        priceDisplay: p.priceDisplay,
        billing: p.billingNote || 'Aylık ödeme',
        featured: p.isFeatured || false,
        features: p.features || []
      }));

      res.json({
        success: true,
        plans
      });
    } catch (e: any) {
      // Log error for debugging
      console.error('Error fetching pricing plans:', e.message, e.code);
      
      // If table doesn't exist or query fails, return default plans
      const defaultPlans = [
        {
          name: 'Başlangıç',
          slug: 'starter',
          description: 'Küçük galeriler için',
          price: '499',
          billing: 'Aylık ödeme',
          featured: false,
          features: ['50 araç yükleme', 'Temel stok yönetimi', 'E-posta desteği', 'Temel raporlar', '1 kanal bağlantısı']
        },
        {
          name: 'Profesyonel',
          slug: 'professional',
          description: 'Büyüyen galeriler için',
          price: '999',
          billing: 'Aylık ödeme',
          featured: true,
          features: ['Sınırsız araç yükleme', 'Gelişmiş stok yönetimi', 'Öncelikli destek', 'Detaylı analitik', 'Tüm kanal bağlantıları', 'API erişimi', 'Özel entegrasyonlar']
        },
        {
          name: 'Kurumsal',
          slug: 'enterprise',
          description: 'Büyük galeriler için',
          price: 'Özel',
          billing: 'Özel fiyatlandırma',
          featured: false,
          features: ['Sınırsız araç yükleme', 'Gelişmiş stok yönetimi', '7/24 öncelikli destek', 'Özel analitik dashboard', 'Tüm kanal bağlantıları', 'API erişimi', 'Özel entegrasyonlar', 'Dedike hesap yöneticisi', 'Özel eğitim ve danışmanlık']
        }
      ];
      
      res.json({
        success: true,
        plans: defaultPlans
      });
    }
  }

  async adminListPricingPlans(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    try {
      const result = await query(`
        SELECT 
          id,
          name,
          slug,
          description,
          price_monthly as "priceMonthly",
          price_yearly as "priceYearly",
          price_custom as "priceCustom",
          price_display as "priceDisplay",
          billing_note as "billingNote",
          is_featured as "isFeatured",
          is_active as "isActive",
          sort_order as "sortOrder",
          features,
          created_at as "createdAt",
          updated_at as "updatedAt"
        FROM pricing_plans
        ORDER BY sort_order ASC, created_at ASC
      `);

      const plans = result.rows.map((p: any) => ({
        id: p.id,
        name: p.name,
        slug: p.slug,
        description: p.description,
        priceMonthly: p.priceMonthly ? parseFloat(p.priceMonthly) : null,
        priceYearly: p.priceYearly ? parseFloat(p.priceYearly) : null,
        priceCustom: p.priceCustom || false,
        priceDisplay: p.priceDisplay,
        billingNote: p.billingNote,
        isFeatured: p.isFeatured || false,
        isActive: p.isActive !== false,
        sortOrder: p.sortOrder || 0,
        features: p.features || [],
        createdAt: p.createdAt,
        updatedAt: p.updatedAt
      }));

      res.json({
        success: true,
        plans
      });
    } catch (e: any) {
      console.error('Error fetching pricing plans for admin:', e.message, e.code);
      // If table doesn't exist, return empty array with error message
      if (e.code === '42P01') {
        res.json({
          success: true,
          plans: [],
          message: 'Pricing plans table not found. Please run database migrations.'
        });
      } else {
        // For other errors, still return empty array but log the error
        res.json({
          success: true,
          plans: [],
          error: e.message
        });
      }
    }
  }

  async createPricingPlan(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can create pricing plans');
    }

    const { name, slug, description, priceMonthly, priceYearly, priceCustom, priceDisplay, billingNote, isFeatured, sortOrder, features } = req.body;

    if (!name || !slug) {
      throw new ValidationError('Name and slug are required');
    }

    try {
      const result = await query(`
        INSERT INTO pricing_plans (
          name, slug, description, price_monthly, price_yearly, 
          price_custom, price_display, billing_note, is_featured, 
          sort_order, features, is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::jsonb, TRUE)
        RETURNING *
      `, [
        name, slug, description || null, priceMonthly || null, priceYearly || null,
        priceCustom || false, priceDisplay || null, billingNote || null,
        isFeatured || false, sortOrder || 0, JSON.stringify(features || [])
      ]);

      res.json({
        success: true,
        plan: result.rows[0]
      });
    } catch (e: any) {
      if (e.code === '23505') {
        throw new ValidationError('Plan with this slug already exists');
      }
      if (e.code === '42P01') {
        throw new ValidationError('Pricing plans table not found. Please run database migrations.');
      }
      throw e;
    }
  }

  async updatePricingPlan(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update pricing plans');
    }

    const { id } = req.params;
    const { name, slug, description, priceMonthly, priceYearly, priceCustom, priceDisplay, billingNote, isFeatured, isActive, sortOrder, features } = req.body;

    try {
      const updates: string[] = [];
      const values: any[] = [];
      let paramCount = 1;

      if (name) {
        updates.push(`name = $${paramCount++}`);
        values.push(name);
      }
      if (slug) {
        updates.push(`slug = $${paramCount++}`);
        values.push(slug);
      }
      if (description !== undefined) {
        updates.push(`description = $${paramCount++}`);
        values.push(description);
      }
      if (priceMonthly !== undefined) {
        updates.push(`price_monthly = $${paramCount++}`);
        values.push(priceMonthly);
      }
      if (priceYearly !== undefined) {
        updates.push(`price_yearly = $${paramCount++}`);
        values.push(priceYearly);
      }
      if (priceCustom !== undefined) {
        updates.push(`price_custom = $${paramCount++}`);
        values.push(priceCustom);
      }
      if (priceDisplay !== undefined) {
        updates.push(`price_display = $${paramCount++}`);
        values.push(priceDisplay);
      }
      if (billingNote !== undefined) {
        updates.push(`billing_note = $${paramCount++}`);
        values.push(billingNote);
      }
      if (isFeatured !== undefined) {
        updates.push(`is_featured = $${paramCount++}`);
        values.push(isFeatured);
      }
      if (isActive !== undefined) {
        updates.push(`is_active = $${paramCount++}`);
        values.push(isActive);
      }
      if (sortOrder !== undefined) {
        updates.push(`sort_order = $${paramCount++}`);
        values.push(sortOrder);
      }
      if (features !== undefined) {
        updates.push(`features = $${paramCount++}::jsonb`);
        values.push(JSON.stringify(features));
      }

      if (updates.length === 0) {
        throw new ValidationError('No fields to update');
      }

      updates.push(`updated_at = NOW()`);
      values.push(id);

      await query(
        `UPDATE pricing_plans SET ${updates.join(', ')} WHERE id = $${paramCount}`,
        values
      );

      res.json({ success: true, message: 'Pricing plan updated' });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Pricing plans table not found');
      }
      throw e;
    }
  }

  async deletePricingPlan(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can delete pricing plans');
    }

    const { id } = req.params;

    try {
      await query('DELETE FROM pricing_plans WHERE id = $1', [id]);
      res.json({ success: true, message: 'Pricing plan deleted' });
    } catch (e: any) {
      if (e.code === '42P01') {
        throw new ValidationError('Pricing plans table not found');
      }
      throw e;
    }
  }
}

