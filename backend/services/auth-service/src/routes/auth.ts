import { Router, Request, Response, NextFunction } from 'express';
import { AuthController } from '../controllers/authController';
import { query } from '@galeri/shared/database/connection';

const router = Router();
const controller = new AuthController();

// Async handler wrapper - catches errors and passes to error handler
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

// Registration flow (web - multi-step)
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

// Get current user (for mobile app compatibility)
router.get('/me', asyncHandler(async (req: Request, res: Response) => {
  const userId = req.headers['x-user-id'] as string;
  
  if (!userId) {
    return res.status(401).json({ success: false, message: 'Unauthorized' });
  }

  const result = await query(
    `SELECT u.id, u.email, u.phone, u.first_name, u.last_name, u.avatar_url, u.role, u.gallery_id, u.status,
            g.name as gallery_name, g.logo_url as gallery_logo, g.city, g.status as gallery_status
     FROM users u
     LEFT JOIN galleries g ON u.gallery_id = g.id
     WHERE u.id = $1`,
    [userId]
  );

  if (result.rows.length === 0) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  const user = result.rows[0];
  
  res.json({
    success: true,
    data: {
      id: user.id,
      email: user.email,
      phone: user.phone,
      first_name: user.first_name,
      last_name: user.last_name,
      avatar_url: user.avatar_url,
      role: user.role,
      status: user.status,
      gallery_id: user.gallery_id,
      gallery_name: user.gallery_name,
      gallery_logo: user.gallery_logo,
      city: user.city,
      gallery_status: user.gallery_status
    }
  });
}));

// OTP verification for mobile (simplified)
router.post('/verify-otp', asyncHandler(async (req: Request, res: Response) => {
  const { phone, otp } = req.body;
  // Redirect to verify-phone endpoint
  return controller.verifyPhone(req, res);
}));

export { router as authRoutes };











