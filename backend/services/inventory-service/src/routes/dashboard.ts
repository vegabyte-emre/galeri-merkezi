import { Router, Request, Response, NextFunction } from 'express';
import { DashboardController } from '../controllers/dashboardController';

const router = Router();
const controller = new DashboardController();

// Async handler wrapper
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

router.get('/', asyncHandler(controller.getStats.bind(controller)));

export { router as dashboardRoutes };
