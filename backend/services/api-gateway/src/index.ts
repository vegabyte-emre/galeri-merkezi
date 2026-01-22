import express from 'express';
import { createProxyMiddleware, fixRequestBody } from 'http-proxy-middleware';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import Redis from 'ioredis';
import { logger } from '@galeri/shared/utils/logger';
import { config } from '@galeri/shared/config';
import { authMiddleware } from './middleware/auth';
import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';

const app = express();
const PORT = config.port || 3000;

// Trust proxy for rate limiting behind reverse proxy (Traefik)
app.set('trust proxy', 1);

const redis = new Redis({
  host: config.redis.host || 'redis',
  port: config.redis.port || 6379,
  password: config.redis.password || undefined,
  retryStrategy: (times) => Math.min(times * 50, 2000),
  maxRetriesPerRequest: 3
});

app.use(helmet());
app.use(compression());
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || '*',
  credentials: true
}));
app.use(requestLogger);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'api-gateway', timestamp: new Date().toISOString() });
});

const generalLimiter = rateLimit({
  // @ts-ignore - RedisStore type compatibility
  store: new RedisStore({
    // @ts-ignore
    sendCommand: (...args: string[]) => redis.call(...args),
    prefix: 'rl:api:'
  }),
  windowMs: 60 * 1000,
  max: 100,
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false
});

const authLimiter = rateLimit({
  // @ts-ignore - RedisStore type compatibility
  store: new RedisStore({
    // @ts-ignore
    sendCommand: (...args: string[]) => redis.call(...args),
    prefix: 'rl:auth:'
  }),
  windowMs: 60 * 1000,
  max: 20,
  message: 'Too many authentication attempts, please try again later.',
  skipSuccessfulRequests: true
});

const services = {
  auth: process.env.AUTH_SERVICE_URL || 'http://auth-service:3001',
  gallery: process.env.GALLERY_SERVICE_URL || 'http://gallery-service:3002',
  inventory: process.env.INVENTORY_SERVICE_URL || 'http://inventory-service:3003',
  offer: process.env.OFFER_SERVICE_URL || 'http://offer-service:3004',
  chat: process.env.CHAT_SERVICE_URL || 'http://chat-service:3005',
  channel: process.env.CHANNEL_SERVICE_URL || 'http://channel-connector:3006'
};

// ===== PUBLIC ROUTES (No auth required) =====

// Auth service routes - No body parsing needed, proxy handles raw body
app.use('/api/v1/auth', authLimiter);
app.use('/api/v1/auth', createProxyMiddleware({
  target: services.auth,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/auth': '/auth' },
  timeout: 30000,
  proxyTimeout: 30000,
  onError: (err, req, res) => {
    logger.error('Auth service proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Auth service unavailable' });
    }
  }
}));

// Config routes (PUBLIC - splash is public, updates require auth)
app.use('/api/v1/config', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/config': '/config' },
  onError: (err, req, res) => {
    logger.error('Config proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Config service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    // Pass user headers if available (for super admin updates)
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Marketplace routes (PUBLIC - but add user headers if authenticated)
app.use('/api/v1/marketplace', express.json());
// Optional auth - don't fail if no token, just set user if available
app.use('/api/v1/marketplace', async (req: any, res, next) => {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    try {
      const jwt = require('jsonwebtoken');
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key-change-in-production') as any;
      req.user = decoded;
    } catch (err: any) {
      // Token invalid or expired - continue without user
    }
  }
  next();
});
app.use('/api/v1/marketplace', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/marketplace': '/marketplace' },
  onError: (err, req, res) => {
    logger.error('Marketplace proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Marketplace service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    // Add user headers if authenticated
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Catalog routes (PUBLIC - for vehicle brand/model/engine data)
app.use('/api/v1/catalog', express.json());
app.use('/api/v1/catalog', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/catalog': '/catalog' },
  onError: (err, req, res) => {
    logger.error('Catalog proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Catalog service unavailable' });
    }
  },
  onProxyReq: fixRequestBody
}));

// Banners routes (PUBLIC - for mobile app home screen)
app.use('/api/v1/banners', express.json());
app.use('/api/v1/banners', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/banners': '/banners' },
  onError: (err, req, res) => {
    logger.error('Banners proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Banners service unavailable' });
    }
  },
  onProxyReq: fixRequestBody
}));

