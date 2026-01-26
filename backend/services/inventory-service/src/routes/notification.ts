import { Router, Request, Response, NextFunction } from 'express';
import { NotificationController } from '../controllers/notificationController';

const router = Router();
const controller = new NotificationController();

// Async handler wrapper
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

router.get('/', asyncHandler(controller.list.bind(controller)));
router.get('/unread-count', asyncHandler(controller.getUnreadCount.bind(controller)));
router.post('/:id/read', asyncHandler(controller.markRead.bind(controller)));
router.put('/:id/read', asyncHandler(controller.markRead.bind(controller)));
router.post('/read-all', asyncHandler(controller.markAllRead.bind(controller)));
router.put('/read-all', asyncHandler(controller.markAllRead.bind(controller)));
router.post('/fcm/register', asyncHandler(controller.registerFCMToken.bind(controller)));
router.post('/fcm/unregister', asyncHandler(controller.unregisterFCMToken.bind(controller)));

export { router as notificationRoutes };
