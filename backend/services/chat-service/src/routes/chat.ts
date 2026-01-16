import { Router, Request, Response, NextFunction } from 'express';
import { ChatController } from '../controllers/chatController';

const router = Router();
const controller = new ChatController();

// Async handler wrapper - catches errors and passes to error handler
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

router.get('/', asyncHandler(controller.listRooms.bind(controller)));
router.get('/:roomId', asyncHandler(controller.getRoom.bind(controller)));
router.post('/', asyncHandler(controller.createRoom.bind(controller)));
router.delete('/:roomId', asyncHandler(controller.deleteRoom.bind(controller)));
router.get('/:roomId/messages', asyncHandler(controller.getMessages.bind(controller)));
router.post('/:roomId/messages', asyncHandler(controller.sendMessage.bind(controller)));
router.post('/:roomId/read', asyncHandler(controller.markAllRead.bind(controller)));
router.put('/:roomId/messages/:id/read', asyncHandler(controller.markRead.bind(controller)));
router.post('/:roomId/upload', asyncHandler(controller.uploadFile.bind(controller)));

export { router as chatRoutes };






