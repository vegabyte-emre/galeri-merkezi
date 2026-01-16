import { logger } from '@galeri/shared/utils/logger';

export interface ChannelListing {
  vehicleId: string;
  channelId: string;
  externalListingId?: string;
  data: any;
}

export interface ChannelCredentials {
  apiKey?: string;
  apiSecret?: string;
  username?: string;
  password?: string;
  [key: string]: any;
}

export abstract class BaseChannelAdapter {
  protected credentials: ChannelCredentials;
  protected rateLimitPerMinute: number;
  protected lastRequestTime: number = 0;
  protected requestQueue: Array<() => Promise<any>> = [];
  protected processing: boolean = false;

  constructor(credentials: ChannelCredentials, rateLimitPerMinute: number = 60) {
    this.credentials = credentials;
    this.rateLimitPerMinute = rateLimitPerMinute;
  }

  abstract createListing(listing: ChannelListing): Promise<string>;
  abstract updateListing(listing: ChannelListing): Promise<void>;
  abstract deleteListing(externalListingId: string): Promise<void>;
  abstract getListingStatus(externalListingId: string): Promise<string>;
  abstract mapFields(vehicleData: any): any;
  abstract transformMedia(mediaUrls: string[]): Promise<string[]>;

  protected async rateLimit(): Promise<void> {
    const now = Date.now();
    const timeSinceLastRequest = now - this.lastRequestTime;
    const minInterval = (60 * 1000) / this.rateLimitPerMinute;

    if (timeSinceLastRequest < minInterval) {
      const waitTime = minInterval - timeSinceLastRequest;
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }

    this.lastRequestTime = Date.now();
  }

  protected async handleError(error: any, operation: string): Promise<never> {
    logger.error(`Channel adapter error: ${operation}`, {
      error: error.message,
      stack: error.stack,
      channel: this.constructor.name
    });
    throw error;
  }
}
















