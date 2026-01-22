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
      const tokensResult = await query(
        'SELECT token FROM fcm_tokens WHERE user_id = $1 AND is_active = TRUE',
        [userId]
      );

      if (tokensResult.rows.length === 0) {
        logger.info('No FCM tokens found for user', { userId });
        return; // No tokens, skip push notification
      }

      // Get template
      const templateResult = await query(
        'SELECT push_template FROM notification_templates WHERE type = $1 AND is_active = TRUE',
        [notification.type]
      );

      let message = notification.body;
      if (templateResult.rows.length > 0 && templateResult.rows[0].push_template) {
        message = this.replaceVariables(templateResult.rows[0].push_template, notification);
      }

      // Send to all active tokens
      const { config } = await import('@galeri/shared/config');
      const tokens = tokensResult.rows.map((r: any) => r.token);
      let successCount = 0;
      let failCount = 0;

      for (const token of tokens) {
        try {
          if (!config.fcm.serverKey) {
            logger.warn('FCM server key not configured, skipping push notification');
            continue;
          }

          const fcmResponse = await axios.post(
            config.fcm.apiUrl,
            {
              to: token,
              notification: {
                title: notification.title,
                body: message
              },
              data: notification.data || {}
            },
            {
              headers: {
                'Authorization': `key=${config.fcm.serverKey}`,
                'Content-Type': 'application/json'
              }
            }
          );

          if (fcmResponse.data.success === 1) {
            successCount++;
            // Update token last_used_at
            await query(
              'UPDATE fcm_tokens SET last_used_at = NOW() WHERE token = $1',
              [token]
            );
          } else {
            failCount++;
            // If token is invalid, mark as inactive
            if (fcmResponse.data.results?.[0]?.error === 'InvalidRegistration' || 
                fcmResponse.data.results?.[0]?.error === 'NotRegistered') {
              await query(
                'UPDATE fcm_tokens SET is_active = FALSE WHERE token = $1',
                [token]
              );
            }
          }
        } catch (error: any) {
          failCount++;
          logger.error('FCM send failed for token', { 
            error: error.message, 
            token: token.substring(0, 20) + '...',
            userId 
          });
        }
      }

      // Log
      await query(
        `INSERT INTO notification_logs (notification_id, channel, provider, status, provider_response)
         VALUES ($1, 'push', 'fcm', $2, $3::jsonb)`,
        [
          notification.id,
          successCount > 0 ? 'sent' : 'failed',
          JSON.stringify({ successCount, failCount, totalTokens: tokens.length })
        ]
      );

      logger.info('Push notification processed', { 
        userId, 
        notificationId: notification.id,
        successCount,
        failCount,
        totalTokens: tokens.length
      });
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
















