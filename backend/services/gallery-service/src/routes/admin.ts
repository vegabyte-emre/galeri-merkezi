import { Router, Request, Response, NextFunction } from 'express';
import { AdminController } from '../controllers/adminController';

const router = Router();
const controller = new AdminController();

// Async handler wrapper
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => 
    Promise.resolve(fn(req, res, next)).catch(next);

// Dashboard
router.get('/dashboard', asyncHandler(controller.getDashboard.bind(controller)));

// Gallery management
router.get('/galleries', asyncHandler(controller.listGalleries.bind(controller)));
router.get('/galleries/:id', asyncHandler(controller.getGallery.bind(controller)));
router.put('/galleries/:id', asyncHandler(controller.updateGallery.bind(controller)));
router.post('/galleries/:id/approve', asyncHandler(controller.approveGallery.bind(controller)));
router.post('/galleries/:id/reject', asyncHandler(controller.rejectGallery.bind(controller)));
router.post('/galleries/:id/suspend', asyncHandler(controller.suspendGallery.bind(controller)));
router.post('/galleries/:id/activate', asyncHandler(controller.activateGallery.bind(controller)));

// User management
router.get('/users', asyncHandler(controller.listUsers.bind(controller)));
router.get('/users/:id', asyncHandler(controller.getUser.bind(controller)));
router.post('/users', asyncHandler(controller.createUser.bind(controller)));
router.put('/users/:id', asyncHandler(controller.updateUser.bind(controller)));
router.delete('/users/:id', asyncHandler(controller.deleteUser.bind(controller)));

// Settings
router.get('/settings', asyncHandler(controller.getSettings.bind(controller)));
router.put('/settings/general', asyncHandler(controller.updateGeneralSettings.bind(controller)));
router.put('/settings/security', asyncHandler(controller.updateSecuritySettings.bind(controller)));
router.put('/settings/notifications', asyncHandler(controller.updateNotificationSettings.bind(controller)));

// Analytics
router.get('/analytics', asyncHandler(controller.getAnalytics.bind(controller)));

// Subscriptions
router.get('/subscriptions', asyncHandler(controller.listSubscriptions.bind(controller)));
router.post('/subscriptions', asyncHandler(controller.createSubscription.bind(controller)));
router.put('/subscriptions/:id', asyncHandler(controller.updateSubscription.bind(controller)));
router.post('/subscriptions/:id/extend-trial', asyncHandler(controller.extendTrial.bind(controller)));

// Logs
router.get('/logs', asyncHandler(controller.getLogs.bind(controller)));
router.get('/logs/export', asyncHandler(controller.exportLogs.bind(controller)));

// System status
router.get('/system/status', asyncHandler(controller.getSystemStatus.bind(controller)));

// Roles & Permissions
router.get('/roles', asyncHandler(controller.listRoles.bind(controller)));
router.get('/roles/permissions', asyncHandler(controller.getPermissions.bind(controller)));
router.post('/roles', asyncHandler(controller.createRole.bind(controller)));
router.put('/roles/:id', asyncHandler(controller.updateRole.bind(controller)));
router.put('/roles/:id/permissions', asyncHandler(controller.updateRolePermissions.bind(controller)));
router.delete('/roles/:id', asyncHandler(controller.deleteRole.bind(controller)));

// Email templates
router.get('/email-templates', asyncHandler(controller.listEmailTemplates.bind(controller)));

// Backup
router.get('/backups', asyncHandler(controller.listBackups.bind(controller)));
router.post('/backups', asyncHandler(controller.createBackup.bind(controller)));
router.get('/backups/:id/download', asyncHandler(controller.downloadBackup.bind(controller)));
router.delete('/backups/:id', asyncHandler(controller.deleteBackup.bind(controller)));
router.put('/backups/schedule', asyncHandler(controller.updateBackupSchedule.bind(controller)));

// Integrations
router.get('/integrations', asyncHandler(controller.listIntegrations.bind(controller)));
router.post('/integrations', asyncHandler(controller.createIntegration.bind(controller)));
router.put('/integrations/:id', asyncHandler(controller.updateIntegration.bind(controller)));

// Oto Shorts
router.get('/oto-shorts', asyncHandler(controller.listOtoShorts.bind(controller)));
router.post('/oto-shorts/:id/approve', asyncHandler(controller.approveVideo.bind(controller)));
router.post('/oto-shorts/:id/reject', asyncHandler(controller.rejectVideo.bind(controller)));

// Splash config
router.get('/splash-config', asyncHandler(controller.getSplashConfig.bind(controller)));
router.put('/splash-config', asyncHandler(controller.updateSplashConfig.bind(controller)));

// Reports
router.get('/reports', asyncHandler(controller.getReports.bind(controller)));
router.post('/reports', asyncHandler(controller.generateReport.bind(controller)));
router.get('/reports/:id/download', asyncHandler(controller.downloadReport.bind(controller)));
router.get('/reports/export', asyncHandler(controller.exportReport.bind(controller)));

// Pricing Plans
router.get('/pricing-plans', asyncHandler(controller.adminListPricingPlans.bind(controller)));
router.post('/pricing-plans', asyncHandler(controller.createPricingPlan.bind(controller)));
router.put('/pricing-plans/:id', asyncHandler(controller.updatePricingPlan.bind(controller)));
router.delete('/pricing-plans/:id', asyncHandler(controller.deletePricingPlan.bind(controller)));

// Database Migrations
router.post('/run-migration', asyncHandler(controller.runMigration.bind(controller)));

export { router as adminRoutes };
















