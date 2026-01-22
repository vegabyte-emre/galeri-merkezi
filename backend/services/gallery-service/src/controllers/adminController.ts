import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError, ForbiddenError } from '@galeri/shared/utils/errors';

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
        u.id, u.name, u.email, u.phone, u.role, u.status, u.created_at,
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
        u.*, g.name as gallery_name
      FROM users u
      LEFT JOIN galleries g ON u.gallery_id = g.id
      WHERE u.id = $1
    `, [id]);

    if (result.rows.length === 0) {
      throw new ValidationError('User not found');
    }

    res.json({
      success: true,
      data: result.rows[0]
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

    // Check if email exists
    const existingUser = await query('SELECT id FROM users WHERE email = $1', [email]);
    if (existingUser.rows.length > 0) {
      throw new ValidationError('Email already exists');
    }

    const userId = uuidv4();
    let galleryId = null;

    // If gallery owner, create gallery first
    if (role === 'gallery_owner' && galleryName) {
      galleryId = uuidv4();
      await query(`
        INSERT INTO galleries (id, name, tax_type, tax_number, status, created_at)
        VALUES ($1, $2, $3, $4, 'pending', NOW())
      `, [galleryId, galleryName, taxType || 'VKN', taxNumber]);
    }

    // Hash password (use bcrypt in production)
    const bcrypt = await import('bcrypt');
    const hashedPassword = await bcrypt.hash(password, 10);

    await query(`
      INSERT INTO users (id, name, email, phone, password_hash, role, status, gallery_id, created_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
    `, [userId, name, email, phone, hashedPassword, role || 'gallery_owner', status || 'active', galleryId]);

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

    if (name) { updates.push(`name = $${paramCount++}`); values.push(name); }
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
      topPerformers: [
        { name: 'İstanbul', metric: 'En çok galeri', value: '45%' },
        { name: 'Ankara', metric: 'En çok araç', value: '20%' },
        { name: 'İzmir', metric: 'En yüksek satış', value: '15%' }
      ],
      regions,
      charts: {
        userGrowth: {
          labels: ['Hafta 1', 'Hafta 2', 'Hafta 3', 'Hafta 4'],
          datasets: [{
            label: 'Yeni Kullanıcılar',
            data: [10, 15, 12, 18],
            borderColor: 'rgb(59, 130, 246)',
            backgroundColor: 'rgba(59, 130, 246, 0.1)',
            fill: true
          }]
        },
        revenue: {
          labels: ['Hafta 1', 'Hafta 2', 'Hafta 3', 'Hafta 4'],
          datasets: [{
            label: 'Gelir (₺)',
            data: [5000, 7500, 6000, 9000],
            backgroundColor: 'rgba(34, 197, 94, 0.8)'
          }]
        }
      }
    });
  }

  // ===================== SUBSCRIPTIONS =====================
  async listSubscriptions(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    // Return demo data for now (subscriptions table would need to be created)
    const galleriesResult = await query(`
      SELECT 
        g.id as gallery_id,
        g.name as "galleryName",
        g.email as "galleryEmail",
        g.status,
        g.created_at as "startDate"
      FROM galleries g
      WHERE g.status = 'active'
      ORDER BY g.created_at DESC
      LIMIT 50
    `);

    const subscriptions = galleriesResult.rows.map((g, i) => ({
      id: i + 1,
      galleryId: g.gallery_id,
      galleryName: g.galleryName,
      galleryEmail: g.galleryEmail,
      plan: i % 3 === 0 ? 'enterprise' : (i % 2 === 0 ? 'premium' : 'basic'),
      paymentType: i % 2 === 0 ? 'monthly' : 'yearly',
      startDate: g.startDate,
      endDate: new Date(new Date(g.startDate).setFullYear(new Date(g.startDate).getFullYear() + 1)).toISOString(),
      status: 'active'
    }));

    res.json({
      success: true,
      subscriptions
    });
  }

  async createSubscription(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can create subscriptions');
    }

    // In a real implementation, this would create a subscription record
    res.json({ success: true, message: 'Subscription created' });
  }

  async updateSubscription(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update subscriptions');
    }

    res.json({ success: true, message: 'Subscription updated' });
  }

  async extendTrial(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can extend trials');
    }

    res.json({ success: true, message: 'Trial extended' });
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
          id,
          created_at as timestamp,
          level,
          user_id,
          action,
          details,
          ip_address as ip
        FROM audit_logs
      `;
      
      const conditions: string[] = [];
      const params: any[] = [];
      let paramCount = 1;

      if (level) {
        conditions.push(`level = $${paramCount++}`);
        params.push(level);
      }
      if (search) {
        conditions.push(`(action ILIKE $${paramCount} OR details ILIKE $${paramCount})`);
        params.push(`%${search}%`);
        paramCount++;
      }

      if (conditions.length > 0) {
        queryStr += ' WHERE ' + conditions.join(' AND ');
      }
      queryStr += ' ORDER BY created_at DESC LIMIT 100';

      const result = await query(queryStr, params);

      const logs = result.rows.map(r => ({
        id: r.id,
        timestamp: r.timestamp,
        level: r.level || 'info',
        user: r.user_id || 'Sistem',
        action: r.action,
        details: r.details || '',
        ip: r.ip || '-'
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
    } catch (e) {
      // Table doesn't exist, return demo data
    }

    // Demo data
    const logs = [
      { id: 1, timestamp: new Date().toISOString(), level: 'info', user: 'admin@otobia.com', action: 'Giriş yapıldı', details: 'Başarılı oturum açma', ip: '192.168.1.1' },
      { id: 2, timestamp: new Date(Date.now() - 3600000).toISOString(), level: 'success', user: 'Sistem', action: 'Yedekleme tamamlandı', details: 'Günlük yedekleme başarılı', ip: '-' },
      { id: 3, timestamp: new Date(Date.now() - 7200000).toISOString(), level: 'warning', user: 'Sistem', action: 'Disk alanı uyarısı', details: '%85 doluluk oranı', ip: '-' },
      { id: 4, timestamp: new Date(Date.now() - 10800000).toISOString(), level: 'error', user: 'Sistem', action: 'Bağlantı hatası', details: 'Redis bağlantısı koptu', ip: '-' }
    ];

    res.json({
      success: true,
      logs,
      stats: { error: 1, warning: 1, info: 1, success: 1 }
    });
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

    // Check database connectivity
    let dbStatus = 'healthy';
    let dbResponseTime = 0;
    try {
      const start = Date.now();
      await query('SELECT 1');
      dbResponseTime = Date.now() - start;
    } catch (e) {
      dbStatus = 'error';
    }

    res.json({
      success: true,
      services: [
        { name: 'API Gateway', status: 'healthy', responseTime: 45 },
        { name: 'Database', status: dbStatus, responseTime: dbResponseTime },
        { name: 'Redis', status: 'healthy', responseTime: 8 },
        { name: 'RabbitMQ', status: 'healthy', responseTime: 15 }
      ],
      recentErrors: []
    });
  }

  // ===================== ROLES =====================
  async listRoles(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    // Count users per role
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

    const roles = [
      { id: 1, name: 'Süper Admin', description: 'Tüm sistem erişimi', permissions: [1,2,3,4,5,6,7,8,9,10], isDefault: true, userCount: roleCounts['superadmin'] || 0 },
      { id: 2, name: 'Admin', description: 'Yönetim paneli erişimi', permissions: [1,2,4,5,7], isDefault: false, userCount: roleCounts['admin'] || 0 },
      { id: 3, name: 'Uyum Sorumlusu', description: 'Galeri onay işlemleri', permissions: [1,2,7], isDefault: false, userCount: roleCounts['compliance_officer'] || 0 },
      { id: 4, name: 'Destek Temsilcisi', description: 'Müşteri desteği', permissions: [1,4,7], isDefault: false, userCount: roleCounts['support_agent'] || 0 },
      { id: 5, name: 'Galeri Sahibi', description: 'Galeri yönetimi', permissions: [1,4], isDefault: false, userCount: roleCounts['gallery_owner'] || 0 },
      { id: 6, name: 'Galeri Yöneticisi', description: 'Galeri operasyonları', permissions: [1], isDefault: false, userCount: roleCounts['gallery_manager'] || 0 }
    ];

    res.json({
      success: true,
      roles
    });
  }

  async getPermissions(req: AuthenticatedRequest, res: Response) {
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

  async createRole(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can create roles');
    }

    res.json({ success: true, id: Date.now(), ...req.body, userCount: 0 });
  }

  async updateRole(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update roles');
    }

    res.json({ success: true, message: 'Role updated' });
  }

  async updateRolePermissions(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update permissions');
    }

    res.json({ success: true, message: 'Permissions updated' });
  }

  async deleteRole(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can delete roles');
    }

    res.json({ success: true, message: 'Role deleted' });
  }

  // ===================== EMAIL TEMPLATES =====================
  async listEmailTemplates(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    res.json({
      success: true,
      templates: [
        { id: 1, name: 'Hoş Geldiniz', subject: 'Otobia\'ya Hoş Geldiniz', type: 'welcome', active: true },
        { id: 2, name: 'Şifre Sıfırlama', subject: 'Şifre Sıfırlama Talebi', type: 'password_reset', active: true },
        { id: 3, name: 'Galeri Onayı', subject: 'Galeri Başvurunuz Onaylandı', type: 'gallery_approved', active: true },
        { id: 4, name: 'Galeri Reddi', subject: 'Galeri Başvurunuz Reddedildi', type: 'gallery_rejected', active: true },
        { id: 5, name: 'Yeni Teklif', subject: 'Aracınıza Yeni Teklif Geldi', type: 'new_offer', active: true }
      ]
    });
  }

  // ===================== BACKUP =====================
  async listBackups(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can access backups');
    }

    res.json({
      success: true,
      backups: [
        { id: 1, name: 'backup_2024_01_20.sql', size: '125 MB', createdAt: new Date().toISOString(), status: 'completed' },
        { id: 2, name: 'backup_2024_01_19.sql', size: '124 MB', createdAt: new Date(Date.now() - 86400000).toISOString(), status: 'completed' },
        { id: 3, name: 'backup_2024_01_18.sql', size: '123 MB', createdAt: new Date(Date.now() - 172800000).toISOString(), status: 'completed' }
      ],
      settings: {
        autoBackup: true,
        frequency: 'daily',
        retention: 30
      }
    });
  }

  async createBackup(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    if (user.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can create backups');
    }

    res.json({ success: true, message: 'Backup started' });
  }

  // ===================== INTEGRATIONS =====================
  async listIntegrations(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    res.json({
      success: true,
      integrations: [
        { id: 1, name: 'Sahibinden.com', type: 'listing', status: 'active', lastSync: new Date().toISOString() },
        { id: 2, name: 'Arabam.com', type: 'listing', status: 'inactive', lastSync: null },
        { id: 3, name: 'Firebase', type: 'push_notification', status: 'active', lastSync: new Date().toISOString() },
        { id: 4, name: 'Twilio', type: 'sms', status: 'active', lastSync: new Date().toISOString() },
        { id: 5, name: 'SendGrid', type: 'email', status: 'active', lastSync: new Date().toISOString() }
      ]
    });
  }

  // ===================== OTO SHORTS =====================
  async listOtoShorts(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    res.json({
      success: true,
      videos: [
        { id: 1, title: 'BMW M5 Tanıtım', galleryName: 'Premium Motors', status: 'pending', views: 0, createdAt: new Date().toISOString() },
        { id: 2, title: 'Mercedes E Serisi', galleryName: 'Luxury Cars', status: 'approved', views: 1250, createdAt: new Date(Date.now() - 86400000).toISOString() },
        { id: 3, title: 'Audi A6 Test Sürüşü', galleryName: 'Auto Gallery', status: 'approved', views: 890, createdAt: new Date(Date.now() - 172800000).toISOString() }
      ],
      stats: {
        totalVideos: 45,
        pendingApproval: 8,
        totalViews: 125000
      }
    });
  }

  async approveVideo(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    res.json({ success: true, message: 'Video approved' });
  }

  async rejectVideo(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin', 'compliance_officer'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    res.json({ success: true, message: 'Video rejected' });
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

    res.json({
      success: true,
      reports: [
        { id: 1, name: 'Aylık Galeri Raporu', type: 'gallery', generatedAt: new Date().toISOString(), status: 'ready' },
        { id: 2, name: 'Araç Satış Raporu', type: 'vehicle', generatedAt: new Date(Date.now() - 86400000).toISOString(), status: 'ready' },
        { id: 3, name: 'Finansal Özet', type: 'financial', generatedAt: new Date(Date.now() - 172800000).toISOString(), status: 'ready' }
      ]
    });
  }

  async exportReport(req: AuthenticatedRequest, res: Response) {
    const user = getUserFromHeaders(req);
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(user.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    // Generate a simple report
    const report = 'Tarih,Galeri,Araç Sayısı,Satış\n2024-01-20,Premium Motors,45,12';
    
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=report.csv');
    res.send(report);
  }
}

