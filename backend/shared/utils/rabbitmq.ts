import amqp from 'amqplib';
import { config } from '../config';
import { logger } from './logger';

let connection: amqp.Connection | null = null;
let channel: amqp.Channel | null = null;

export async function getRabbitMQConnection(): Promise<amqp.Connection> {
  if (!connection) {
    connection = await amqp.connect({
      hostname: config.rabbitmq.host,
      port: config.rabbitmq.port,
      username: config.rabbitmq.user,
      password: config.rabbitmq.password,
      vhost: config.rabbitmq.vhost
    });
    
    connection.on('error', (err) => {
      logger.error('RabbitMQ connection error', { error: err.message });
      connection = null;
    });
  }
  
  return connection;
}

export async function getRabbitMQChannel(): Promise<amqp.Channel> {
  if (!channel) {
    const conn = await getRabbitMQConnection();
    channel = await conn.createChannel();
  }
  
  return channel;
}

export async function publishToQueue(
  queueName: string,
  message: any,
  options?: amqp.Options.Publish
): Promise<boolean> {
  try {
    const ch = await getRabbitMQChannel();
    await ch.assertQueue(queueName, { durable: true });
    
    return ch.sendToQueue(
      queueName,
      Buffer.from(JSON.stringify(message)),
      options
    );
  } catch (error: any) {
    logger.error('Failed to publish message', { error: error.message, queueName });
    throw error;
  }
}

export async function closeRabbitMQ(): Promise<void> {
  if (channel) {
    await channel.close();
    channel = null;
  }
  if (connection) {
    await connection.close();
    connection = null;
  }
}
















