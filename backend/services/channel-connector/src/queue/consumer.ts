import amqp from 'amqplib';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { query } from '@galeri/shared/database/connection';
import { ChannelSyncService } from '../services/channelSyncService';

const QUEUE_NAME = 'channel_sync_queue';

export async function setupQueueConsumer() {
  try {
    const connection = await amqp.connect({
      hostname: config.rabbitmq.host,
      port: config.rabbitmq.port,
      username: config.rabbitmq.user,
      password: config.rabbitmq.password,
      vhost: config.rabbitmq.vhost
    });

    const channel = await connection.createChannel();
    await channel.assertQueue(QUEUE_NAME, { durable: true });

    logger.info('Channel sync queue consumer started');

    channel.consume(QUEUE_NAME, async (msg) => {
      if (!msg) return;

      try {
        const data = JSON.parse(msg.content.toString());
        logger.info('Processing channel sync job', { data });

        const syncService = new ChannelSyncService();
        await syncService.syncListing(data);

        channel.ack(msg);
      } catch (error: any) {
        logger.error('Channel sync job failed', { error: error.message });
        // Retry logic or send to DLQ
        channel.nack(msg, false, true);
      }
    });
  } catch (error: any) {
    logger.error('Failed to setup queue consumer', { error: error.message });
  }
}
















