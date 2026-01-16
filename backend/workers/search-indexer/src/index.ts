import amqp from 'amqplib';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { SearchIndexService } from './services/searchIndexService';

const QUEUE_NAME = 'search_index_queue';

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
    await channel.prefetch(10);

    logger.info('Search indexer started');

    const indexService = new SearchIndexService();

    channel.consume(QUEUE_NAME, async (msg) => {
      if (!msg) return;

      try {
        const job = JSON.parse(msg.content.toString());
        logger.info('Indexing vehicle', { vehicleId: job.vehicleId, action: job.action });

        if (job.action === 'index') {
          await indexService.indexVehicle(job.vehicleId);
        } else if (job.action === 'delete') {
          await indexService.deleteVehicle(job.vehicleId);
        }

        channel.ack(msg);
      } catch (error: any) {
        logger.error('Search indexing failed', { error: error.message });
        channel.nack(msg, false, true);
      }
    });
  } catch (error: any) {
    logger.error('Failed to start search indexer', { error: error.message });
    process.exit(1);
  }
}

startWorker();
















