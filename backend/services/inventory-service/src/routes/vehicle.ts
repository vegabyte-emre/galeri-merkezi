import { Router, Request, Response } from 'express';
import { VehicleController } from '../controllers/vehicleController';
import { query } from '@galeri/shared/database/connection';

const router = Router();
const controller = new VehicleController();

// List vehicles - uses gallery_id from headers for filtering
router.get('/', controller.list.bind(controller));

// Get my vehicles (mobile app compatibility)
router.get('/my', async (req: Request, res: Response) => {
  try {
    const galleryId = req.headers['x-gallery-id'] as string;
    const { status, sort = 'created_at', order = 'desc', limit = 50, skip = 0 } = req.query;
    
    if (!galleryId) {
      return res.status(400).json({ success: false, message: 'Gallery ID not found' });
    }
    
    let whereClause = 'WHERE gallery_id = $1';
    const params: any[] = [galleryId];
    let paramCount = 2;
    
    if (status) {
      whereClause += ` AND status = $${paramCount}`;
      params.push(status);
      paramCount++;
    }
    
    const validSortFields = ['created_at', 'updated_at', 'base_price', 'year', 'mileage'];
    const sortField = validSortFields.includes(sort as string) ? sort : 'created_at';
    const sortOrder = order === 'asc' ? 'ASC' : 'DESC';
    
    const result = await query(
      `SELECT v.*, 
              (SELECT url FROM vehicle_media WHERE vehicle_id = v.id AND type = 'image' ORDER BY sort_order LIMIT 1) as cover_image_url
       FROM vehicles v 
       ${whereClause}
       ORDER BY ${sortField} ${sortOrder}
       LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, Number(limit), Number(skip)]
    );
    
    const countResult = await query(
      `SELECT COUNT(*) as total FROM vehicles ${whereClause}`,
      params
    );
    
    res.json({
      success: true,
      data: result.rows,
      pagination: {
        total: parseInt(countResult.rows[0].total),
        limit: Number(limit),
        skip: Number(skip)
      }
    });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/search', controller.search.bind(controller));
router.get('/pending-approval', controller.listPendingApproval.bind(controller)); // Superadmin: Onay bekleyenler
router.get('/:id', controller.get.bind(controller));
router.post('/', controller.create.bind(controller));
router.put('/:id', controller.update.bind(controller));
router.delete('/:id', controller.delete.bind(controller));
router.post('/:id/publish', controller.publish.bind(controller));
router.post('/:id/pause', controller.pause.bind(controller));
router.post('/:id/archive', controller.archive.bind(controller));
router.post('/:id/sold', controller.markSold.bind(controller));
router.post('/:id/submit-approval', controller.submitForApproval.bind(controller)); // Galeri: Onaya gönder
router.post('/:id/approve', controller.approve.bind(controller)); // Superadmin: Onayla
router.post('/:id/reject', controller.reject.bind(controller)); // Superadmin: Reddet

// View tracking
router.post('/:id/view', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await query('UPDATE vehicles SET view_count = COALESCE(view_count, 0) + 1 WHERE id = $1', [id]);
    res.json({ success: true });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Unpublish vehicle
router.post('/:id/unpublish', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const galleryId = req.headers['x-gallery-id'] as string;
    
    await query(
      `UPDATE vehicles SET status = 'draft' WHERE id = $1 AND gallery_id = $2`,
      [id, galleryId]
    );
    res.json({ success: true, message: 'Vehicle unpublished' });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

export { router as vehicleRoutes };
















