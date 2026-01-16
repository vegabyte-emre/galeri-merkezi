import express from 'express';
import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { config } from '@galeri/shared/config';
import { offerRoutes } from './routes/offer';
import { errorHandler } from './middleware/errorHandler';

const app = express();
const PORT = config.port || 3004;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.json({ status: 'ok', service: 'offer-service', timestamp: new Date().toISOString() });
  } catch (error) {
    res.status(503).json({ status: 'error', service: 'offer-service' });
  }
});

// Routes
app.use('/offers', offerRoutes);

// Error handler
app.use(errorHandler);

app.listen(PORT, () => {
  logger.info(`Offer Service started on port ${PORT}`);
});
















