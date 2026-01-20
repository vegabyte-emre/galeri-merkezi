import express from 'express';
import cors from 'cors';
import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { config } from '@galeri/shared/config';
import { authRoutes } from './routes/auth';
import { userRoutes } from './routes/user';
import { errorHandler } from './middleware/errorHandler';

const app = express();
const PORT = config.port || 3001;

// CORS configuration - allow all origins
app.use(cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.json({ status: 'ok', service: 'auth-service', timestamp: new Date().toISOString() });
  } catch (error) {
    res.status(503).json({ status: 'error', service: 'auth-service' });
  }
});

// Routes
app.use('/auth', authRoutes);
app.use('/users', userRoutes);

// Error handler
app.use(errorHandler);

app.listen(PORT, () => {
  logger.info(`Auth Service started on port ${PORT}`);
});




