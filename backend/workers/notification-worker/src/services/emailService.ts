import nodemailer from 'nodemailer';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { query } from '@galeri/shared/database/connection';

interface Notification {
  id: string;
  type: string;
  title: string;
  body: string;
  metadata?: {
    email?: string;
    password?: string;
    galleryName?: string;
    [key: string]: any;
  };
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
      let subject = notification.title;
      let htmlBody = notification.body;
      let textBody = notification.body;

      // Handle welcome notification type with special template
      if (notification.type === 'welcome' && notification.metadata) {
        const { email: userEmail, password, galleryName } = notification.metadata;
        subject = 'Otobia\'ya Hoş Geldiniz - Hesap Bilgileriniz';
        
        htmlBody = `
          <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f9fafb;">
            <div style="background: linear-gradient(135deg, #f97316, #ea580c); padding: 40px 30px; text-align: center; border-radius: 12px 12px 0 0;">
              <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 700;">Otobia</h1>
              <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0; font-size: 16px;">Türkiye'nin Oto Galeri Platformu</p>
            </div>
            <div style="padding: 40px 30px; background: white;">
              <h2 style="color: #111827; margin: 0 0 20px 0; font-size: 22px;">Hoş Geldiniz!</h2>
              <p style="color: #4b5563; font-size: 16px; line-height: 1.6; margin: 0 0 20px 0;">
                Otobia platformuna hesabınız başarıyla oluşturuldu. Aşağıdaki bilgilerle giriş yapabilirsiniz.
              </p>
              ${galleryName ? `<p style="color: #4b5563; font-size: 16px; margin: 0 0 20px 0;"><strong>Galeri:</strong> ${galleryName}</p>` : ''}
              <div style="background: #f3f4f6; border-radius: 8px; padding: 20px; margin: 20px 0;">
                <p style="margin: 0 0 10px 0; color: #374151;"><strong>E-posta:</strong> ${userEmail}</p>
                <p style="margin: 0; color: #374151;"><strong>Şifre:</strong> ${password}</p>
              </div>
              <p style="color: #ef4444; font-size: 14px; margin: 20px 0;">
                ⚠️ Güvenliğiniz için lütfen ilk girişten sonra şifrenizi değiştirin.
              </p>
              <div style="text-align: center; margin: 30px 0;">
                <a href="https://panel.otobia.com/login" style="display: inline-block; background: linear-gradient(135deg, #f97316, #ea580c); color: white; text-decoration: none; padding: 14px 40px; border-radius: 8px; font-weight: 600; font-size: 16px;">
                  Giriş Yap
                </a>
              </div>
            </div>
            <div style="padding: 20px 30px; background: #f3f4f6; text-align: center; border-radius: 0 0 12px 12px;">
              <p style="color: #6b7280; font-size: 13px; margin: 0;">
                © ${new Date().getFullYear()} Otobia. Tüm hakları saklıdır.
              </p>
            </div>
          </div>
        `;
        
        textBody = `Otobia'ya Hoş Geldiniz!\n\nHesabınız başarıyla oluşturuldu.\n\n${galleryName ? `Galeri: ${galleryName}\n` : ''}E-posta: ${userEmail}\nŞifre: ${password}\n\nGiriş yapmak için: https://panel.otobia.com/login\n\nGüvenliğiniz için lütfen ilk girişten sonra şifrenizi değiştirin.`;
      } else {
        // Get template from database
        const templateResult = await query(
          'SELECT email_subject, email_body_html, email_body_text FROM notification_templates WHERE type = $1 AND is_active = TRUE',
          [notification.type]
        );

        if (templateResult.rows.length > 0) {
          const template = templateResult.rows[0];
          subject = template.email_subject || subject;
          htmlBody = template.email_body_html ? this.replaceVariables(template.email_body_html, notification) : htmlBody;
          textBody = template.email_body_text ? this.replaceVariables(template.email_body_text, notification) : textBody;
        }
      }

      await this.transporter.sendMail({
        from: config.email.smtp.from,
        to: email,
        subject,
        text: textBody,
        html: htmlBody
      });

      // Log
      try {
        await query(
          `INSERT INTO notification_logs (notification_id, channel, provider, status)
           VALUES ($1, 'email', 'smtp', 'sent')`,
          [notification.id]
        );
      } catch (logErr: any) {
        logger.warn('Failed to log email notification', { error: logErr.message });
      }

      logger.info('Email sent', { email, notificationId: notification.id, type: notification.type });
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
















