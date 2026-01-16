import { Router } from 'express';
import { VehicleController } from '../controllers/vehicleController';

const router = Router();
const controller = new VehicleController();

router.get('/', controller.list.bind(controller));
router.get('/search', controller.search.bind(controller));
router.get('/:id', controller.get.bind(controller));
router.post('/', controller.create.bind(controller));
router.put('/:id', controller.update.bind(controller));
router.delete('/:id', controller.delete.bind(controller));
router.post('/:id/publish', controller.publish.bind(controller));
router.post('/:id/pause', controller.pause.bind(controller));
router.post('/:id/archive', controller.archive.bind(controller));
router.post('/:id/sold', controller.markSold.bind(controller));

export { router as vehicleRoutes };
















