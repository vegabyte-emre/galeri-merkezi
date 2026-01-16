import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '@galeri/shared/config';
import { UnauthorizedError, ForbiddenError } from '@galeri/shared/utils/errors';
import { JWTPayload } from '@galeri/shared/types';

export interface AuthenticatedRequest extends Request {
  user?: JWTPayload;
}

export function authMiddleware(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  // Skip authentication for public routes
  const publicRoutes = [
    '/api/v1/auth/register',
    '/api/v1/auth/login',
    '/api/v1/auth/register/verify-phone',
    '/api/v1/auth/register/resend-otp',
    '/api/v1/auth/forgot-password',
    '/api/v1/auth/reset-password',
    '/health'
  ];

  if (publicRoutes.some(route => req.path.startsWith(route))) {
    return next();
  }

  // Get token from header
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new UnauthorizedError('No token provided');
  }

  const token = authHeader.substring(7);

  try {
    // Verify token
    const decoded = jwt.verify(token, config.jwt.secret) as JWTPayload;
    req.user = decoded;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new UnauthorizedError('Token expired');
    }
    if (error instanceof jwt.JsonWebTokenError) {
      throw new UnauthorizedError('Invalid token');
    }
    throw new UnauthorizedError('Authentication failed');
  }
}

export function requireRole(...roles: string[]) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new UnauthorizedError('Authentication required');
    }

    if (!roles.includes(req.user.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }

    next();
  };
}

export function requireGallery() {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new UnauthorizedError('Authentication required');
    }

    if (!req.user.gallery_id) {
      throw new ForbiddenError('Gallery context required');
    }

    next();
  };
}
















