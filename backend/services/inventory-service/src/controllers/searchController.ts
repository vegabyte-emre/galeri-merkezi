import { Request, Response } from 'express';
import { getMeilisearchClient } from '@galeri/shared/utils/meilisearch';
import { ValidationError } from '@galeri/shared/utils/errors';

export class SearchController {
  async search(req: Request, res: Response) {
    const { q, page = 1, limit = 20, filters, sort } = req.query;

    if (!q) {
      throw new ValidationError('Search query is required');
    }

    try {
      const client = getMeilisearchClient();
      const index = client.index('vehicles');

      const searchParams: any = {
        q: q as string,
        limit: Number(limit),
        offset: (Number(page) - 1) * Number(limit)
      };

      if (filters) {
        searchParams.filter = filters;
      }

      if (sort) {
        searchParams.sort = [sort as string];
      }

      const results = await index.search(q as string, searchParams);

      res.json({
        success: true,
        data: results.hits,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total: results.estimatedTotalHits || 0,
          totalPages: Math.ceil((results.estimatedTotalHits || 0) / Number(limit))
        },
        facets: results.facetDistribution
      });
    } catch (error: any) {
      throw new ValidationError(`Search failed: ${error.message}`);
    }
  }

  async getFilters(req: Request, res: Response) {
    try {
      const client = getMeilisearchClient();
      const index = client.index('vehicles');

      // Get facet distribution for filters
      const results = await index.search('', {
        limit: 0,
        facets: ['brand', 'fuel_type', 'transmission', 'body_type', 'city', 'year']
      });

      res.json({
        success: true,
        data: results.facetDistribution || {}
      });
    } catch (error: any) {
      throw new ValidationError(`Failed to get filters: ${error.message}`);
    }
  }
}
















