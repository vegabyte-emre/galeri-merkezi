import { Router } from 'express';
import { EIDSController } from '../controllers/eidsController';

const router = Router();
const controller = new EIDSController();

router.post('/initiate', controller.initiate.bind(controller));
router.post('/callback', controller.callback.bind(controller));
router.get('/status', controller.getStatus.bind(controller));

export { router as eidsRoutes };
















