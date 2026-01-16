# Araç Çekme Yapısı - Teknik Dokümantasyon

## 📋 Genel Bakış

Galeri Paneli'nde araçlar iki farklı endpoint üzerinden çekilir:
1. **`/vehicles`** - Kendi galerisinin araçları (Authenticated, Protected)
2. **`/marketplace`** - Tüm galerilerin yayında olan araçları (Public, Optional Auth)

---

## 🔄 Veri Akışı

### Senaryo 1: Kendi Araçlarım (`/vehicles`)

```
Frontend (Panel)
    ↓
GET /api/v1/vehicles
    ↓
API Gateway (Port 8000)
    ├─ Auth Middleware (JWT kontrolü)
    ├─ User bilgilerini header'a ekle (x-gallery-id)
    └─ Proxy → Inventory Service
    ↓
Inventory Service (Port 3003)
    ├─ /vehicles route
    ├─ VehicleController.list()
    ├─ gallery_id kontrolü
    └─ PostgreSQL Query
    ↓
PostgreSQL
    └─ SELECT * FROM vehicles WHERE gallery_id = $1
    ↓
Response
    └─ JSON: { success: true, data: [...], pagination: {...} }
```

### Senaryo 2: Oto Pazarı (`/marketplace`)

```
Frontend (Panel)
    ↓
GET /api/v1/marketplace?page=1&limit=12&brand=BMW
    ↓
API Gateway (Port 8000)
    ├─ Optional Auth (token varsa decode et)
    ├─ User bilgilerini header'a ekle (varsa)
    └─ Proxy → Inventory Service
    ↓
Inventory Service (Port 3003)
    ├─ /marketplace route
    ├─ Marketplace route handler
    ├─ Published araçlar filtreleme
    ├─ Authenticated ise kendi galerisini hariç tut
    └─ PostgreSQL Query (JOIN with galleries)
    ↓
PostgreSQL
    └─ SELECT v.*, g.* FROM vehicles v 
       LEFT JOIN galleries g ON v.gallery_id = g.id
       WHERE v.status = 'published' AND v.gallery_id != $1
    ↓
Response
    └─ JSON: { success: true, data: [...], pagination: {...} }
```

---

## 🎯 Frontend Implementation

### 1. Kendi Araçlarım Sayfası (`/vehicles`)

**Dosya:** `frontend/panel/pages/vehicles/index.vue`

**API Çağrısı:**
```typescript
const loadVehicles = async () => {
  loading.value = true
  try {
    const response = await api.get<{ 
      success: boolean; 
      data?: any[]; 
      pagination?: any 
    }>('/vehicles')
    
    if (response.success && response.data) {
      vehicles.value = response.data
    } else if (Array.isArray(response)) {
      vehicles.value = response
    } else {
      vehicles.value = []
    }
  } catch (error: any) {
    console.error('Araçlar yüklenemedi:', error)
    toast.error('Araçlar yüklenemedi: ' + error.message)
    vehicles.value = []
  } finally {
    loading.value = false
  }
}
```

**Özellikler:**
- Authentication gerekli (JWT token)
- Sadece kendi galerisinin araçları
- Durum filtreleme (published, draft, paused, archived, sold)
- Client-side arama (marka, model)
- Pagination desteği

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `status` (opsiyonel: published, draft, paused, archived, sold)

---

### 2. Oto Pazarı Sayfası (`/marketplace`)

**Dosya:** `frontend/panel/pages/marketplace.vue`

**API Çağrısı:**
```typescript
const fetchVehicles = async () => {
  loading.value = true
  try {
    const params: Record<string, any> = {
      page: pagination.page,
      limit: pagination.limit,
      sort: sortBy.value
    }

    // Filtreler
    if (filters.brand) params.brand = filters.brand
    if (filters.city) params.city = filters.city
    if (filters.minPrice) params.minPrice = filters.minPrice
    if (filters.maxPrice) params.maxPrice = filters.maxPrice
    if (filters.minYear) params.minYear = filters.minYear
    if (filters.maxYear) params.maxYear = filters.maxYear
    if (filters.fuelType) params.fuelType = filters.fuelType
    if (filters.transmission) params.transmission = filters.transmission

    const response = await api.get('/marketplace', params)
    
    if (response.success) {
      vehicles.value = response.data || []
      pagination.total = response.pagination?.total || 0
      pagination.totalPages = response.pagination?.totalPages || 0
    }
  } catch (error) {
    console.error('Error fetching vehicles:', error)
    vehicles.value = []
  } finally {
    loading.value = false
  }
}
```

