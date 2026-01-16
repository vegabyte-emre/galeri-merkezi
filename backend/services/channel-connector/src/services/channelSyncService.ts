import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';
import { SahibindenAdapter } from '../adapters/SahibindenAdapter';
import { ArabamAdapter } from '../adapters/ArabamAdapter';
import { BaseChannelAdapter } from '../adapters/BaseChannelAdapter';

interface SyncJob {
  vehicleId: string;
  channelId: string;
  action: 'create' | 'update' | 'delete';
}

export class ChannelSyncService {
  async syncListing(job: SyncJob) {
    try {
      // Get channel listing data
      const listingResult = await query(
        `SELECT cl.*, v.*, c.adapter_type, c.api_base_url, gcc.credentials
         FROM channel_listings cl
         JOIN vehicles v ON cl.vehicle_id = v.id
         JOIN channels c ON cl.channel_id = c.id
         JOIN gallery_channel_credentials gcc ON cl.channel_id = gcc.channel_id AND v.gallery_id = gcc.gallery_id
         WHERE cl.vehicle_id = $1 AND cl.channel_id = $2`,
        [job.vehicleId, job.channelId]
      );

      if (listingResult.rows.length === 0) {
        throw new Error('Channel listing not found');
      }

      const listing = listingResult.rows[0];

      // Get adapter
      const adapter = this.getAdapter(listing.adapter_type, JSON.parse(listing.credentials));

      // Get media URLs
      const mediaResult = await query(
        'SELECT original_url FROM vehicle_media WHERE vehicle_id = $1 ORDER BY sort_order',
        [job.vehicleId]
      );
      const mediaUrls = mediaResult.rows.map((row: any) => row.original_url);

      // Prepare listing data
      const listingData = {
        ...listing,
        mediaUrls
      };

      // Execute action
      let externalListingId: string | undefined;

      if (job.action === 'create') {
        externalListingId = await adapter.createListing({
          vehicleId: job.vehicleId,
          channelId: job.channelId,
          data: listingData
        });

        // Update channel listing
        await query(
          `UPDATE channel_listings 
           SET external_listing_id = $1, status = 'active', last_sync_at = NOW(), last_sync_status = 'success'
           WHERE vehicle_id = $2 AND channel_id = $3`,
          [externalListingId, job.vehicleId, job.channelId]
        );
      } else if (job.action === 'update') {
        await adapter.updateListing({
          vehicleId: job.vehicleId,
          channelId: job.channelId,
          externalListingId: listing.external_listing_id,
          data: listingData
        });

        await query(
          `UPDATE channel_listings 
           SET last_sync_at = NOW(), last_sync_status = 'success'
           WHERE vehicle_id = $1 AND channel_id = $2`,
          [job.vehicleId, job.channelId]
        );
      } else if (job.action === 'delete') {
        if (listing.external_listing_id) {
          await adapter.deleteListing(listing.external_listing_id);
        }

        await query(
          `UPDATE channel_listings 
           SET status = 'removed', last_sync_at = NOW(), last_sync_status = 'success'
           WHERE vehicle_id = $1 AND channel_id = $2`,
          [job.vehicleId, job.channelId]
        );
      }

      logger.info('Channel sync completed', { job, externalListingId });
    } catch (error: any) {
      logger.error('Channel sync failed', { error: error.message, job });

      // Update status
      await query(
        `UPDATE channel_listings 
         SET status = 'error', last_sync_at = NOW(), last_sync_status = 'failed', last_error = $1
         WHERE vehicle_id = $2 AND channel_id = $3`,
        [error.message, job.vehicleId, job.channelId]
      );

      throw error;
    }
  }

  private getAdapter(adapterType: string, credentials: any): BaseChannelAdapter {
    switch (adapterType) {
      case 'SahibindenAdapter':
        return new SahibindenAdapter(credentials, 60);
      case 'ArabamAdapter':
        return new ArabamAdapter(credentials, 100);
      default:
        throw new Error(`Unknown adapter type: ${adapterType}`);
    }
  }
}
















