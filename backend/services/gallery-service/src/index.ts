import express from 'express';
import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { config } from '@galeri/shared/config';
import { galleryRoutes } from './routes/gallery';
import { userRoutes } from './routes/user';
import { eidsRoutes } from './routes/eids';
import { channelRoutes } from './routes/channel';
import { adminRoutes } from './routes/admin';
import { publicRoutes } from './routes/public';
import { errorHandler } from './middleware/errorHandler';

const app = express();
const PORT = config.port || 3002;

// Auto-run critical migrations on startup
async function runStartupMigrations() {
  try {
    logger.info('Running startup migrations...');
    
    // Add 'deleted' status to galleries for soft delete
    try {
      await query(`ALTER TABLE galleries DROP CONSTRAINT IF EXISTS galleries_status_check`);
      await query(`ALTER TABLE galleries ADD CONSTRAINT galleries_status_check CHECK (status IN ('pending', 'active', 'suspended', 'rejected', 'deleted'))`);
      logger.info('Updated galleries status constraint');
    } catch (e: any) {
      logger.warn(`galleries_status_check migration: ${e.message}`);
    }

    // Add 'deleted' status to users for soft delete
    try {
      await query(`ALTER TABLE users DROP CONSTRAINT IF EXISTS users_status_check`);
      await query(`ALTER TABLE users ADD CONSTRAINT users_status_check CHECK (status IN ('pending', 'active', 'suspended', 'deleted'))`);
      logger.info('Updated users status constraint');
    } catch (e: any) {
      logger.warn(`users_status_check migration: ${e.message}`);
    }

    // Add 'deleted' status to vehicles for soft delete
    try {
      await query(`ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS vehicles_status_check`);
      await query(`ALTER TABLE vehicles ADD CONSTRAINT vehicles_status_check CHECK (status IN ('draft', 'pending_approval', 'published', 'paused', 'archived', 'sold', 'rejected', 'deleted'))`);
      logger.info('Updated vehicles status constraint');
    } catch (e: any) {
      logger.warn(`vehicles_status_check migration: ${e.message}`);
    }

    // Add slug column to vehicles if not exists
    try {
      await query(`ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS slug VARCHAR(500)`);
      await query(`CREATE INDEX IF NOT EXISTS idx_vehicles_slug ON vehicles(slug)`);
      logger.info('Added vehicles slug column');
    } catch (e: any) {
      logger.warn(`vehicles slug migration: ${e.message}`);
    }

    logger.info('Startup migrations completed');
  } catch (error: any) {
    logger.error('Startup migrations failed:', error.message);
  }
}

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
app.use('/public', publicRoutes);

// Error handler
app.use(errorHandler);

app.listen(PORT, async () => {
  logger.info(`Gallery Service started on port ${PORT}`);
  // Run migrations after server starts
  await runStartupMigrations();
});

