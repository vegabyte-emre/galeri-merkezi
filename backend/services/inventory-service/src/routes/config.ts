import { Router, Request, Response, NextFunction } from 'express';
import { ConfigController } from '../controllers/configController';

const router = Router();
const controller = new ConfigController();

const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) =>
  (req: Request, res: Response, next: NextFunction) =>
    Promise.resolve(fn(req, res, next)).catch(next);

router.get('/splash', asyncHandler(controller.getSplashConfig.bind(controller)));
router.put('/splash', asyncHandler(controller.updateSplashConfig.bind(controller)));
router.get('/', asyncHandler(controller.getAllConfigs.bind(controller)));

export { router as configRoutes };