// Shorts routes (PUBLIC for GET, authenticated for POST/DELETE)
app.use('/api/v1/shorts', express.json());
// Optional auth - don't fail if no token, just set user if available
app.use('/api/v1/shorts', async (req: any, res, next) => {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    try {
      const jwt = require('jsonwebtoken');
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key-change-in-production') as any;
      req.user = decoded;
    } catch (err: any) {
      // Token invalid or expired - continue without user for GET requests
    }
  }
  next();
});
app.use('/api/v1/shorts', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/shorts': '/shorts' },
  onError: (err, req, res) => {
    logger.error('Shorts proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Shorts service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    // Add user headers if authenticated
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// ===== PROTECTED ROUTES (Auth required) =====
app.use('/api/v1', generalLimiter);
app.use('/api/v1', authMiddleware);
app.use('/api/v1', express.json());

// Vehicles (authenticated)
app.use('/api/v1/vehicles', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/vehicles': '/vehicles' },
  onError: (err, req, res) => {
    logger.error('Vehicles proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Inventory service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    // Add user info headers from authenticated request
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Gallery service - list and get single gallery
app.use('/api/v1/galleries', createProxyMiddleware({
  target: services.gallery,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/galleries': '/galleries' },
  onError: (err, req, res) => {
    logger.error('Gallery service proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Gallery service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Gallery service - my gallery and settings
app.use('/api/v1/gallery', createProxyMiddleware({
  target: services.gallery,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/gallery': '/galleries' },
  onError: (err, req, res) => {
    logger.error('Gallery service proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Gallery service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Dashboard (authenticated)
app.use('/api/v1/dashboard', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/dashboard': '/dashboard' },
  onError: (err, req, res) => {
    logger.error('Dashboard proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Dashboard service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Favorites (authenticated)
app.use('/api/v1/favorites', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/favorites': '/favorites' },
  onError: (err, req, res) => {
    logger.error('Favorites proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Favorites service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Notifications (authenticated)
app.use('/api/v1/notifications', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/notifications': '/notifications' },
  onError: (err, req, res) => {
    logger.error('Notifications proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Notifications service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Activity (authenticated)
app.use('/api/v1/activity', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/activity': '/activity' },
  onError: (err, req, res) => {
    logger.error('Activity proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Activity service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Reports (authenticated)
app.use('/api/v1/reports', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/reports': '/reports' },
  onError: (err, req, res) => {
    logger.error('Reports proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Reports service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Inventory service
app.use('/api/v1/inventory', createProxyMiddleware({
  target: services.inventory,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/inventory': '' },
  onError: (err, req, res) => {
    logger.error('Inventory service proxy error', { error: err.message });
    res.status(500).json({ error: 'Inventory service unavailable' });
  },
  onProxyReq: fixRequestBody
}));

// Chat service - supports both /chat and /chats
const chatProxyConfig = {
  target: services.chat,
  changeOrigin: true,
  onError: (err: any, req: any, res: any) => {
    logger.error('Chat service proxy error', { error: err.message });
    res.status(500).json({ error: 'Chat service unavailable' });
  },
  onProxyReq: (proxyReq: any, req: any, res: any) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
};

app.use('/api/v1/chat', createProxyMiddleware({
  ...chatProxyConfig,
  pathRewrite: { '^/api/v1/chat': '/chats' }
}));

app.use('/api/v1/chats', createProxyMiddleware({
  ...chatProxyConfig,
  pathRewrite: { '^/api/v1/chats': '/chats' }
}));

// Offer service (authenticated)
app.use('/api/v1/offers', createProxyMiddleware({
  target: services.offer,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/offers': '/offers' },
  onError: (err, req, res) => {
    logger.error('Offer service proxy error', { error: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'Offer service unavailable' });
    }
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Channel connector service
app.use('/api/v1/channels', createProxyMiddleware({
  target: services.channel,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/channels': '' },
  onError: (err, req, res) => {
    logger.error('Channel service proxy error', { error: err.message });
    res.status(500).json({ error: 'Channel service unavailable' });
  },
  onProxyReq: fixRequestBody
}));

// User service (self-service)
app.use('/api/v1/user', createProxyMiddleware({
  target: services.auth,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/user': '/users' },
  onError: (err, req, res) => {
    logger.error('User service proxy error', { error: err.message });
    res.status(500).json({ error: 'User service unavailable' });
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Users management (admin - for superadmin user management)
app.use('/api/v1/users', createProxyMiddleware({
  target: services.auth,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/users': '/users' },
  onError: (err, req, res) => {
    logger.error('Users management proxy error', { error: err.message });
    res.status(500).json({ error: 'User service unavailable' });
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Admin routes
app.use('/api/v1/admin', createProxyMiddleware({
  target: services.gallery,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/admin': '/admin' },
  onError: (err, req, res) => {
    logger.error('Admin service proxy error', { error: err.message });
    res.status(500).json({ error: 'Admin service unavailable' });
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// Contact
app.use('/api/v1/contact', createProxyMiddleware({
  target: services.gallery,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/contact': '/contact' },
  onError: (err, req, res) => {
    logger.error('Contact service proxy error', { error: err.message });
    res.status(500).json({ error: 'Contact service unavailable' });
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

// System routes
app.use('/api/v1/system', createProxyMiddleware({
  target: services.gallery,
  changeOrigin: true,
  pathRewrite: { '^/api/v1/system': '/system' },
  onError: (err, req, res) => {
    logger.error('System service proxy error', { error: err.message });
    res.status(500).json({ error: 'System service unavailable' });
  },
  onProxyReq: (proxyReq, req: any, res) => {
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '');
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '');
      proxyReq.setHeader('x-user-role', req.user.role || '');
    }
    fixRequestBody(proxyReq, req as any);
  }
}));

app.use(errorHandler);

process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  redis.quit();
  process.exit(0);
});

app.listen(PORT, () => {
  logger.info(`API Gateway started on port ${PORT}`);
});

