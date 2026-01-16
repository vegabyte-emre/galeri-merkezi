import { getPresignedUrl } from '@galeri/shared/utils/minio';
import { config } from '@galeri/shared/config';
import { v4 as uuidv4 } from 'uuid';

export class PresignedUrlService {
  async generateUploadUrl(
    vehicleId: string,
    fileType: string,
    fileName: string
  ): Promise<{ uploadUrl: string; fileKey: string }> {
    const fileKey = `vehicles/${vehicleId}/${uuidv4()}-${fileName}`;
    const uploadUrl = await getPresignedUrl(
      config.minio.bucket,
      fileKey,
      3600 // 1 hour expiry
    );

    return {
      uploadUrl,
      fileKey
    };
  }
}
















