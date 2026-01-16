import { Router } from 'express';
import { ChannelController } from '../controllers/channelController';

const router = Router();
const controller = new ChannelController();

router.get('/my', controller.getMyChannels.bind(controller));
router.post('/my/:channelId/credentials', controller.setCredentials.bind(controller));
router.put('/my/:channelId/credentials', controller.updateCredentials.bind(controller));
router.delete('/my/:channelId/credentials', controller.deleteCredentials.bind(controller));
router.post('/my/:channelId/verify', controller.verifyCredentials.bind(controller));

export { router as channelRoutes };
















