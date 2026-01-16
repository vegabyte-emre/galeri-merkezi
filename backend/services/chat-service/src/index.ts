import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { config } from '@galeri/shared/config';
import { chatRoutes } from './routes/chat';
import { errorHandler } from './middleware/errorHandler';
import { setupWebSocket } from './websocket';

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    credentials: true
  }
});

const PORT = config.port || 3005;

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Middleware to attach io to requests
app.use((req: any, res, next) => {
  req.io = io;
  next();
});

// Health check
app.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.json({ status: 'ok', service: 'chat-service', timestamp: new Date().toISOString() });
  } catch (error) {
    res.status(503).json({ status: 'error', service: 'chat-service' });
  }
});

// Routes
app.use('/chats', chatRoutes);

// Error handler
app.use(errorHandler);

// Setup WebSocket
setupWebSocket(io);

httpServer.listen(PORT, () => {
  logger.info(`Chat Service started on port ${PORT}`);
});






