import axios from 'axios';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { query } from '@galeri/shared/database/connection';

interface Notification {
  id: string;
  type: string;
  body: string;
}

export class SMSService {
  async send(notification: Notification, phone: string) {
    try {
      // Get template
      const templateResult = await query(
        'SELECT sms_template FROM notification_templates WHERE type = $1 AND is_active = TRUE',
        [notification.type]
      );

      let message = notification.body;
      if (templateResult.rows.length > 0 && templateResult.rows[0].sms_template) {
        message = this.replaceVariables(templateResult.rows[0].sms_template, notification);
      }

      // Send via provider
      if (config.sms.provider === 'netgsm') {
        await this.sendViaNetGSM(phone, message);
      }

      // Log
      await query(
        `INSERT INTO notification_logs (notification_id, channel, provider, status)
         VALUES ($1, 'sms', $2, 'sent')`,
        [notification.id, config.sms.provider]
      );

      logger.info('SMS sent', { phone, notificationId: notification.id });
    } catch (error: any) {
      logger.error('SMS send failed', { error: error.message, phone });
      throw error;
    }
  }

  private async sendViaNetGSM(phone: string, message: string) {
    const response = await axios.get('https://api.netgsm.com.tr/sms/send/get', {
      params: {
        usercode: config.sms.netgsm.username,
        password: config.sms.netgsm.password,
        gsmno: phone.replace('+90', ''),
        message: message,
        msgheader: config.sms.netgsm.msgHeader
      }
    });

    if (!response.data.startsWith('00')) {
      throw new Error(`NetGSM error: ${response.data}`);
    }
  }

  private replaceVariables(template: string, notification: any): string {
    // Simple variable replacement
    return template
      .replace(/\{\{title\}\}/g, notification.title || '')
      .replace(/\{\{body\}\}/g, notification.body || '');
  }
}
















