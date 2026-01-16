import { Router, Request, Response, NextFunction } from 'express';
import { ReportController } from '../controllers/reportController';

const router = Router();
const controller = new ReportController();

// Async handler wrapper
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

router.get('/sales', asyncHandler(controller.getSalesReport.bind(controller)));
router.get('/inventory', asyncHandler(controller.getInventoryReport.bind(controller)));
router.get('/offers', asyncHandler(controller.getOfferReport.bind(controller)));

export { router as reportRoutes };
