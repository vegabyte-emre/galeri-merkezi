import express from 'express';
import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { config } from '@galeri/shared/config';
import { vehicleRoutes } from './routes/vehicle';
import { videoRoutes } from './routes/video';
import { mediaRoutes } from './routes/media';
import { channelRoutes } from './routes/channel';
import { searchRoutes } from './routes/search';
import { marketplaceRoutes } from './routes/marketplace';
import { dashboardRoutes } from './routes/dashboard';
import { favoriteRoutes } from './routes/favorite';
import { notificationRoutes } from './routes/notification';
import { activityRoutes } from './routes/activity';
import { reportRoutes } from './routes/report';
import { configRoutes } from './routes/config';
import catalogRoutes from './routes/catalog';
import { shortsRoutes } from './routes/shorts';
import { errorHandler } from './middleware/errorHandler';

const app = express();
const PORT = config.port || 3003;

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check
app.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.json({ status: 'ok', service: 'inventory-service', timestamp: new Date().toISOString() });
  } catch (error) {
    res.status(503).json({ status: 'error', service: 'inventory-service' });
  }
});

// Banners endpoint (for mobile app)
app.get('/banners', async (req, res) => {
  try {
    // Try to get banners from system_settings
    const result = await query(
      `SELECT value FROM system_settings WHERE key = 'mobile_banners' LIMIT 1`
    );
    
    let banners = [];
    if (result.rows.length > 0) {
      try {
        banners = JSON.parse(result.rows[0].value);
      } catch (e) {
        // Use defaults
      }
    }
    
    // Default banners if none configured
    if (banners.length === 0) {
      banners = [
        {
          id: '1',
          title: 'Yeni Sezon Kampanyası',
          subtitle: 'Araçlarınızı öne çıkarın, %50 indirimli!',
          background_colors: ['#667eea', '#764ba2'],
          icon: 'megaphone',
          action_text: 'Detaylar',
          action_route: '/offer/list',
        },
        {
          id: '2',
          title: 'Oto Shorts ile Öne Çıkın',
          subtitle: 'Video paylaşarak daha fazla müşteriye ulaşın',
          background_colors: ['#f093fb', '#f5576c'],
          icon: 'videocam',
          action_text: 'Başla',
          action_route: '/(tabs)/shorts',
        },
        {
          id: '3',
          title: 'Premium Üyelik',
          subtitle: 'Sınırsız araç ekleme ve öncelikli listeleme',
          background_colors: ['#4facfe', '#00f2fe'],
          icon: 'diamond',
          action_text: 'İncele',
          action_route: '/(tabs)/profile',
        }
      ];
    }
    
    res.json(banners);
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Routes
app.use('/vehicles', vehicleRoutes);
app.use('/vehicles/video', videoRoutes);
app.use('/marketplace', marketplaceRoutes);
app.use('/media', mediaRoutes);
app.use('/channels', channelRoutes);
app.use('/search', searchRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/favorites', favoriteRoutes);
app.use('/notifications', notificationRoutes);
app.use('/activity', activityRoutes);
app.use('/reports', reportRoutes);
app.use('/config', configRoutes);
app.use('/catalog', catalogRoutes);
app.use('/shorts', shortsRoutes);

// Error handler
app.use(errorHandler);

app.listen(PORT, () => {
  logger.info(`Inventory Service started on port ${PORT}`);
});
