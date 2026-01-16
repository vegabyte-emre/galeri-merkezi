import { Router } from 'express';
import { UserController } from '../controllers/userController';

const router = Router();
const controller = new UserController();

router.get('/me', controller.getMe.bind(controller));
router.put('/me', controller.updateMe.bind(controller));
router.put('/change-password', controller.changePassword.bind(controller));
router.get('/sessions', controller.getSessions.bind(controller));
router.delete('/sessions/:id', controller.deleteSession.bind(controller));

export { router as userRoutes };
















