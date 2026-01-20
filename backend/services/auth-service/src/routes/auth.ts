import { Router, Request, Response, NextFunction } from 'express';
import { AuthController } from '../controllers/authController';

const router = Router();
const controller = new AuthController();

// Async handler wrapper - catches errors and passes to error handler
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

// Registration flow
router.post('/register', asyncHandler(controller.startRegistration.bind(controller)));
router.post('/register/verify-phone', asyncHandler(controller.verifyPhone.bind(controller)));
router.post('/register/resend-otp', asyncHandler(controller.resendOTP.bind(controller)));
router.post('/register/complete', asyncHandler(controller.completeRegistration.bind(controller)));

// Authentication
router.post('/login', asyncHandler(controller.login.bind(controller)));
router.post('/logout', asyncHandler(controller.logout.bind(controller)));
router.post('/refresh', asyncHandler(controller.refreshToken.bind(controller)));

// Password management
router.post('/forgot-password', asyncHandler(controller.forgotPassword.bind(controller)));
router.post('/reset-password', asyncHandler(controller.resetPassword.bind(controller)));

export { router as authRoutes };











