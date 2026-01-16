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

export function setupWebSocket(io: Server) {
  // Authentication middleware
  io.use(async (socket: AuthenticatedSocket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, config.jwt.secret) as JWTPayload;
      socket.userId = decoded.sub;
      socket.galleryId = decoded.gallery_id;

      next();
    } catch (error) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket: AuthenticatedSocket) => {
    logger.info('WebSocket connection', {
      userId: socket.userId,
      galleryId: socket.galleryId,
      socketId: socket.id
    });

    // Join gallery room
    if (socket.galleryId) {
      socket.join(`gallery:${socket.galleryId}`);
    }

    // Join chat room
    socket.on('join_room', async (roomId: string) => {
      // Verify room access
      const roomResult = await query(
        'SELECT id FROM chat_rooms WHERE id = $1 AND (gallery_a_id = $2 OR gallery_b_id = $2)',
        [roomId, socket.galleryId]
      );

      if (roomResult.rows.length > 0) {
        socket.join(`room:${roomId}`);
        logger.info('User joined room', { userId: socket.userId, roomId });
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
















