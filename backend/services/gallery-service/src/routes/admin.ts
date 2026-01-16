import { Router } from 'express';
import { AdminController } from '../controllers/adminController';

const router = Router();
const controller = new AdminController();

// Gallery management
router.get('/galleries', controller.listGalleries.bind(controller));
router.get('/galleries/:id', controller.getGallery.bind(controller));
router.put('/galleries/:id', controller.updateGallery.bind(controller));
router.post('/galleries/:id/approve', controller.approveGallery.bind(controller));
router.post('/galleries/:id/reject', controller.rejectGallery.bind(controller));
router.post('/galleries/:id/suspend', controller.suspendGallery.bind(controller));
router.post('/galleries/:id/activate', controller.activateGallery.bind(controller));

export { router as adminRoutes };
















