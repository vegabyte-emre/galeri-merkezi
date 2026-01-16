import amqp from 'amqplib';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { NotificationService } from './services/notificationService';

const QUEUE_NAME = 'notifications_queue';

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
    await channel.prefetch(10); // Process 10 messages at a time

    logger.info('Notification worker started');

    const notificationService = new NotificationService();

    channel.consume(QUEUE_NAME, async (msg) => {
      if (!msg) return;

      try {
        const notification = JSON.parse(msg.content.toString());
        logger.info('Processing notification', { notificationId: notification.id });

        await notificationService.sendNotification(notification);

        channel.ack(msg);
      } catch (error: any) {
        logger.error('Notification processing failed', { error: error.message });
        // Retry logic
        channel.nack(msg, false, true);
      }
    });
  } catch (error: any) {
    logger.error('Failed to start notification worker', { error: error.message });
    process.exit(1);
  }
}

startWorker();
















