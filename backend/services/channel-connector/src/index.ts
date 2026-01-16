import express from 'express';
import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { config } from '@galeri/shared/config';
import { setupQueueConsumer } from './queue/consumer';
import { errorHandler } from './middleware/errorHandler';

const app = express();
const PORT = config.port || 3006;

app.use(express.json());

// Health check
app.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.json({ status: 'ok', service: 'channel-connector', timestamp: new Date().toISOString() });
  } catch (error) {
    res.status(503).json({ status: 'error', service: 'channel-connector' });
  }
});

// Error handler
app.use(errorHandler);

// Start queue consumer
setupQueueConsumer();

app.listen(PORT, () => {
  logger.info(`Channel Connector started on port ${PORT}`);
});
















