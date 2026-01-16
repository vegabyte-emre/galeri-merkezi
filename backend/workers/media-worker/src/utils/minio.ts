import { Client } from 'minio';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';

export class MinIOClient {
  private client: Client;

  constructor() {
    this.client = new Client({
      endPoint: config.minio.endpoint,
      port: config.minio.port,
      useSSL: config.minio.useSSL,
      accessKey: config.minio.accessKey,
      secretKey: config.minio.secretKey
    });
  }

  async upload(fileName: string, buffer: Buffer, contentType: string): Promise<string> {
    try {
      await this.client.putObject(
        config.minio.bucket,
        fileName,
        buffer,
        buffer.length,
        {
          'Content-Type': contentType
        }
      );

      const url = `${config.minio.useSSL ? 'https' : 'http'}://${config.minio.endpoint}:${config.minio.port}/${config.minio.bucket}/${fileName}`;
      return url;
    } catch (error: any) {
      logger.error('MinIO upload failed', { error: error.message, fileName });
      throw error;
    }
  }

  async download(url: string): Promise<Buffer> {
    try {
      const objectName = url.split('/').pop() || '';
      const dataStream = await this.client.getObject(config.minio.bucket, objectName);
      
      const chunks: Buffer[] = [];
      for await (const chunk of dataStream) {
        chunks.push(chunk);
      }

      return Buffer.concat(chunks);
    } catch (error: any) {
      logger.error('MinIO download failed', { error: error.message, url });
      throw error;
    }
  }

  async delete(url: string): Promise<void> {
    try {
      const objectName = url.split('/').pop() || '';
      await this.client.removeObject(config.minio.bucket, objectName);
    } catch (error: any) {
      logger.error('MinIO delete failed', { error: error.message, url });
      throw error;
    }
  }
}
















