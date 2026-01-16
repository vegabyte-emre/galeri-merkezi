import { publishToQueue } from '@galeri/shared/utils/rabbitmq';
import { logger } from '@galeri/shared/utils/logger';

export class EventPublisher {
  async publishVehicleCreated(vehicleId: string) {
    try {
      await publishToQueue('search_index_queue', {
        vehicleId,
        action: 'index'
      });
      logger.info('Vehicle created event published', { vehicleId });
    } catch (error: any) {
      logger.error('Failed to publish vehicle created event', { error: error.message });
    }
  }

  async publishVehicleUpdated(vehicleId: string) {
    try {
      await publishToQueue('search_index_queue', {
        vehicleId,
        action: 'index'
      });
      await publishToQueue('channel_sync_queue', {
        vehicleId,
        action: 'update'
      });
      logger.info('Vehicle updated event published', { vehicleId });
    } catch (error: any) {
      logger.error('Failed to publish vehicle updated event', { error: error.message });
    }
  }

  async publishVehiclePublished(vehicleId: string) {
    try {
      await publishToQueue('search_index_queue', {
        vehicleId,
        action: 'index'
      });
      await publishToQueue('channel_sync_queue', {
        vehicleId,
        action: 'create'
      });
      logger.info('Vehicle published event published', { vehicleId });
    } catch (error: any) {
      logger.error('Failed to publish vehicle published event', { error: error.message });
    }
  }

  async publishMediaProcessing(mediaId: string, vehicleId: string, type: string, originalUrl: string) {
    try {
      await publishToQueue('media_processing_queue', {
        mediaId,
        vehicleId,
        type,
        originalUrl
      });
      logger.info('Media processing event published', { mediaId });
    } catch (error: any) {
      logger.error('Failed to publish media processing event', { error: error.message });
    }
  }
}
















