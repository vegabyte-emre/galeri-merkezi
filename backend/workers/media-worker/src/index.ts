import amqp from 'amqplib';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { MediaProcessingService } from './services/mediaProcessingService';

const QUEUE_NAME = 'media_processing_queue';

async function startWorker() {
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
    await channel.prefetch(5); // Process 5 media files at a time

    logger.info('Media worker started');

    const mediaService = new MediaProcessingService();

    channel.consume(QUEUE_NAME, async (msg) => {
      if (!msg) return;

      try {
        const job = JSON.parse(msg.content.toString());
        logger.info('Processing media', { mediaId: job.mediaId });

        await mediaService.processMedia(job);

        channel.ack(msg);
      } catch (error: any) {
        logger.error('Media processing failed', { error: error.message });
        channel.nack(msg, false, true);
      }
    });
  } catch (error: any) {
    logger.error('Failed to start media worker', { error: error.message });
    process.exit(1);
  }
}

startWorker();
















