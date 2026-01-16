import { Router } from 'express';
import { OfferController } from '../controllers/offerController';

const router = Router();
const controller = new OfferController();

// Get all offers (incoming + outgoing)
router.get('/', controller.getAll.bind(controller));

// Incoming offers
router.get('/incoming', controller.getIncoming.bind(controller));
router.get('/incoming/:id', controller.getIncomingOffer.bind(controller));

// Outgoing offers
router.get('/outgoing', controller.getOutgoing.bind(controller));
router.get('/outgoing/:id', controller.getOutgoingOffer.bind(controller));

// Offer operations
router.post('/', controller.create.bind(controller));
router.put('/:id', controller.update.bind(controller));
router.post('/:id/send', controller.send.bind(controller));
router.post('/:id/counter', controller.counter.bind(controller));
router.post('/:id/accept', controller.accept.bind(controller));
router.post('/:id/reject', controller.reject.bind(controller));
router.post('/:id/cancel', controller.cancel.bind(controller));
router.post('/:id/reserve', controller.reserve.bind(controller));
router.post('/:id/convert', controller.convert.bind(controller));

// History
router.get('/:id/history', controller.getHistory.bind(controller));

export { router as offerRoutes };






