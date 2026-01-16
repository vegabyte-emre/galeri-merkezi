import { Router } from 'express';
import { SearchController } from '../controllers/searchController';

const router = Router();
const controller = new SearchController();

router.get('/', controller.search.bind(controller));
router.get('/filters', controller.getFilters.bind(controller));

export { router as searchRoutes };
















