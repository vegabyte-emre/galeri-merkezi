import nodemailer from 'nodemailer';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { query } from '@galeri/shared/database/connection';

interface Notification {
  id: string;
  type: string;
  title: string;
  body: string;
}

export class EmailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      host: config.email.smtp.host,
      port: config.email.smtp.port,
      secure: config.email.smtp.port === 465,
      auth: {
        user: config.email.smtp.user,
        pass: config.email.smtp.password
      }
    });
  }

  async send(notification: Notification, email: string) {
    try {
      // Get template
      const templateResult = await query(
        'SELECT email_subject, email_body_html, email_body_text FROM notification_templates WHERE type = $1 AND is_active = TRUE',
        [notification.type]
      );

      let subject = notification.title;
      let htmlBody = notification.body;
      let textBody = notification.body;

      if (templateResult.rows.length > 0) {
        const template = templateResult.rows[0];
        subject = template.email_subject || subject;
        htmlBody = template.email_body_html ? this.replaceVariables(template.email_body_html, notification) : htmlBody;
        textBody = template.email_body_text ? this.replaceVariables(template.email_body_text, notification) : textBody;
      }

      await this.transporter.sendMail({
        from: config.email.smtp.from,
        to: email,
        subject,
        text: textBody,
        html: htmlBody
      });

      // Log
      await query(
        `INSERT INTO notification_logs (notification_id, channel, provider, status)
         VALUES ($1, 'email', 'smtp', 'sent')`,
        [notification.id]
      );

      logger.info('Email sent', { email, notificationId: notification.id });
    } catch (error: any) {
      logger.error('Email send failed', { error: error.message, email });
      throw error;
    }
  }

  private replaceVariables(template: string, notification: any): string {
    return template
      .replace(/\{\{title\}\}/g, notification.title || '')
      .replace(/\{\{body\}\}/g, notification.body || '');
  }
}
















