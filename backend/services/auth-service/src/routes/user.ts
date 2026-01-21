import { Router } from 'express';
import { UserController } from '../controllers/userController';

const router = Router();
const controller = new UserController();

// Admin user management routes (superadmin only)
router.get('/', controller.listUsers.bind(controller));
router.post('/', controller.createUser.bind(controller));
router.put('/:id', controller.updateUser.bind(controller));
router.delete('/:id', controller.deleteUser.bind(controller));

// User self-service routes
router.get('/me', controller.getMe.bind(controller));
router.put('/me', controller.updateMe.bind(controller));
router.put('/change-password', controller.changePassword.bind(controller));
router.get('/sessions', controller.getSessions.bind(controller));
router.delete('/sessions/:id', controller.deleteSession.bind(controller));

export { router as userRoutes };
