**Özellikler:**
- Public endpoint (authentication opsiyonel)
- Tüm galerilerin yayında olan araçları
- Authenticated ise kendi galerisini hariç tutar
- Gelişmiş filtreleme:
  - Marka
  - Şehir
  - Fiyat aralığı (min/max)
  - Yıl aralığı (min/max)
  - Yakıt tipi
  - Vites tipi
- Sıralama:
  - En yeni (default)
  - Fiyat (artan/azalan)
  - Model yılı
  - Kilometre
- Pagination

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `brand` (opsiyonel)
- `city` (opsiyonel)
- `minPrice` (opsiyonel)
- `maxPrice` (opsiyonel)
- `minYear` (opsiyonel)
- `maxYear` (opsiyonel)
- `fuelType` (opsiyonel)
- `transmission` (opsiyonel)
- `sort` (default: 'newest')

---

## 🌐 API Gateway Routing

### Endpoint 1: `/api/v1/vehicles`

**Yapılandırma:**
```typescript
// Protected route (Auth required)
app.use('/api/v1/vehicles', createProxyMiddleware({
  target: services.inventory,  // http://inventory-service:3003
  changeOrigin: true,
  pathRewrite: { '^/api/v1/vehicles': '/vehicles' },
  onProxyReq: (proxyReq, req: any, res) => {
    // User bilgilerini header'a ekle
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '')
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '')
      proxyReq.setHeader('x-user-role', req.user.role || '')
    }
  }
}))
```

**Özellikler:**
- Authentication zorunlu
- Rate limiting (100 req/min)
- User bilgileri header'a eklenir
- Inventory Service'e proxy edilir

---

### Endpoint 2: `/api/v1/marketplace`

**Yapılandırma:**
```typescript
// Public route (Optional auth)
app.use('/api/v1/marketplace', express.json())

// Optional auth middleware
app.use('/api/v1/marketplace', async (req: any, res, next) => {
  const authHeader = req.headers.authorization
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1]
    try {
      const decoded = jwt.verify(token, JWT_SECRET)
      req.user = decoded
    } catch (err) {
      // Token invalid - continue without user
    }
  }
  next()
})

app.use('/api/v1/marketplace', createProxyMiddleware({
  target: services.inventory,  // http://inventory-service:3003
  changeOrigin: true,
  pathRewrite: { '^/api/v1/marketplace': '/marketplace' },
  onProxyReq: (proxyReq, req: any, res) => {
    // User bilgilerini header'a ekle (varsa)
    if (req.user) {
      proxyReq.setHeader('x-user-id', req.user.sub || '')
      proxyReq.setHeader('x-gallery-id', req.user.gallery_id || '')
      proxyReq.setHeader('x-user-role', req.user.role || '')
    }
  }
}))
```

**Özellikler:**
- Public endpoint (authentication opsiyonel)
- Token varsa decode edilir
- User bilgileri header'a eklenir (varsa)
- Rate limiting yok (public)

---

## 🔧 Backend Implementation

### Inventory Service - Vehicle Controller

**Dosya:** `backend/services/inventory-service/src/controllers/vehicleController.ts`

#### `list()` Method

**Endpoint:** `GET /vehicles`

**Authentication:** Required

**Headers:**
- `x-gallery-id` (API Gateway tarafından eklenir)

**Implementation:**
```typescript
async list(req: AuthenticatedRequest, res: Response) {
  const userInfo = getUserFromHeaders(req)
  const galleryId = userInfo.gallery_id
  const { page = 1, limit = 20, status } = req.query

  if (!galleryId) {
    throw new ValidationError('Gallery ID not found')
  }

  const offset = (Number(page) - 1) * Number(limit)
  let whereClause = 'WHERE gallery_id = $1'
  const params: any[] = [galleryId]
  let paramCount = 2

  // Status filtreleme
  if (status) {
    whereClause += ` AND status = $${paramCount++}`
    params.push(status)
  }

  // Araçları getir
  const result = await query(
    `SELECT * FROM vehicles ${whereClause} 
     ORDER BY created_at DESC 
     LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
    [...params, Number(limit), offset]
  )

  // Toplam sayı
  const countResult = await query(
    `SELECT COUNT(*) as total FROM vehicles ${whereClause}`,
    params
  )

  res.json({
    success: true,
    data: result.rows,
    pagination: {
      page: Number(page),
      limit: Number(limit),
      total: parseInt(countResult.rows[0].total),
      totalPages: Math.ceil(parseInt(countResult.rows[0].total) / Number(limit))
    }
  })
}
```

**SQL Sorgusu:**
```sql
SELECT * FROM vehicles 
WHERE gallery_id = $1 
  AND status = $2  -- (opsiyonel)
