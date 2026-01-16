import { Router } from 'express';
import { MediaController } from '../controllers/mediaController';

const router = Router();
const controller = new MediaController();

router.get('/:vehicleId', controller.list.bind(controller));
router.post('/:vehicleId/presigned-url', controller.getPresignedUrl.bind(controller));
router.post('/:vehicleId', controller.upload.bind(controller));
router.put('/:vehicleId/:mediaId', controller.update.bind(controller));
router.delete('/:vehicleId/:mediaId', controller.delete.bind(controller));
router.put('/:vehicleId/:mediaId/cover', controller.setCover.bind(controller));

export { router as mediaRoutes };

