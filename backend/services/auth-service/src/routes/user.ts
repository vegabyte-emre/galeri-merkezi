import { Router, Request, Response, NextFunction } from 'express';
import { UserController } from '../controllers/userController';

const router = Router();
const controller = new UserController();

// Async handler wrapper - catches errors and passes to error handler
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

// Admin user management routes (superadmin/admin only)
router.get('/', asyncHandler(controller.listUsers.bind(controller)));
router.post('/', asyncHandler(controller.createUser.bind(controller)));
router.put('/:id', asyncHandler(controller.updateUser.bind(controller)));
router.delete('/:id', asyncHandler(controller.deleteUser.bind(controller)));

// User self-service routes
router.get('/me', asyncHandler(controller.getMe.bind(controller)));
router.put('/me', asyncHandler(controller.updateMe.bind(controller)));
router.put('/change-password', asyncHandler(controller.changePassword.bind(controller)));
router.get('/sessions', asyncHandler(controller.getSessions.bind(controller)));
router.delete('/sessions/:id', asyncHandler(controller.deleteSession.bind(controller)));

export { router as userRoutes };
















