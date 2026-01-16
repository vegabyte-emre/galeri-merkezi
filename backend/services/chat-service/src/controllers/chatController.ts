import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError } from '@galeri/shared/utils/errors';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
  };
  io?: any;
}

// Helper function to extract user info from headers (passed by API Gateway)
function getUserFromHeaders(req: AuthenticatedRequest) {
  const userId = req.headers['x-user-id'] as string;
  const galleryId = req.headers['x-gallery-id'] as string;
  const userRole = req.headers['x-user-role'] as string;
  
  return {
    sub: userId || req.user?.sub,
    gallery_id: galleryId || req.user?.gallery_id,
    role: userRole
  };
}

export class ChatController {
  async listRooms(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const result = await query(
      `SELECT 
        cr.*,
        ga.name as gallery_a_name,
        gb.name as gallery_b_name,
        v.brand as vehicle_brand,
        v.model as vehicle_model,
        v.base_price as vehicle_price,
        CONCAT(v.brand, ' ', v.model) as vehicle_title,
        (SELECT COUNT(*) FROM chat_messages cm 
         WHERE cm.room_id = cr.id 
         AND cm.sender_id != $1 
         AND cm.read_at IS NULL) as unread_count
       FROM chat_rooms cr
       LEFT JOIN galleries ga ON cr.gallery_a_id = ga.id
       LEFT JOIN galleries gb ON cr.gallery_b_id = gb.id
       LEFT JOIN vehicles v ON cr.vehicle_id = v.id
       WHERE (cr.gallery_a_id = $1 OR cr.gallery_b_id = $1) AND cr.is_active = TRUE
       ORDER BY cr.last_message_at DESC NULLS LAST`,
      [galleryId]
    );

    res.json({
      success: true,
      data: result.rows
    });
  }

  async getRoom(req: AuthenticatedRequest, res: Response) {
    const { roomId } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const result = await query(
      `SELECT * FROM chat_rooms
       WHERE id = $1 AND (gallery_a_id = $2 OR gallery_b_id = $2)`,
      [roomId, galleryId]
    );

    if (result.rows.length === 0) {
      throw new ValidationError('Room not found');
    }

    // Get last messages
    const messagesResult = await query(
      `SELECT cm.*, u.first_name, u.last_name
       FROM chat_messages cm
       LEFT JOIN users u ON cm.sender_id = u.id
       WHERE cm.room_id = $1
       ORDER BY cm.created_at DESC
       LIMIT 50`,
      [roomId]
    );

    res.json({
      success: true,
      data: {
        ...result.rows[0],
        messages: messagesResult.rows.reverse()
      }
    });
  }

