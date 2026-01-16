import { Router, Request, Response, NextFunction } from 'express';
import { FavoriteController } from '../controllers/favoriteController';

const router = Router();
const controller = new FavoriteController();

// Async handler wrapper
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

router.get('/', asyncHandler(controller.list.bind(controller)));
router.post('/:vehicleId', asyncHandler(controller.add.bind(controller)));
router.delete('/:vehicleId', asyncHandler(controller.remove.bind(controller)));

export { router as favoriteRoutes };
