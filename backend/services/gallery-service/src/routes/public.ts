import { Router, Request, Response } from 'express';
import { AdminController } from '../controllers/adminController';

const router = Router();
const controller = new AdminController();

// Async handler wrapper
const asyncHandler = (fn: (req: Request, res: Response) => Promise<any>) => 
  async (req: Request, res: Response) => {
    try {
      await fn(req, res);
    } catch (error: any) {
      res.status(error.statusCode || 500).json({ 
        success: false, 
        message: error.message || 'Internal server error' 
      });
    }
  };

// Public pricing plans endpoint (for landing page)
router.get('/pricing-plans', asyncHandler(controller.listPricingPlans.bind(controller)));

export { router as publicRoutes };
