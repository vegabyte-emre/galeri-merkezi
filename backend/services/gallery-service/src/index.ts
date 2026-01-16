import express from 'express';
import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { config } from '@galeri/shared/config';
import { galleryRoutes } from './routes/gallery';
import { userRoutes } from './routes/user';
import { eidsRoutes } from './routes/eids';
import { channelRoutes } from './routes/channel';
import { adminRoutes } from './routes/admin';
import { errorHandler } from './middleware/errorHandler';

const app = express();
const PORT = config.port || 3002;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.json({ status: 'ok', service: 'gallery-service', timestamp: new Date().toISOString() });
  } catch (error) {
    res.status(503).json({ status: 'error', service: 'gallery-service' });
  }
});

// Routes
app.use('/galleries', galleryRoutes);
app.use('/users', userRoutes);
app.use('/eids', eidsRoutes);
app.use('/channels', channelRoutes);
app.use('/admin', adminRoutes);

// Error handler
app.use(errorHandler);

app.listen(PORT, () => {
  logger.info(`Gallery Service started on port ${PORT}`);
});

