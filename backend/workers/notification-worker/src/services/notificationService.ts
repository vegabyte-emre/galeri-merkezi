import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { SMSService } from './smsService';
import { EmailService } from './emailService';
import { PushService } from './pushService';
import { v4 as uuidv4 } from 'uuid';

interface Notification {
  id: string;
  userId: string;
  galleryId?: string;
  type: string;
  title: string;
  body: string;
  data?: any;
  channels: string[];
}

export class NotificationService {
  private smsService: SMSService;
  private emailService: EmailService;
  private pushService: PushService;

  constructor() {
    this.smsService = new SMSService();
    this.emailService = new EmailService();
    this.pushService = new PushService();
  }

  async sendNotification(notification: any) {
    // Special handling for OTP notifications (no userId, just phone)
    if (notification.type === 'otp' && notification.phone) {
      try {
        await this.smsService.send({
          id: notification.id || 'otp-' + Date.now(),
          type: 'otp',
          body: `Doğrulama kodunuz: ${notification.otp}`
        }, notification.phone);
        logger.info('OTP SMS sent', { phone: notification.phone });
        return;
      } catch (error: any) {
        logger.error('OTP SMS failed', { error: error.message, phone: notification.phone });
        throw error;
      }
    }

    // Handle targetRole notifications (e.g., send to all superadmins)
    if (notification.targetRole) {
      await this.sendToRole(notification);
      return;
    }

    // Handle galleryId notifications (send to gallery owner)
    if (notification.galleryId && !notification.userId) {
      await this.sendToGalleryOwner(notification);
      return;
    }

    // For other notifications, require userId
    if (!notification.userId) {
      logger.warn('Notification skipped: No userId, targetRole, or galleryId provided', { type: notification.type });
      return;
    }

    await this.sendToUser(notification, notification.userId);
  }

  // Send notification to all users with a specific role
  private async sendToRole(notification: any) {
    const { targetRole, type, title, message, vehicleId, galleryId } = notification;
    
    logger.info('Sending notification to role', { targetRole, type });

    // Find all users with the target role
    const usersResult = await query(
      'SELECT id, email, phone, notification_prefs FROM users WHERE role = $1 AND status = $2',
      [targetRole, 'active']
    );

    if (usersResult.rows.length === 0) {
      logger.warn('No active users found for role', { targetRole });
      return;
    }

    logger.info('Found users for role notification', { targetRole, count: usersResult.rows.length });

    // Create notification record and send to each user
    for (const user of usersResult.rows) {
      try {
        // Create notification record in database
        const notificationId = uuidv4();
        await query(
          `INSERT INTO notifications (id, user_id, gallery_id, type, title, body, data, channels, created_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, ARRAY['push', 'email']::VARCHAR(50)[], NOW())`,
          [
            notificationId,
            user.id,
            galleryId || null,
            type,
            title,
            message,
            JSON.stringify({ vehicleId, galleryId })
          ]
        );

        // Send notification
        const userNotification = {
          id: notificationId,
          type,
          title,
          body: message,
          data: { vehicleId, galleryId },
          channels: ['push', 'email']
        };

        await this.sendToUser(userNotification, user.id, user);
        logger.info('Role notification sent to user', { userId: user.id, targetRole, type });
      } catch (error: any) {
        logger.error('Failed to send role notification to user', { 
          userId: user.id, 
          targetRole, 
          error: error.message 
        });
      }
    }
  }

  // Send notification to gallery owner
  private async sendToGalleryOwner(notification: any) {
    const { galleryId, type, title, message, vehicleId } = notification;

    logger.info('Sending notification to gallery owner', { galleryId, type });

    // Find gallery owner
    const ownerResult = await query(
      `SELECT id, email, phone, notification_prefs FROM users 
       WHERE gallery_id = $1 AND role = 'gallery_owner' AND status = 'active'
       LIMIT 1`,
      [galleryId]
    );

    if (ownerResult.rows.length === 0) {
      logger.warn('No gallery owner found', { galleryId });
      return;
    }

    const owner = ownerResult.rows[0];

    try {
      // Create notification record
      const notificationId = uuidv4();
      await query(
        `INSERT INTO notifications (id, user_id, gallery_id, type, title, body, data, channels, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, ARRAY['push', 'email']::VARCHAR(50)[], NOW())`,
        [
          notificationId,
          owner.id,
          galleryId,
          type,
          title,
          message,
          JSON.stringify({ vehicleId })
        ]
      );

      // Send notification
      const userNotification = {
        id: notificationId,
        type,
        title,
        body: message,
        data: { vehicleId, galleryId },
        channels: ['push', 'email']
      };

      await this.sendToUser(userNotification, owner.id, owner);
      logger.info('Gallery owner notification sent', { ownerId: owner.id, galleryId, type });
    } catch (error: any) {
      logger.error('Failed to send gallery owner notification', { 
        galleryId, 
        error: error.message 
      });
    }
  }

  // Send notification to a specific user
  private async sendToUser(notification: any, userId: string, userCache?: any) {
    let user = userCache;

    if (!user) {
      const userResult = await query(
        'SELECT notification_prefs, phone, email FROM users WHERE id = $1',
        [userId]
      );

      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      user = userResult.rows[0];
    }

    const prefs = user.notification_prefs || {};

    // Check quiet hours (skip for OTP and critical notifications)
    if (!['otp', 'password_reset'].includes(notification.type) && this.isQuietHours(prefs.quiet_hours)) {
      logger.info('Skipping notification due to quiet hours', { notificationId: notification.id });
      return;
    }

    // Send via each channel
    for (const channel of notification.channels || []) {
      try {
        if (channel === 'sms' && prefs.sms !== false && user.phone) {
          await this.smsService.send(notification, user.phone);
        } else if (channel === 'email' && prefs.email !== false && user.email) {
          await this.emailService.send(notification, user.email);
        } else if (channel === 'push' && prefs.push !== false) {
          await this.pushService.send(notification, userId);
        }
      } catch (error: any) {
        logger.error(`Failed to send ${channel} notification`, {
          error: error.message,
          notificationId: notification.id
        });
      }
    }

    // Update notification sent_at if notification record exists
    if (notification.id) {
      try {
        await query(
          'UPDATE notifications SET sent_at = NOW() WHERE id = $1',
          [notification.id]
        );
      } catch (error: any) {
        // Notification record might not exist, continue
        logger.debug('Could not update notification record', { notificationId: notification.id });
      }
    }
  }

  private isQuietHours(quietHours?: any): boolean {
    if (!quietHours) return false;

    const now = new Date();
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    const start = quietHours.start || '22:00';
    const end = quietHours.end || '08:00';

    // Simple check (can be improved with timezone support)
    return currentTime >= start || currentTime <= end;
  }
}
















