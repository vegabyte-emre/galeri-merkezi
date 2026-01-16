import { Router } from 'express';
import { ChannelListingController } from '../controllers/channelListingController';

const router = Router();
const controller = new ChannelListingController();

router.get('/:vehicleId', controller.list.bind(controller));
router.post('/:vehicleId/:channelId', controller.create.bind(controller));
router.put('/:vehicleId/:channelId', controller.update.bind(controller));
router.delete('/:vehicleId/:channelId', controller.delete.bind(controller));
router.post('/:vehicleId/:channelId/sync', controller.sync.bind(controller));

export { router as channelRoutes };
















