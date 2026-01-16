import { Router } from 'express';
import { UserController } from '../controllers/userController';

const router = Router();
const controller = new UserController();

router.get('/my', controller.getMyUsers.bind(controller));
router.post('/my', controller.createUser.bind(controller));
router.get('/my/:id', controller.getUser.bind(controller));
router.put('/my/:id', controller.updateUser.bind(controller));
router.delete('/my/:id', controller.deleteUser.bind(controller));

export { router as userRoutes };
















