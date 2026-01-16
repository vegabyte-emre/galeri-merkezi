import { Client } from 'minio';
import { config } from '../config';
import { logger } from './logger';

let minioClient: Client | null = null;

export function getMinIOClient(): Client {
  if (!minioClient) {
    minioClient = new Client({
      endPoint: config.minio.endpoint,
      port: config.minio.port,
      useSSL: config.minio.useSSL,
      accessKey: config.minio.accessKey,
      secretKey: config.minio.secretKey
    });
  }
  
  return minioClient;
}

export async function uploadFile(
  bucket: string,
  objectName: string,
  buffer: Buffer,
  contentType: string
): Promise<string> {
  try {
    const client = getMinIOClient();
    
    // Ensure bucket exists
    const exists = await client.bucketExists(bucket);
    if (!exists) {
      await client.makeBucket(bucket);
    }
    
    await client.putObject(bucket, objectName, buffer, buffer.length, {
      'Content-Type': contentType
    });
    
    const url = `${config.minio.useSSL ? 'https' : 'http'}://${config.minio.endpoint}:${config.minio.port}/${bucket}/${objectName}`;
    return url;
  } catch (error: any) {
    logger.error('MinIO upload failed', { error: error.message, bucket, objectName });
    throw error;
  }
}

export async function getPresignedUrl(
  bucket: string,
  objectName: string,
  expiry: number = 3600
): Promise<string> {
  try {
    const client = getMinIOClient();
    return await client.presignedPutObject(bucket, objectName, expiry);
  } catch (error: any) {
    logger.error('Failed to generate presigned URL', { error: error.message });
    throw error;
  }
}

