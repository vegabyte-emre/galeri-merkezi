import { Router, Request, Response, NextFunction } from 'express';
import { ActivityController } from '../controllers/activityController';

const router = Router();
const controller = new ActivityController();

// Async handler wrapper
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

router.get('/', asyncHandler(controller.list.bind(controller)));
router.get('/stats', asyncHandler(controller.getStats.bind(controller)));

export { router as activityRoutes };
