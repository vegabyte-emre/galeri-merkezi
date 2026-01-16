import axios from 'axios';
import { logger } from '@galeri/shared/utils/logger';
import { query } from '@galeri/shared/database/connection';

interface Notification {
  id: string;
  type: string;
  title: string;
  body: string;
  data?: any;
}

export class PushService {
  async send(notification: Notification, userId: string) {
    try {
      // Get FCM tokens for user
      // TODO: Implement FCM token storage and retrieval

      // Get template
      const templateResult = await query(
        'SELECT push_template FROM notification_templates WHERE type = $1 AND is_active = TRUE',
        [notification.type]
      );

      let message = notification.body;
      if (templateResult.rows.length > 0 && templateResult.rows[0].push_template) {
        message = this.replaceVariables(templateResult.rows[0].push_template, notification);
      }

      // TODO: Send via FCM
      // const fcmResponse = await axios.post('https://fcm.googleapis.com/fcm/send', {
      //   to: fcmToken,
      //   notification: {
      //     title: notification.title,
      //     body: message
      //   },
      //   data: notification.data
      // }, {
      //   headers: {
      //     'Authorization': `key=${process.env.FCM_SERVER_KEY}`
      //   }
      // });

      // Log
      await query(
        `INSERT INTO notification_logs (notification_id, channel, provider, status)
         VALUES ($1, 'push', 'fcm', 'sent')`,
        [notification.id]
      );

      logger.info('Push notification sent', { userId, notificationId: notification.id });
    } catch (error: any) {
      logger.error('Push notification failed', { error: error.message, userId });
      throw error;
    }
  }

  private replaceVariables(template: string, notification: any): string {
    return template
      .replace(/\{\{title\}\}/g, notification.title || '')
      .replace(/\{\{body\}\}/g, notification.body || '');
  }
}
