  async createRoom(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { roomType, offerId, vehicleId, otherGalleryId } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Check if room already exists
    let existingRoom;
    if (roomType === 'offer' && offerId) {
      existingRoom = await query(
        'SELECT id FROM chat_rooms WHERE offer_id = $1',
        [offerId]
      );
    } else if (roomType === 'vehicle' && vehicleId) {
      existingRoom = await query(
        'SELECT id FROM chat_rooms WHERE vehicle_id = $1',
        [vehicleId]
      );
    }

    if (existingRoom && existingRoom.rows.length > 0) {
      return res.json({
        success: true,
        data: { id: existingRoom.rows[0].id }
      });
    }

    // Determine gallery IDs
    let galleryAId = galleryId;
    let galleryBId = otherGalleryId;

    if (!galleryBId) {
      if (roomType === 'offer' && offerId) {
        const offerResult = await query(
          'SELECT seller_gallery_id, buyer_gallery_id FROM offers WHERE id = $1',
          [offerId]
        );
        if (offerResult.rows.length > 0) {
          const offer = offerResult.rows[0];
          galleryAId = offer.seller_gallery_id;
          galleryBId = offer.buyer_gallery_id;
        }
      } else if (roomType === 'vehicle' && vehicleId) {
        const vehicleResult = await query(
          'SELECT gallery_id FROM vehicles WHERE id = $1',
          [vehicleId]
        );
        if (vehicleResult.rows.length > 0) {
          galleryBId = vehicleResult.rows[0].gallery_id;
        }
      }
    }

    // Ensure galleryAId and galleryBId are different
    if (galleryAId === galleryBId) {
      throw new ValidationError('Cannot create room with same gallery IDs');
    }

    // Ensure current user's gallery is one of the galleries
    if (galleryAId !== galleryId && galleryBId !== galleryId) {
      throw new ValidationError('Current user gallery must be one of the room galleries');
    }

    const result = await query(
      `INSERT INTO chat_rooms (
        room_type, offer_id, vehicle_id, gallery_a_id, gallery_b_id, is_active
      ) VALUES ($1, $2, $3, $4, $5, TRUE)
      RETURNING *`,
      [roomType, offerId || null, vehicleId || null, galleryAId, galleryBId]
    );

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async getMessages(req: AuthenticatedRequest, res: Response) {
    const { roomId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Verify room access
    const roomResult = await query(
      'SELECT id FROM chat_rooms WHERE id = $1 AND (gallery_a_id = $2 OR gallery_b_id = $2)',
      [roomId, galleryId]
    );

    if (roomResult.rows.length === 0) {
      throw new ValidationError('Room not found');
    }

    const offset = (Number(page) - 1) * Number(limit);

    const result = await query(
      `SELECT cm.*, u.first_name, u.last_name
       FROM chat_messages cm
       LEFT JOIN users u ON cm.sender_id = u.id
       WHERE cm.room_id = $1
       ORDER BY cm.created_at DESC
       LIMIT $2 OFFSET $3`,
      [roomId, Number(limit), offset]
    );

    const countResult = await query(
      'SELECT COUNT(*) as total FROM chat_messages WHERE room_id = $1',
      [roomId]
    );

    res.json({
      success: true,
      data: result.rows.reverse(),
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: parseInt(countResult.rows[0].total),
        totalPages: Math.ceil(parseInt(countResult.rows[0].total) / Number(limit))
      }
    });
  }

  async sendMessage(req: AuthenticatedRequest, res: Response) {
    const { roomId } = req.params;
    const { content, messageType = 'text', metadata } = req.body;
    const userInfo = getUserFromHeaders(req);
    const userId = userInfo.sub;
    const galleryId = userInfo.gallery_id;

    if (!userId || !galleryId) {
      throw new ValidationError('User information not found');
    }

    // Verify room access
    const roomResult = await query(
      'SELECT * FROM chat_rooms WHERE id = $1 AND (gallery_a_id = $2 OR gallery_b_id = $2)',
      [roomId, galleryId]
    );

    if (roomResult.rows.length === 0) {
      throw new ValidationError('Room not found');
    }

    const room = roomResult.rows[0];

    const result = await query(
      `INSERT INTO chat_messages (
        room_id, sender_id, message_type, content, metadata
      ) VALUES ($1, $2, $3, $4, $5)
      RETURNING *`,
      [roomId, userId, messageType, content, metadata ? JSON.stringify(metadata) : null]
    );

    // Update room last message
    await query(
      `UPDATE chat_rooms 
       SET last_message_at = NOW(), 
           last_message_preview = LEFT($1, 100),
           updated_at = NOW()
       WHERE id = $2`,
      [content, roomId]
    );

    // Emit via WebSocket
    if (req.io) {
      const otherGalleryId = room.gallery_a_id === galleryId ? room.gallery_b_id : room.gallery_a_id;
      const messageData = {
        roomId,
        message: result.rows[0]
      };
      
      // Emit to gallery room (for notifications)
      req.io.to(`gallery:${otherGalleryId}`).emit('new_message', messageData);
      
      // Emit to chat room (for real-time updates)
      req.io.to(`room:${roomId}`).emit('new_message', messageData);
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async markAllRead(req: AuthenticatedRequest, res: Response) {
    const { roomId } = req.params;
    const userInfo = getUserFromHeaders(req);
    const userId = userInfo.sub;
    const galleryId = userInfo.gallery_id;

    if (!userId || !galleryId) {
      throw new ValidationError('User information not found');
    }

    // Verify room access
    const roomResult = await query(
      'SELECT id FROM chat_rooms WHERE id = $1 AND (gallery_a_id = $2 OR gallery_b_id = $2)',
      [roomId, galleryId]
    );

    if (roomResult.rows.length === 0) {
      throw new ValidationError('Room not found');
    }

    // Karşı tarafın mesajlarını okundu işaretle
    await query(
      `UPDATE chat_messages 
       SET read_at = NOW(), read_by = $1
       WHERE room_id = $2 AND sender_id != $1 AND read_at IS NULL`,
      [userId, roomId]
    );

    res.json({
      success: true,
      message: 'All messages marked as read'
    });
  }

  async markRead(req: AuthenticatedRequest, res: Response) {
    const { roomId, id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const userId = userInfo.sub;
    const galleryId = userInfo.gallery_id;

    if (!userId || !galleryId) {
      throw new ValidationError('User information not found');
    }

    // Verify room access
    const roomResult = await query(
      'SELECT id FROM chat_rooms WHERE id = $1 AND (gallery_a_id = $2 OR gallery_b_id = $2)',
      [roomId, galleryId]
    );

    if (roomResult.rows.length === 0) {
      throw new ValidationError('Room not found');
    }

    await query(
      `UPDATE chat_messages 
       SET read_at = NOW(), read_by = $1
       WHERE id = $2 AND room_id = $3`,
      [userId, id, roomId]
    );

    res.json({
      success: true,
      message: 'Message marked as read'
    });
  }

  async uploadFile(req: AuthenticatedRequest, res: Response) {
    const { roomId } = req.params;
    const { fileUrl, fileName, fileSize, fileType } = req.body;
    const userInfo = getUserFromHeaders(req);
    const userId = userInfo.sub;
    const galleryId = userInfo.gallery_id;

    if (!userId || !galleryId) {
      throw new ValidationError('User information not found');
    }

    // Verify room access
    const roomResult = await query(
      'SELECT * FROM chat_rooms WHERE id = $1 AND (gallery_a_id = $2 OR gallery_b_id = $2)',
      [roomId, galleryId]
    );

    if (roomResult.rows.length === 0) {
      throw new ValidationError('Room not found');
    }

    const room = roomResult.rows[0];

    const result = await query(
      `INSERT INTO chat_messages (
        room_id, sender_id, message_type, file_url, file_name, file_size, file_type
      ) VALUES ($1, $2, 'file', $3, $4, $5, $6)
      RETURNING *`,
      [roomId, userId, fileUrl, fileName, fileSize, fileType]
    );

    // Update room
    await query(
      `UPDATE chat_rooms 
       SET last_message_at = NOW(), 
           last_message_preview = $1,
           updated_at = NOW()
       WHERE id = $2`,
      [`File: ${fileName}`, roomId]
    );

    // Emit via WebSocket
    if (req.io) {
      const otherGalleryId = room.gallery_a_id === galleryId ? room.gallery_b_id : room.gallery_a_id;
      req.io.to(`gallery:${otherGalleryId}`).emit('new_message', {
        roomId,
        message: result.rows[0]
      });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async deleteRoom(req: AuthenticatedRequest, res: Response) {
    const { roomId } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Verify room access
    const roomResult = await query(
      'SELECT * FROM chat_rooms WHERE id = $1 AND (gallery_a_id = $2 OR gallery_b_id = $2)',
      [roomId, galleryId]
    );

    if (roomResult.rows.length === 0) {
      throw new ValidationError('Room not found');
    }

    // Soft delete: Mark room as archived instead of hard delete
    await query(
      `UPDATE chat_rooms 
       SET is_active = FALSE, 
           updated_at = NOW()
       WHERE id = $1`,
      [roomId]
    );

    // Optionally, you can also delete messages
    // await query('DELETE FROM chat_messages WHERE room_id = $1', [roomId]);

    res.json({
      success: true,
      message: 'Room deleted successfully'
    });
  }
}






