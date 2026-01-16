import axios from 'axios';
import { BaseChannelAdapter, ChannelListing, ChannelCredentials } from './BaseChannelAdapter';

export class ArabamAdapter extends BaseChannelAdapter {
  private apiBaseUrl = 'https://partner.arabam.com/api';

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

      return response.data.listingId;
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
    // Field mapping: Platform → Arabam
    const fieldMap: any = {
      brandId: this.getBrandId(vehicleData.brand),
      seriesId: this.getSeriesId(vehicleData.series),
      modelId: this.getModelId(vehicleData.model),
      year: vehicleData.year,
      fuelType: vehicleData.fuelType?.toUpperCase(),
      transmission: vehicleData.transmission?.toUpperCase(),
      mileage: vehicleData.mileage,
      price: vehicleData.channelPrice || vehicleData.basePrice,
      description: vehicleData.description
    };

    return fieldMap;
  }

  async transformMedia(mediaUrls: string[]): Promise<string[]> {
    // Arabam requires JPEG/PNG, max 5MB
    // TODO: Implement media transformation via media worker
    return mediaUrls.slice(0, 30); // Limit to 30 images
  }

  private getBrandId(brand: string): number {
    // TODO: Implement brand ID lookup from database
    return 1;
  }

  private getSeriesId(series: string): number {
    // TODO: Implement series ID lookup
    return 1;
  }

  private getModelId(model: string): number {
    // TODO: Implement model ID lookup
    return 1;
  }
}
















