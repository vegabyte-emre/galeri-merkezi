import { Server, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { query } from '@galeri/shared/database/connection';
import { JWTPayload } from '@galeri/shared/types';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  galleryId?: string;
}

// Helper to get gallery_id from database if not in token
async function getGalleryIdForUser(userId: string): Promise<string | null> {
  try {
    const result = await query('SELECT gallery_id FROM users WHERE id = $1', [userId]);
    if (result.rows.length > 0 && result.rows[0].gallery_id) {
      return result.rows[0].gallery_id;
    }
  } catch (error) {
    logger.error('Error fetching gallery_id for user', { userId, error });
  }
  return null;
}

export function setupWebSocket(io: Server) {
  // Authentication middleware
  io.use(async (socket: AuthenticatedSocket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        logger.warn('WebSocket auth failed: no token');
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, config.jwt.secret) as JWTPayload;
      socket.userId = decoded.sub;
      
      // Get gallery_id from token or database
      socket.galleryId = decoded.gallery_id;
      if (!socket.galleryId && socket.userId) {
        socket.galleryId = await getGalleryIdForUser(socket.userId) || undefined;
        logger.info('Gallery ID fetched from database', { userId: socket.userId, galleryId: socket.galleryId });
      }

      logger.info('WebSocket auth successful', { userId: socket.userId, galleryId: socket.galleryId });
      next();
    } catch (error: any) {
      logger.error('WebSocket auth error', { error: error.message });
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket: AuthenticatedSocket) => {
    logger.info('WebSocket connection established', {
      userId: socket.userId,
      galleryId: socket.galleryId,
      socketId: socket.id
    });

    // Join gallery room for notifications
    if (socket.galleryId) {
      socket.join(`gallery:${socket.galleryId}`);
      logger.info('User joined gallery room', { galleryId: socket.galleryId });
    } else {
      logger.warn('User has no gallery_id, cannot join gallery room', { userId: socket.userId });
    }

    // Join chat room
    socket.on('join_room', async (roomId: string) => {
      logger.info('Join room request', { userId: socket.userId, galleryId: socket.galleryId, roomId });
      
      try {
        // Verify room access - check if user's gallery is part of this room
        const roomResult = await query(
          'SELECT id, gallery_a_id, gallery_b_id FROM chat_rooms WHERE id = $1 AND (gallery_a_id = $2 OR gallery_b_id = $2)',
          [roomId, socket.galleryId]
        );

        if (roomResult.rows.length > 0) {
          socket.join(`room:${roomId}`);
          logger.info('User successfully joined room', { userId: socket.userId, roomId });
          // Confirm join to client
          socket.emit('room_joined', { roomId, success: true });
        } else {
          logger.warn('Room access denied', { userId: socket.userId, roomId, galleryId: socket.galleryId });
          socket.emit('room_joined', { roomId, success: false, error: 'Access denied' });
        }
      } catch (error: any) {
        logger.error('Error joining room', { error: error.message, roomId });
        socket.emit('room_joined', { roomId, success: false, error: 'Server error' });
      }
    });

    // Leave chat room
    socket.on('leave_room', (roomId: string) => {
      socket.leave(`room:${roomId}`);
      logger.info('User left room', { userId: socket.userId, roomId });
    });

    // Typing indicator
    socket.on('typing_start', (data: { roomId: string }) => {
      socket.to(`room:${data.roomId}`).emit('user_typing', {
        userId: socket.userId,
        roomId: data.roomId
      });
    });

    socket.on('typing_stop', (data: { roomId: string }) => {
      socket.to(`room:${data.roomId}`).emit('user_stopped_typing', {
        userId: socket.userId,
        roomId: data.roomId
      });
    });

    // Disconnect
    socket.on('disconnect', () => {
      logger.info('WebSocket disconnect', {
        userId: socket.userId,
        socketId: socket.id
      });
    });
  });
}
















