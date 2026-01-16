import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { ValidationError } from '@galeri/shared/utils/errors';

interface SplashConfig {
  title: string;
  subtitle: string;
  tagline: string;
  version: string;
  logoEmoji?: string;
  gradientColors?: string[];
  animationDuration?: number;
  showParticles?: boolean;
  particleColor?: string;
}

const DEFAULT_SPLASH_CONFIG: SplashConfig = {
  title: 'Galeri Merkezi',
  subtitle: 'Araç Yönetim Platformu',
  tagline: 'Galerinizi Dijitalleştirin',
  version: 'v1.0.0',
  logoEmoji: '🚗',
  gradientColors: ['#FF6B35', '#FF8F5F'],
  animationDuration: 3000,
  showParticles: true,
  particleColor: '#FF6B35',
};

function getUserFromHeaders(req: Request) {
  return {
    user_id: req.headers['x-user-id'] as string,
    gallery_id: req.headers['x-gallery-id'] as string,
    role: req.headers['x-user-role'] as string,
  };
}

export class ConfigController {
  async getSplashConfig(req: Request, res: Response) {
    try {
      const result = await query(
        `SELECT value, updated_at FROM system_settings WHERE key = 'splash_config' LIMIT 1`
      );

      if (result.rows.length === 0) {
        return res.json({
          success: true,
          config: DEFAULT_SPLASH_CONFIG,
          lastUpdated: new Date().toISOString(),
        });
      }

      const config = typeof result.rows[0].value === 'string' 
        ? JSON.parse(result.rows[0].value) 
        : result.rows[0].value;
      
      res.json({
        success: true,
        config: { ...DEFAULT_SPLASH_CONFIG, ...config },
        lastUpdated: result.rows[0].updated_at || new Date().toISOString(),
      });
    } catch (error: any) {
      console.error('Get splash config error:', error);
      res.json({
        success: true,
        config: DEFAULT_SPLASH_CONFIG,
        lastUpdated: new Date().toISOString(),
      });
    }
  }

  async updateSplashConfig(req: Request, res: Response) {
    const userInfo = getUserFromHeaders(req);
    
    if (userInfo.role !== 'super_admin') {
      throw new ValidationError('Bu işlem için süper admin yetkisi gereklidir.');
    }

    const { config } = req.body;

    if (!config) {
      throw new ValidationError('Config verisi gereklidir.');
    }

    const validFields = [
      'title', 'subtitle', 'tagline', 'version', 
      'logoEmoji', 'gradientColors', 'animationDuration',
      'showParticles', 'particleColor'
    ];

    const sanitizedConfig: Partial<SplashConfig> = {};
    for (const field of validFields) {
      if (config[field] !== undefined) {
        (sanitizedConfig as any)[field] = config[field];
      }
    }

    try {
      const existing = await query(
        `SELECT id FROM system_settings WHERE key = 'splash_config' LIMIT 1`
      );

      if (existing.rows.length === 0) {
        await query(
          `INSERT INTO system_settings (key, value, description, updated_by) 
           VALUES ($1, $2, $3, $4)`,
          ['splash_config', JSON.stringify(sanitizedConfig), 'Mobile app splash screen configuration', userInfo.user_id]
        );
      } else {
        await query(
          `UPDATE system_settings SET value = $1, updated_at = NOW(), updated_by = $2 WHERE key = 'splash_config'`,
          [JSON.stringify(sanitizedConfig), userInfo.user_id]
        );
      }

      res.json({
        success: true,
        message: 'Splash screen ayarları güncellendi.',
        config: { ...DEFAULT_SPLASH_CONFIG, ...sanitizedConfig },
      });
    } catch (error: any) {
      console.error('Update splash config error:', error);
      throw new ValidationError('Splash config güncellenirken bir hata oluştu.');
    }
  }

  async getAllConfigs(req: Request, res: Response) {
    const userInfo = getUserFromHeaders(req);
    
    if (userInfo.role !== 'super_admin') {
      throw new ValidationError('Bu işlem için süper admin yetkisi gereklidir.');
    }

    try {
      const result = await query(
        `SELECT key, value, description, updated_at, updated_by FROM system_settings ORDER BY key`
      );

      res.json({
        success: true,
        configs: result.rows.map(row => ({
          key: row.key,
          value: typeof row.value === 'string' ? JSON.parse(row.value) : row.value,
          description: row.description,
          updatedAt: row.updated_at,
          updatedBy: row.updated_by,
        })),
      });
    } catch (error: any) {
      console.error('Get all configs error:', error);
      res.json({ success: true, configs: [] });
    }
  }
}
