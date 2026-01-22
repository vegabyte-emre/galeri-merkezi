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

  // Araç onaya gönderildiğinde - Superadmin'e bildirim
  async publishVehicleSubmittedForApproval(vehicleId: string, galleryId: string) {
    try {
      await publishToQueue('notifications_queue', {
        type: 'vehicle_submitted_for_approval',
        vehicleId,
        galleryId,
        targetRole: 'superadmin',
        title: 'Yeni Araç Onay Bekliyor',
        message: 'Bir galeri yeni araç onayı için başvurdu.'
      });
      logger.info('Vehicle submitted for approval event published', { vehicleId });
    } catch (error: any) {
      logger.error('Failed to publish vehicle submitted for approval event', { error: error.message });
    }
  }

  // Araç onaylandığında - Galeri sahibine bildirim
  async publishVehicleApproved(vehicleId: string, galleryId: string) {
    try {
      await publishToQueue('notifications_queue', {
        type: 'vehicle_approved',
        vehicleId,
        galleryId,
        title: 'Araç Onaylandı',
        message: 'Aracınız onaylandı ve Oto Pazarı\'nda yayınlandı.'
      });
      logger.info('Vehicle approved event published', { vehicleId });
    } catch (error: any) {
      logger.error('Failed to publish vehicle approved event', { error: error.message });
    }
  }

  // Araç reddedildiğinde - Galeri sahibine bildirim
  async publishVehicleRejected(vehicleId: string, galleryId: string, reason?: string) {
    try {
      await publishToQueue('notifications_queue', {
        type: 'vehicle_rejected',
        vehicleId,
        galleryId,
        title: 'Araç Reddedildi',
        message: `Aracınız reddedildi. Sebep: ${reason || 'Belirtilmedi'}`
      });
      logger.info('Vehicle rejected event published', { vehicleId });
    } catch (error: any) {
      logger.error('Failed to publish vehicle rejected event', { error: error.message });
    }
  }
}
