ORDER BY created_at DESC 
LIMIT $3 OFFSET $4
```

**Özellikler:**
- Gallery ID bazlı filtreleme (tenant isolation)
- Status filtreleme (opsiyonel)
- Pagination
- Sıralama: `created_at DESC` (en yeni önce)

---

### Inventory Service - Marketplace Routes

**Dosya:** `backend/services/inventory-service/src/routes/marketplace.ts`

#### `GET /marketplace`

**Authentication:** Optional

**Headers:**
- `x-gallery-id` (opsiyonel, authenticated ise)

**Implementation:**
```typescript
router.get('/', async (req: Request, res: Response) => {
  const { 
    page = 1, 
    limit = 20, 
    brand, 
    minPrice, 
    maxPrice, 
    minYear, 
    maxYear,
    fuelType,
    transmission,
    city,
    sort = 'newest'
  } = req.query

  // Authenticated ise kendi galerisini hariç tut
  const currentGalleryId = req.headers['x-gallery-id'] as string | undefined

  const offset = (Number(page) - 1) * Number(limit)
  let whereClause = "WHERE v.status = 'published'"
  const params: any[] = []
  let paramCount = 1

  // Kendi galerisini hariç tut
  if (currentGalleryId) {
    whereClause += ` AND v.gallery_id != $${paramCount++}`
    params.push(currentGalleryId)
  }

  // Filtreler
  if (brand) {
    whereClause += ` AND v.brand = $${paramCount++}`
    params.push(brand)
  }
  if (minPrice) {
    whereClause += ` AND v.base_price >= $${paramCount++}`
    params.push(Number(minPrice))
  }
  if (maxPrice) {
    whereClause += ` AND v.base_price <= $${paramCount++}`
    params.push(Number(maxPrice))
  }
  // ... diğer filtreler

  // Sıralama
  let orderBy = 'ORDER BY v.published_at DESC'
  if (sort === 'price_asc') orderBy = 'ORDER BY v.base_price ASC'
  else if (sort === 'price_desc') orderBy = 'ORDER BY v.base_price DESC'
  else if (sort === 'year_desc') orderBy = 'ORDER BY v.year DESC'
  else if (sort === 'mileage_asc') orderBy = 'ORDER BY v.mileage ASC'

  // Sorgu
  const result = await query(
    `SELECT 
      v.id, v.listing_no, v.brand, v.series, v.model, v.year, 
      v.fuel_type, v.transmission, v.body_type, v.color,
      v.mileage, v.base_price, v.currency, v.description,
      v.has_warranty, v.published_at, v.created_at,
      g.id as gallery_id, g.name as gallery_name, g.city, g.district,
      g.logo_url as gallery_logo, g.phone as gallery_phone,
      (SELECT original_url FROM vehicle_media WHERE vehicle_id = v.id AND is_cover = true LIMIT 1) as primary_image,
      (SELECT COUNT(*) FROM vehicle_media WHERE vehicle_id = v.id) as image_count
    FROM vehicles v
    LEFT JOIN galleries g ON v.gallery_id = g.id
    ${whereClause}
    ${orderBy}
    LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
    [...params, Number(limit), offset]
  )

  // Toplam sayı
  const countResult = await query(
    `SELECT COUNT(*) as total 
     FROM vehicles v 
     LEFT JOIN galleries g ON v.gallery_id = g.id 
     ${whereClause}`,
    params
  )

  res.json({
    success: true,
    data: result.rows,
    pagination: {
      page: Number(page),
      limit: Number(limit),
      total: parseInt(countResult.rows[0].total),
      totalPages: Math.ceil(parseInt(countResult.rows[0].total) / Number(limit))
    }
  })
})
```

**SQL Sorgusu:**
```sql
SELECT 
  v.id, v.listing_no, v.brand, v.series, v.model, v.year, 
  v.fuel_type, v.transmission, v.body_type, v.color,
  v.mileage, v.base_price, v.currency, v.description,
  v.has_warranty, v.published_at, v.created_at,
  g.id as gallery_id, g.name as gallery_name, g.city, g.district,
  g.logo_url as gallery_logo, g.phone as gallery_phone,
  (SELECT original_url FROM vehicle_media WHERE vehicle_id = v.id AND is_cover = true LIMIT 1) as primary_image,
  (SELECT COUNT(*) FROM vehicle_media WHERE vehicle_id = v.id) as image_count
FROM vehicles v
LEFT JOIN galleries g ON v.gallery_id = g.id
WHERE v.status = 'published'
  AND v.gallery_id != $1  -- (authenticated ise)
  AND v.brand = $2  -- (opsiyonel)
  AND v.base_price >= $3  -- (opsiyonel)
  AND v.base_price <= $4  -- (opsiyonel)
  -- ... diğer filtreler
ORDER BY v.published_at DESC  -- (sort parametresine göre)
LIMIT $N OFFSET $M
```

**Özellikler:**
- Sadece `published` araçlar
- Authenticated ise kendi galerisini hariç tutar
- Galeri bilgileri JOIN edilir
- Primary image (cover) subquery ile getirilir
- Image count subquery ile getirilir
- Gelişmiş filtreleme
- Çoklu sıralama seçenekleri
- Pagination

---

## 💾 Veritabanı Yapısı

### `vehicles` Tablosu

**Ana Alanlar:**
```sql
CREATE TABLE vehicles (
    id UUID PRIMARY KEY,
    gallery_id UUID NOT NULL REFERENCES galleries(id),
    listing_no VARCHAR(20) UNIQUE NOT NULL,
    brand VARCHAR(100),
    series VARCHAR(100),
    model VARCHAR(100),
    year INTEGER,
    fuel_type VARCHAR(20),
    transmission VARCHAR(20),
    body_type VARCHAR(20),
    engine_power INTEGER,
    engine_cc INTEGER,
    drivetrain VARCHAR(20),
    color VARCHAR(50),
    vehicle_condition VARCHAR(20),
    mileage INTEGER,
    has_warranty BOOLEAN,
    warranty_details TEXT,
    heavy_damage_record BOOLEAN,
    plate_number VARCHAR(20),
    seller_type VARCHAR(20),
    trade_in_acceptable BOOLEAN,
    base_price DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'TRY',
    description TEXT,
    status VARCHAR(20) DEFAULT 'draft',  -- draft, published, paused, archived, sold
    search_vector TSVECTOR,  -- Full-text search
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    published_at TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
)
```

**Indexes:**
- `idx_vehicles_gallery` (gallery_id) - Tenant isolation için
- `idx_vehicles_status` (status) - Status filtreleme için
- `idx_vehicles_brand` (brand) - Marka filtreleme için
- `idx_vehicles_year` (year) - Yıl filtreleme için
- `idx_vehicles_price` (base_price) - Fiyat sıralama için
- `idx_vehicles_listing` (listing_no) - Unique constraint
- `idx_vehicles_search` (search_vector) - Full-text search için (GIN index)

**Full-Text Search:**
- PostgreSQL TSVECTOR kullanılıyor
- Trigger ile otomatik güncellenir
- Marka, seri, model, açıklama arama için

---

## 🔍 Filtreleme ve Sıralama

### Kendi Araçlarım (`/vehicles`)

**Client-side Filtreleme:**
- Arama: Marka, model (JavaScript filter)
- Durum: Dropdown seçimi

**Server-side Filtreleme:**
- Status (query parameter)

**Sıralama:**
- `created_at DESC` (sabit, en yeni önce)

---

### Oto Pazarı (`/marketplace`)

**Server-side Filtreleme:**
- Brand (marka)
- City (şehir)
- MinPrice / MaxPrice (fiyat aralığı)
- MinYear / MaxYear (yıl aralığı)
- FuelType (yakıt tipi)
- Transmission (vites tipi)

**Sıralama Seçenekleri:**
- `newest` (default): `published_at DESC`
- `price_asc`: `base_price ASC`
- `price_desc`: `base_price DESC`
- `year_desc`: `year DESC`
- `mileage_asc`: `mileage ASC`

---

## 🔐 Güvenlik ve İzolasyon

### Tenant Isolation

**Kendi Araçlarım:**
- `gallery_id` kontrolü zorunlu
- Sadece kendi galerisinin araçları
- SQL injection koruması (parameterized queries)

**Oto Pazarı:**
- Authenticated ise kendi galerisini hariç tutar
- Public endpoint (herkes erişebilir)
- Sadece `published` araçlar gösterilir

### Authorization

**Roller:**
- `gallery_owner` - Tüm işlemler
- `gallery_manager` - Tüm işlemler
- `inventory_manager` - Araç yönetimi
- Diğer roller - Sadece görüntüleme

**Kontrol:**
```typescript
const allowedRoles = ['gallery_owner', 'gallery_manager', 'inventory_manager']
if (!allowedRoles.includes(userInfo.role)) {
  throw new ForbiddenError('Insufficient permissions')
}
```

---

## 📊 Response Format

### Başarılı Response

**Kendi Araçlarım:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "gallery_id": "uuid",
      "listing_no": "GM-1234567890-ABC",
      "brand": "BMW",
      "series": "3 Serisi",
      "model": "320i",
      "year": 2020,
      "fuel_type": "benzin",
      "transmission": "otomatik",
      "body_type": "sedan",
      "mileage": 45000,
      "base_price": 850000,
      "currency": "TRY",
      "status": "published",
      "created_at": "2024-01-15T10:00:00Z",
      "published_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

**Oto Pazarı:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "listing_no": "GM-1234567890-ABC",
      "brand": "BMW",
      "model": "320i",
      "year": 2020,
      "fuel_type": "benzin",
      "transmission": "otomatik",
      "mileage": 45000,
      "base_price": 850000,
      "currency": "TRY",
      "primary_image": "https://minio.../image.jpg",
      "image_count": 5,
      "gallery_id": "uuid",
      "gallery_name": "İstanbul Oto",
      "city": "İstanbul",
      "district": "Kadıköy",
      "gallery_logo": "https://minio.../logo.jpg",
      "gallery_phone": "+905551234567",
      "published_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 12,
    "total": 1250,
    "totalPages": 105
  }
}
```

---

## 🚀 Performans Optimizasyonları

### Database Indexes

**Önemli Indexes:**
- `gallery_id` - Tenant isolation için kritik
- `status` - Published araçlar için filtreleme
- `brand` - Marka filtreleme
- `base_price` - Fiyat sıralama
- `year` - Yıl filtreleme
- `search_vector` (GIN) - Full-text search

### Query Optimizations

**1. JOIN Optimization:**
- `LEFT JOIN galleries` - Galeri bilgileri için
- Sadece gerekli alanlar seçilir

**2. Subquery Optimization:**
- Primary image: `LIMIT 1` ile sınırlandırılmış
- Image count: `COUNT(*)` ile hızlı

**3. Pagination:**
- `LIMIT` ve `OFFSET` kullanımı
- Toplam sayı ayrı sorgu ile

**4. Filtering:**
- Parameterized queries (SQL injection koruması)
- Index kullanımı için uygun WHERE clause'lar

---

## 🔄 Event Publishing

### Vehicle Events

**Oluşturulduğunda:**
```typescript
await this.eventPublisher.publishVehicleCreated(vehicleId)
```
- Search indexer'a bildirim
- Meilisearch'e ekleme

**Güncellendiğinde:**
```typescript
await this.eventPublisher.publishVehicleUpdated(vehicleId)
```
- Search indexer'a bildirim
- Meilisearch'te güncelleme

**Yayınlandığında:**
```typescript
await this.eventPublisher.publishVehiclePublished(vehicleId)
```
- Search indexer'a bildirim
- Channel connector'a bildirim (pazar yeri senkronizasyonu)
- Meilisearch'e ekleme

---

## 📝 Örnek Kullanım Senaryoları

### Senaryo 1: Galeri Sahibi Kendi Araçlarını Görüntülüyor

```
1. Kullanıcı /vehicles sayfasına gider
2. Frontend: GET /api/v1/vehicles
3. API Gateway: JWT token kontrolü → User bilgilerini header'a ekle
4. Inventory Service: gallery_id = "user-gallery-id"
5. PostgreSQL: SELECT * FROM vehicles WHERE gallery_id = 'user-gallery-id'
6. Response: Kullanıcının galerisindeki tüm araçlar
7. Frontend: Araçları grid layout'ta gösterir
```

### Senaryo 2: Galeri Sahibi Oto Pazarı'nda Araç Arıyor

```
1. Kullanıcı /marketplace sayfasına gider
2. Filtreler: brand=BMW, minPrice=500000, maxPrice=1000000
3. Frontend: GET /api/v1/marketplace?brand=BMW&minPrice=500000&maxPrice=1000000
4. API Gateway: JWT token varsa decode et → gallery_id header'a ekle
5. Inventory Service: 
   - WHERE status = 'published'
   - AND gallery_id != 'user-gallery-id'  (kendi galerisini hariç tut)
   - AND brand = 'BMW'
   - AND base_price >= 500000
   - AND base_price <= 1000000
6. PostgreSQL: JOIN with galleries, filtreleme, sıralama
7. Response: Filtrelenmiş araçlar + galeri bilgileri
8. Frontend: Araçları grid layout'ta gösterir
```

### Senaryo 3: Misafir Kullanıcı Oto Pazarı'nda Araç Görüntülüyor

```
1. Kullanıcı (giriş yapmamış) /marketplace sayfasına gider
2. Frontend: GET /api/v1/marketplace
3. API Gateway: Token yok → Public request
4. Inventory Service: 
   - WHERE status = 'published'
   - (gallery_id kontrolü yok, tüm galeriler)
5. PostgreSQL: Tüm yayında olan araçlar
6. Response: Tüm galerilerin yayında olan araçları
7. Frontend: Araçları gösterir
```

---

## 🐛 Hata Senaryoları

### 1. Authentication Hatası

**Durum:** Token geçersiz veya eksik

**Kendi Araçlarım:**
- API Gateway: 401 Unauthorized
- Frontend: Login sayfasına yönlendir

**Oto Pazarı:**
- Public endpoint, hata yok
- Sadece kendi galerisini hariç tutma özelliği çalışmaz

---

### 2. Gallery ID Bulunamadı

**Durum:** Token'da gallery_id yok

**Kendi Araçlarım:**
- Backend: `ValidationError('Gallery ID not found')`
- Frontend: Hata mesajı göster

---

### 3. Veritabanı Hatası

**Durum:** PostgreSQL bağlantı hatası

**Response:**
```json
{
  "success": false,
  "error": "Internal server error"
}
```

**Frontend:** Hata mesajı göster, boş liste

---

## 🔧 Geliştirme Notları

### Frontend'de Yapılacaklar

**1. Error Handling:**
- Network hataları
- Timeout hataları
- 401/403 hataları
- 500 hataları

**2. Loading States:**
- Skeleton loading
- Spinner
- Empty states

**3. Caching:**
- React Query (gelecek)
- LocalStorage cache (opsiyonel)

**4. Optimistic Updates:**
- Araç ekleme/güncelleme
- Durum değişiklikleri

---

### Backend'de Yapılacaklar

**1. Meilisearch Entegrasyonu:**
- Arama için Meilisearch kullanımı
- Full-text search iyileştirmesi

**2. Redis Caching:**
- Sık kullanılan sorguları cache'leme
- Pagination cache

**3. Query Optimization:**
- EXPLAIN ANALYZE ile sorgu analizi
- Index optimizasyonu

**4. Rate Limiting:**
- Marketplace için rate limiting
- IP bazlı throttling

---

## 📊 Metrikler ve Monitoring

### Önemli Metrikler

**Performance:**
- Query execution time
- Response time
- Database connection pool usage

**Usage:**
- Request count (per endpoint)
- Filter usage statistics
- Popular brands/cities

**Errors:**
- 401/403/500 error rates
- Timeout rates
- Database connection errors

---

## 🔗 İlgili Dokümantasyonlar

- [GALERI-PANEL.md](./GALERI-PANEL.md) - Frontend panel dokümantasyonu
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Genel mimari
- [CHAT-SYSTEM.md](./CHAT-SYSTEM.md) - Mesajlaşma sistemi

---

**Son Güncelleme**: 2024-01-XX
**Versiyon**: 1.0
**Durum**: Production Ready

---

*Bu dokümantasyon canlı bir belgedir ve sistem geliştikçe güncellenecektir.*
