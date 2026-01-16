import { MeiliSearch } from 'meilisearch';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { query } from '@galeri/shared/database/connection';

const INDEX_NAME = 'vehicles';

export class SearchIndexService {
  private client: MeiliSearch;

  constructor() {
    this.client = new MeiliSearch({
      host: config.meilisearch.host,
      apiKey: config.meilisearch.masterKey
    });
  }

  async indexVehicle(vehicleId: string) {
    try {
      // Get vehicle data
      const result = await query(
        `SELECT v.*, g.name as gallery_name, g.city, g.district,
                vm.thumbnail_url as cover_image
         FROM vehicles v
         JOIN galleries g ON v.gallery_id = g.id
         LEFT JOIN vehicle_media vm ON v.id = vm.vehicle_id AND vm.is_cover = TRUE
         WHERE v.id = $1 AND v.status = 'published'`,
        [vehicleId]
      );

      if (result.rows.length === 0) {
        logger.warn('Vehicle not found or not published', { vehicleId });
        return;
      }

      const vehicle = result.rows[0];

      // Transform to search document
      const document = {
        id: vehicle.id,
        listing_no: vehicle.listing_no,
        brand: vehicle.brand,
        series: vehicle.series,
        model: vehicle.model,
        year: vehicle.year,
        fuel_type: vehicle.fuel_type,
        transmission: vehicle.transmission,
        body_type: vehicle.body_type,
        engine_power: vehicle.engine_power,
        engine_cc: vehicle.engine_cc,
        drivetrain: vehicle.drivetrain,
        color: vehicle.color,
        vehicle_condition: vehicle.vehicle_condition,
        mileage: vehicle.mileage,
        has_warranty: vehicle.has_warranty,
        heavy_damage_record: vehicle.heavy_damage_record,
        base_price: parseFloat(vehicle.base_price || 0),
        currency: vehicle.currency,
        description: vehicle.description,
        gallery_id: vehicle.gallery_id,
        gallery_name: vehicle.gallery_name,
        city: vehicle.city,
        district: vehicle.district,
        cover_image: vehicle.cover_image,
        published_at: vehicle.published_at
      };

      // Index in Meilisearch
      const index = this.client.index(INDEX_NAME);
      await index.addDocuments([document]);

      logger.info('Vehicle indexed', { vehicleId });
    } catch (error: any) {
      logger.error('Vehicle indexing failed', { error: error.message, vehicleId });
      throw error;
    }
  }

  async deleteVehicle(vehicleId: string) {
    try {
      const index = this.client.index(INDEX_NAME);
      await index.deleteDocument(vehicleId);

      logger.info('Vehicle deleted from index', { vehicleId });
    } catch (error: any) {
      logger.error('Vehicle deletion from index failed', { error: error.message, vehicleId });
      throw error;
    }
  }

  async initializeIndex() {
    try {
      const index = this.client.index(INDEX_NAME);

      // Configure searchable attributes
      await index.updateSearchableAttributes([
        'brand',
        'series',
        'model',
        'description',
        'gallery_name',
        'city'
      ]);

      // Configure filterable attributes
      await index.updateFilterableAttributes([
        'gallery_id',
        'status',
        'brand',
        'fuel_type',
        'transmission',
        'body_type',
        'city',
        'year',
        'mileage',
        'base_price',
        'has_warranty',
        'heavy_damage_record'
      ]);

      // Configure sortable attributes
      await index.updateSortableAttributes([
        'base_price',
        'year',
        'mileage',
        'published_at'
      ]);

      logger.info('Search index initialized');
    } catch (error: any) {
      logger.error('Index initialization failed', { error: error.message });
      throw error;
    }
  }
}
















