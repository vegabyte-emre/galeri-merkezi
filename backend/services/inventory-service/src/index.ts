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
