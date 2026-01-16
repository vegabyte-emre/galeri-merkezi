import { Router } from 'express';
import { GalleryController } from '../controllers/galleryController';

const router = Router();
const controller = new GalleryController();

// My gallery
router.get('/my', controller.getMyGallery.bind(controller));
router.put('/my', controller.updateMyGallery.bind(controller));
router.put('/my/logo', controller.uploadLogo.bind(controller));
router.put('/my/cover', controller.uploadCover.bind(controller));
router.get('/my/stats', controller.getMyGalleryStats.bind(controller));

// Settings
router.get('/settings', controller.getSettings.bind(controller));
router.put('/settings', controller.updateSettings.bind(controller));

export { router as galleryRoutes };
















