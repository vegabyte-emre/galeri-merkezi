// Common types shared across all services

export type UUID = string;

export interface BaseEntity {
  id: UUID;
  created_at: Date;
  updated_at: Date;
}

export interface PaginationParams {
  page?: number;
  limit?: number;
  sort?: string;
  order?: 'asc' | 'desc';
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface ApiError {
  code: string;
  message: string;
  details?: Array<{
    field: string;
    message: string;
  }>;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: ApiError;
}

// Gallery related types
export enum GalleryStatus {
  PENDING = 'pending',
  ACTIVE = 'active',
  SUSPENDED = 'suspended',
  REJECTED = 'rejected'
}

export enum TaxType {
  TCKN = 'TCKN',
  VKN = 'VKN'
}

// User related types
export enum UserRole {
  // Superadmin roles
  SUPERADMIN = 'superadmin',
  COMPLIANCE_OFFICER = 'compliance_officer',
  SUPPORT_AGENT = 'support_agent',
  INTEGRATION_MANAGER = 'integration_manager',
  FINANCE_REPORTER = 'finance_reporter',
  // Gallery roles
  GALLERY_OWNER = 'gallery_owner',
  GALLERY_MANAGER = 'gallery_manager',
  SALES_REP = 'sales_rep',
  INVENTORY_MANAGER = 'inventory_manager',
  VIEWER = 'viewer'
}

export enum UserStatus {
  ACTIVE = 'active',
  SUSPENDED = 'suspended',
  DELETED = 'deleted'
}

// Vehicle related types
export enum VehicleStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  PAUSED = 'paused',
  ARCHIVED = 'archived',
  SOLD = 'sold'
}

export enum FuelType {
  BENZIN = 'benzin',
  DIZEL = 'dizel',
  LPG = 'lpg',
  ELEKTRIK = 'elektrik',
  HIBRIT = 'hibrit'
}

export enum Transmission {
  MANUEL = 'manuel',
  OTOMATIK = 'otomatik',
  YARI_OTOMATIK = 'yarı_otomatik'
}

export enum BodyType {
  SEDAN = 'sedan',
  HATCHBACK = 'hatchback',
  SUV = 'suv',
  PICKUP = 'pickup',
  MINIVAN = 'minivan',
  COUPE = 'coupe',
  CABRIO = 'cabrio',
  STATION = 'station'
}

// Offer related types
export enum OfferStatus {
  DRAFT = 'draft',
  SENT = 'sent',
  VIEWED = 'viewed',
  COUNTER_OFFER = 'counter_offer',
  ACCEPTED = 'accepted',
  REJECTED = 'rejected',
  CANCELLED = 'cancelled',
  EXPIRED = 'expired',
  CONVERTED = 'converted'
}

// Channel related types
export enum ChannelListingStatus {
  PENDING = 'pending',
  ACTIVE = 'active',
  PAUSED = 'paused',
  ERROR = 'error',
  REMOVED = 'removed'
}

// Notification types
export enum NotificationType {
  NEW_OFFER = 'new_offer',
  OFFER_ACCEPTED = 'offer_accepted',
  OFFER_REJECTED = 'offer_rejected',
  NEW_MESSAGE = 'new_message',
  LISTING_PUBLISHED = 'listing_published',
  GALLERY_APPROVED = 'gallery_approved',
  GALLERY_REJECTED = 'gallery_rejected'
}

export enum NotificationChannel {
  SMS = 'sms',
  EMAIL = 'email',
  PUSH = 'push'
}

// Verification status types
export enum PhoneVerificationStatus {
  PENDING = 'pending',
  VERIFIED = 'verified',
  FAILED = 'failed'
}

export enum AuthorityDocumentStatus {
  PENDING = 'pending',
  VERIFIED = 'verified',
  INVALID = 'invalid',
  EXPIRED = 'expired'
}

export enum EIDSStatus {
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  VERIFIED = 'verified',
  FAILED = 'failed',
  EXPIRED = 'expired'
}

// JWT Payload
export interface JWTPayload {
  sub: UUID; // user_id
  gallery_id?: UUID;
  role: UserRole;
  permissions: string[];
  iat: number;
  exp: number;
  jti: string;
}
















