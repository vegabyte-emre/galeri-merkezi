import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { SMSService } from './smsService';
import { EmailService } from './emailService';
import { PushService } from './pushService';

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

  async sendNotification(notification: Notification) {
    // Get user preferences
    const userResult = await query(
      'SELECT notification_prefs, phone, email FROM users WHERE id = $1',
      [notification.userId]
    );

    if (userResult.rows.length === 0) {
      throw new Error('User not found');
    }

    const user = userResult.rows[0];
    const prefs = user.notification_prefs || {};

    // Check quiet hours
    if (this.isQuietHours(prefs.quiet_hours)) {
      logger.info('Skipping notification due to quiet hours', { notificationId: notification.id });
      return;
    }

    // Send via each channel
    for (const channel of notification.channels) {
      try {
        if (channel === 'sms' && prefs.sms !== false && user.phone) {
          await this.smsService.send(notification, user.phone);
        } else if (channel === 'email' && prefs.email !== false && user.email) {
          await this.emailService.send(notification, user.email);
        } else if (channel === 'push' && prefs.push !== false) {
          await this.pushService.send(notification, notification.userId);
        }
      } catch (error: any) {
        logger.error(`Failed to send ${channel} notification`, {
          error: error.message,
          notificationId: notification.id
        });
      }
    }

    // Update notification sent_at
    await query(
      'UPDATE notifications SET sent_at = NOW() WHERE id = $1',
      [notification.id]
    );
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
















