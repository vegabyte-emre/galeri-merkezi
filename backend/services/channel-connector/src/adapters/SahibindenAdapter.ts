import axios from 'axios';
import { BaseChannelAdapter, ChannelListing, ChannelCredentials } from './BaseChannelAdapter';
import { logger } from '@galeri/shared/utils/logger';

export class SahibindenAdapter extends BaseChannelAdapter {
  private apiBaseUrl = 'https://api.sahibinden.com/v1';

  async createListing(listing: ChannelListing): Promise<string> {
    await this.rateLimit();

    try {
      const mappedData = this.mapFields(listing.data);
      const transformedMedia = await this.transformMedia(listing.data.mediaUrls || []);

      const response = await axios.post(
        `${this.apiBaseUrl}/listings`,
        {
          ...mappedData,
          images: transformedMedia
        },
        {
          headers: {
            'Authorization': `Bearer ${this.credentials.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return response.data.listing_id;
    } catch (error: any) {
      return this.handleError(error, 'createListing');
    }
  }

  async updateListing(listing: ChannelListing): Promise<void> {
    await this.rateLimit();

    try {
      if (!listing.externalListingId) {
        throw new Error('External listing ID is required');
      }

      const mappedData = this.mapFields(listing.data);
      const transformedMedia = await this.transformMedia(listing.data.mediaUrls || []);

      await axios.put(
        `${this.apiBaseUrl}/listings/${listing.externalListingId}`,
        {
          ...mappedData,
          images: transformedMedia
        },
        {
          headers: {
            'Authorization': `Bearer ${this.credentials.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );
    } catch (error: any) {
      return this.handleError(error, 'updateListing');
    }
  }

  async deleteListing(externalListingId: string): Promise<void> {
    await this.rateLimit();

    try {
      await axios.delete(
        `${this.apiBaseUrl}/listings/${externalListingId}`,
        {
          headers: {
            'Authorization': `Bearer ${this.credentials.apiKey}`
          }
        }
      );
    } catch (error: any) {
      return this.handleError(error, 'deleteListing');
    }
  }

  async getListingStatus(externalListingId: string): Promise<string> {
    await this.rateLimit();

    try {
      const response = await axios.get(
        `${this.apiBaseUrl}/listings/${externalListingId}/status`,
        {
          headers: {
            'Authorization': `Bearer ${this.credentials.apiKey}`
          }
        }
      );

      return response.data.status;
    } catch (error: any) {
      return this.handleError(error, 'getListingStatus');
    }
  }

  mapFields(vehicleData: any): any {
    // Field mapping: Platform → Sahibinden
    const fieldMap: any = {
      marka: vehicleData.brand,
      seri: vehicleData.series,
      model: vehicleData.model,
      yil: vehicleData.year,
      yakit_tipi: this.mapFuelType(vehicleData.fuelType),
      vites: this.mapTransmission(vehicleData.transmission),
      km: vehicleData.mileage,
      fiyat: vehicleData.channelPrice || vehicleData.basePrice,
      aciklama: vehicleData.description
    };

    return fieldMap;
  }

  async transformMedia(mediaUrls: string[]): Promise<string[]> {
    // Sahibinden requires JPEG format, max 2MB
    // TODO: Implement media transformation via media worker
    return mediaUrls.slice(0, 20); // Limit to 20 images
  }

  private mapFuelType(fuelType: string): number {
    const map: Record<string, number> = {
      'benzin': 1,
      'dizel': 2,
      'lpg': 3,
      'elektrik': 4,
      'hibrit': 5
    };
    return map[fuelType] || 1;
  }

  private mapTransmission(transmission: string): number {
    const map: Record<string, number> = {
      'manuel': 1,
      'otomatik': 2,
      'yarı_otomatik': 3
    };
    return map[transmission] || 1;
  }
}
















