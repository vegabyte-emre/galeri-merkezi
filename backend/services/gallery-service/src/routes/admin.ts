import { Router, Request, Response, NextFunction } from 'express';
import { AdminController } from '../controllers/adminController';

const router = Router();
const controller = new AdminController();

// Async handler wrapper
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

// Gallery management
router.get('/galleries', asyncHandler(controller.listGalleries.bind(controller)));
router.get('/galleries/:id', asyncHandler(controller.getGallery.bind(controller)));
router.put('/galleries/:id', asyncHandler(controller.updateGallery.bind(controller)));
router.post('/galleries/:id/approve', asyncHandler(controller.approveGallery.bind(controller)));
router.post('/galleries/:id/reject', asyncHandler(controller.rejectGallery.bind(controller)));
router.post('/galleries/:id/suspend', asyncHandler(controller.suspendGallery.bind(controller)));
router.post('/galleries/:id/activate', asyncHandler(controller.activateGallery.bind(controller)));

export { router as adminRoutes };
















