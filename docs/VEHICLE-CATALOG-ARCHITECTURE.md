# Araç Katalog Yapısı - Teknik Dokümantasyon

## 📋 Genel Bakış

Araç ekleme formunda kullanılan özellikler (marka, model, motor, vb.) **hierarchical (hierarşik)** bir yapı ile çekilir. Kullanıcı önce marka seçer, sonra yıl, sonra model, son olarak motor/versiyon seçer. Her seçim bir sonraki seçenekleri dinamik olarak yükler.

**Veri Yapısı:**
```
Brand (Marka)
  └─ Year (Yıl) - Model isimlerinden extract edilir
      └─ Model (Model)
          └─ Engine (Motor/Versiyon)
```

---

## 🔄 Veri Akışı

### Senaryo: Araç Ekleme Formu

```
Frontend (Panel) - /vehicles/new
    ↓
1. Sayfa Yüklendiğinde
   GET /api/v1/catalog/brands
   ↓
   API Gateway → Inventory Service
   ↓
   PostgreSQL: SELECT * FROM vehicle_brands
   ↓
   Response: Tüm markalar (popüler markalar önce)
   
2. Kullanıcı Marka Seçtiğinde
   GET /api/v1/catalog/brands/{brandId}/models
   ↓
   API Gateway → Inventory Service
   ↓
   PostgreSQL: SELECT * FROM vehicle_models WHERE brand_id = $1
   ↓
   Response: Tüm modeller (model isimlerinden yıl extract edilir)
   ↓
   Frontend: Yılları extract et ve göster
   
3. Kullanıcı Yıl Seçtiğinde
   GET /api/v1/catalog/brands/{brandId}/models (tekrar)
   ↓
   Frontend: Seçilen yıla göre modelleri filtrele
   ↓
   Model isimlerinden yıl prefix'ini kaldır
   
4. Kullanıcı Model Seçtiğinde
   GET /api/v1/catalog/models/{modelId}/engines
   ↓
   API Gateway → Inventory Service
   ↓
   PostgreSQL: SELECT * FROM vehicle_engines WHERE model_id = $1
   ↓
   Response: Motor/versiyon seçenekleri
   ↓
   Frontend: Form alanlarını otomatik doldur (motor gücü, hacim, yakıt, vb.)
   
5. Kullanıcı Motor Seçtiğinde (Opsiyonel)
   Frontend: Motor verilerinden form alanlarını otomatik doldur
   - Motor gücü (HP)
   - Motor hacmi (cc)
   - Yakıt tipi
   - Çekiş tipi
   - Vites tipi (gearbox'tan parse edilir)
```

---

## 🎯 Frontend Implementation

### Araç Ekleme Formu

**Dosya:** `frontend/panel/pages/vehicles/new.vue`

### 1. Markaları Yükleme

**Sayfa Yüklendiğinde:**
```typescript
onMounted(async () => {
  await loadBrands()
})

const loadBrands = async () => {
  loadingBrands.value = true
  try {
    const response = await api.get<{ success: boolean; data: Brand[] }>('/catalog/brands')
    if (response.success) {
      brands.value = response.data
    }
  } catch (error: any) {
    console.error('Markalar yüklenemedi:', error)
    toast.error('Markalar yüklenemedi')
  } finally {
    loadingBrands.value = false
  }
}
```

**API Endpoint:** `GET /api/v1/catalog/brands`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "BMW",
      "logo_url": "https://...",
      "is_popular": true
    },
    {
      "id": 2,
      "name": "Mercedes Benz",
      "logo_url": "https://...",
      "is_popular": true
    }
  ]
}
```

**UI:**
- Popüler markalar ayrı optgroup'ta gösterilir
- Diğer markalar "Tüm Markalar" optgroup'unda

---

### 2. Marka Seçildiğinde - Yılları Yükleme

**Event Handler:**
```typescript
const onBrandChange = async () => {
  selectedYear.value = ''
  selectedModelId.value = ''
  selectedEngineId.value = ''
  years.value = []
  models.value = []
  engines.value = []
  
  if (!selectedBrandId.value) return
  
  // Form'a marka adını kaydet
  form.brand = selectedBrand.value?.name || ''
  
  loadingYears.value = true
  try {
    // Markanın tüm modellerini getir
    const modelsResponse = await api.get<{ success: boolean; data: Model[] }>(
      `/catalog/brands/${selectedBrandId.value}/models`
    )
    
    if (modelsResponse.success && modelsResponse.data) {
      // Model isimlerinden yılları extract et
      // Format: "2025 Audi A3" -> 2025
      const extractedYears = new Set<number>()
      
      modelsResponse.data.forEach((model: Model) => {
        const yearMatch = model.name.match(/^(\d{4})\s+/)
        if (yearMatch && yearMatch[1]) {
          const year = parseInt(yearMatch[1], 10)
          if (year >= 1900 && year <= new Date().getFullYear() + 1) {
            extractedYears.add(year)
          }
        }
      })
      
      // Yılları sırala (en yeni önce)
      years.value = Array.from(extractedYears).sort((a, b) => b - a)
    }
  } catch (error: any) {
    console.error('Yıllar yüklenemedi:', error)
    toast.error('Yıllar yüklenemedi')
  } finally {
    loadingYears.value = false
  }
}
```

**API Endpoint:** `GET /api/v1/catalog/brands/{brandId}/models`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "name": "2025 Audi A3 Sportback",
      "year_start": 2025,
      "year_end": null,
      "body_type": "Hatchback",
      "engine_count": 3
    },
    {
      "id": 124,
      "name": "2024 Audi A3 Sportback",
      "year_start": 2024,
      "year_end": null,
      "body_type": "Hatchback",
      "engine_count": 3
    }
  ]
}
```

**Özellikler:**
- Model isimleri format: `"YYYY Brand Model"` (örn: "2025 Audi A3")
- Yıllar regex ile extract edilir: `/^(\d{4})\s+/`
- Duplicate yıllar Set ile filtrelenir
- Yıllar descending sıralanır (en yeni önce)

---

### 3. Yıl Seçildiğinde - Modelleri Yükleme

**Event Handler:**
```typescript
const onYearChange = async () => {
  selectedModelId.value = ''
  selectedEngineId.value = ''
  models.value = []
  engines.value = []
  
  if (!selectedBrandId.value || !selectedYear.value) return
  
  loadingModels.value = true
  try {
    // Markanın tüm modellerini getir (tekrar)
    const modelsResponse = await api.get<{ success: boolean; data: Model[] }>(
      `/catalog/brands/${selectedBrandId.value}/models`
    )
    
    if (modelsResponse.success && modelsResponse.data) {
      const yearStr = String(selectedYear.value)
      
      // Seçilen yıla göre modelleri filtrele
      models.value = modelsResponse.data
        .filter((model: Model) => {
          // Model ismi seçilen yıl ile başlıyor mu?
          return model.name.startsWith(yearStr + ' ')
        })
        .map((model: Model) => {
          // Yıl prefix'ini kaldır (örn: "2025 Audi A3" -> "Audi A3")
          return {
            ...model,
            name: model.name.replace(/^\d{4}\s+/, ''),
            original_name: model.name  // Orijinal ismi sakla
          }
        })
    }
  } catch (error: any) {
    console.error('Modeller yüklenemedi:', error)
    toast.error('Modeller yüklenemedi')
  } finally {
    loadingModels.value = false
  }
}
```

**Özellikler:**
- Seçilen yıla göre modeller client-side'da filtrelenir
- Model isimlerinden yıl prefix'i kaldırılır
- Orijinal isim `original_name` olarak saklanır (form'a kaydedilir)

---

### 4. Model Seçildiğinde - Motorları Yükleme

**Event Handler:**
```typescript
const onModelChange = async () => {
  selectedEngineId.value = ''
  engines.value = []
  
  if (!selectedModelId.value) return
  
  // Form'a model adını kaydet (orijinal isim)
  const modelName = selectedModel.value?.original_name || selectedModel.value?.name || ''
  form.model = modelName
  
  // Body type'ı otomatik doldur (varsa)
  if (selectedModel.value?.body_type) {
    form.bodyType = selectedModel.value.body_type
  }
  
  // Yılı form'a kaydet
  if (selectedYear.value) {
    form.year = Number(selectedYear.value)
  }
  
  loadingEngines.value = true
  try {
    const response = await api.get<{ success: boolean; data: Engine[] }>(
      `/catalog/models/${selectedModelId.value}/engines`
    )
    if (response.success) {
      engines.value = response.data
    }
  } catch (error: any) {
    console.error('Motor seçenekleri yüklenemedi:', error)
  } finally {
    loadingEngines.value = false
  }
}
```

**API Endpoint:** `GET /api/v1/catalog/models/{modelId}/engines`

**Response:**
```json
{
  "success": true,
 "data": [
    {
      "id": 456,
      "name": "2.0 TDI 150 HP",
      "cylinders": "4",
      "displacement_cc": 1968,
      "power_hp": 150,
      "power_kw": 110,
      "torque_nm": 340,
      "fuel_type": "Dizel",
      "fuel_system": "Common Rail",
      "top_speed_kmh": 210,
      "acceleration_0_100": 8.5,
      "drive_type": "Önden Çekiş",
      "gearbox": "6-speed Manual",
      "length_mm": 4340,
      "width_mm": 1816,
      "height_mm": 1425,
      "wheelbase_mm": 2636,
      "cargo_volume_l": 380,
      "weight_kg": 1350,
      "fuel_city_l100km": 5.2,
      "fuel_highway_l100km": 4.1,
      "fuel_combined_l100km": 4.5,
      "co2_emissions": 118
    }
  ]
}
```

**Özellikler:**
- Model seçildiğinde form alanları otomatik doldurulur:
  - `form.model` = Model adı (orijinal, yıl ile)
  - `form.bodyType` = Body type (varsa)
  - `form.year` = Seçilen yıl

---

### 5. Motor Seçildiğinde - Form Otomatik Doldurma

**Event Handler:**
```typescript
const onEngineChange = () => {
  if (!selectedEngineId.value) return
  
  const engine = selectedEngine.value
  if (!engine) return
  
  // Teknik özellikleri otomatik doldur
  if (engine.power_hp) form.enginePower = engine.power_hp
  if (engine.displacement_cc) form.engineCc = engine.displacement_cc
  if (engine.fuel_type) form.fuelType = engine.fuel_type
  if (engine.drive_type) form.drivetrain = engine.drive_type
  
  // Vites tipini gearbox'tan parse et
  if (engine.gearbox) {
    const gearbox = engine.gearbox.toLowerCase()
    if (gearbox.includes('automatic') || gearbox.includes('otomatik')) {
      form.transmission = 'Otomatik'
    } else if (gearbox.includes('manual') || gearbox.includes('manuel')) {
      form.transmission = 'Manuel'
    }
  }
  
  // Seri adını motor adından al
  form.series = engine.name
}
```

**Otomatik Doldurulan Alanlar:**
- `enginePower` (HP) - Motor gücü
- `engineCc` (cc) - Motor hacmi
- `fuelType` - Yakıt tipi
- `drivetrain` - Çekiş tipi
- `transmission` - Vites tipi (gearbox'tan parse edilir)
- `series` - Seri adı (motor adı)

---

## 🔧 Backend Implementation

### Inventory Service - Catalog Routes

**Dosya:** `backend/services/inventory-service/src/routes/catalog.ts`

### 1. GET /catalog/brands

**Endpoint:** `GET /api/v1/catalog/brands`

**Query Parameters:**
- `popular` (opsiyonel): `true` ise sadece popüler markalar

**Implementation:**
```typescript
router.get('/brands', asyncHandler(async (req: Request, res: Response) => {
  const { popular } = req.query
  
  let sql = `
    SELECT id, name, logo_url, is_popular
    FROM vehicle_brands
  `
  
  if (popular === 'true') {
    sql += ` WHERE is_popular = true`
  }
  
  sql += ` ORDER BY is_popular DESC, sort_order ASC, name ASC`
  
  const result = await query(sql)
  
  res.json({
    success: true,
    data: result.rows
  })
}))
```

**SQL Sorgusu:**
```sql
SELECT id, name, logo_url, is_popular
FROM vehicle_brands
WHERE is_popular = true  -- (opsiyonel)
ORDER BY is_popular DESC, sort_order ASC, name ASC
```

**Özellikler:**
- Popüler markalar önce gösterilir
- `sort_order` ile özel sıralama
- Alfabetik sıralama

---

### 2. GET /catalog/brands/:brandId/models

**Endpoint:** `GET /api/v1/catalog/brands/{brandId}/models`

**Query Parameters:**
- `search` (opsiyonel): Model adında arama

**Implementation:**
```typescript
router.get('/brands/:brandId/models', asyncHandler(async (req: Request, res: Response) => {
  const { brandId } = req.params
  const { search } = req.query
  
  let sql = `
    SELECT 
      vm.id, 
      vm.name, 
      vm.year_start, 
      vm.year_end,
      vm.body_type,
      vm.photos,
      COUNT(ve.id) as engine_count
    FROM vehicle_models vm
    LEFT JOIN vehicle_engines ve ON ve.model_id = vm.id
    WHERE vm.brand_id = $1
  `
  
  const params: any[] = [brandId]
  
  if (search) {
    sql += ` AND vm.name ILIKE $2`
    params.push(`%${search}%`)
  }
  
  sql += ` GROUP BY vm.id ORDER BY vm.name ASC`
  
  const result = await query(sql, params)
  
  res.json({
    success: true,
    data: result.rows
  })
}))
```

**SQL Sorgusu:**
```sql
SELECT 
  vm.id, 
  vm.name, 
  vm.year_start, 
  vm.year_end,
  vm.body_type,
  vm.photos,
  COUNT(ve.id) as engine_count
FROM vehicle_models vm
LEFT JOIN vehicle_engines ve ON ve.model_id = vm.id
WHERE vm.brand_id = $1
  AND vm.name ILIKE $2  -- (opsiyonel, search)
GROUP BY vm.id 
ORDER BY vm.name ASC
```

**Özellikler:**
- Model adı format: `"YYYY Brand Model"` (örn: "2025 Audi A3")
- Motor sayısı (`engine_count`) JOIN ile hesaplanır
- Arama desteği (ILIKE)

---

### 3. GET /catalog/models/:modelId/engines

**Endpoint:** `GET /api/v1/catalog/models/{modelId}/engines`

**Implementation:**
```typescript
router.get('/models/:modelId/engines', asyncHandler(async (req: Request, res: Response) => {
  const { modelId } = req.params
  
  const result = await query(`
    SELECT 
      id, 
      name,
      cylinders,
      displacement_cc,
      power_hp,
      power_kw,
      torque_nm,
      fuel_type,
      fuel_system,
      top_speed_kmh,
      acceleration_0_100,
      drive_type,
      gearbox,
      length_mm,
      width_mm,
      height_mm,
      wheelbase_mm,
      cargo_volume_l,
      weight_kg,
      fuel_city_l100km,
      fuel_highway_l100km,
      fuel_combined_l100km,
      co2_emissions
    FROM vehicle_engines
    WHERE model_id = $1
    ORDER BY power_hp DESC NULLS LAST, name ASC
  `, [modelId])
  
  res.json({
    success: true,
    data: result.rows
  })
}))
```

**SQL Sorgusu:**
```sql
SELECT 
  id, 
  name,
  cylinders,
  displacement_cc,
  power_hp,
  power_kw,
  torque_nm,
  fuel_type,
  fuel_system,
  top_speed_kmh,
  acceleration_0_100,
  drive_type,
  gearbox,
  length_mm,
  width_mm,
  height_mm,
  wheelbase_mm,
  cargo_volume_l,
  weight_kg,
  fuel_city_l100km,
  fuel_highway_l100km,
  fuel_combined_l100km,
  co2_emissions
FROM vehicle_engines
WHERE model_id = $1
ORDER BY power_hp DESC NULLS LAST, name ASC
```

**Özellikler:**
- Motor gücüne göre sıralama (en güçlü önce)
- Detaylı teknik özellikler
- Performans verileri (0-100, top speed)
- Yakıt tüketimi (şehir, otoyol, kombine)
- CO2 emisyonları

---

## 💾 Veritabanı Yapısı

### vehicle_brands Tablosu

```sql
CREATE TABLE vehicle_brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    logo_url TEXT,
    is_popular BOOLEAN DEFAULT false,
    sort_order INT DEFAULT 999,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Indexes:**
- `idx_vehicle_brands_popular` (is_popular) - Popüler markalar için

**Popüler Markalar (Türkiye):**
- RENAULT, VOLKSWAGEN, FIAT, FORD, TOYOTA, HYUNDAI, OPEL, PEUGEOT, CITROEN, DACIA
- BMW, MERCEDES BENZ, AUDI, HONDA, NISSAN, KIA, SKODA, SEAT, MAZDA, VOLVO

---

### vehicle_models Tablosu

```sql
CREATE TABLE vehicle_models (
    id SERIAL PRIMARY KEY,
    brand_id INT NOT NULL REFERENCES vehicle_brands(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,  -- Format: "YYYY Brand Model"
    year_start INT,
    year_end INT,
    body_type VARCHAR(50),
    photos TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(brand_id, name)
)
```

**Indexes:**
- `idx_vehicle_models_brand` (brand_id) - Marka bazlı sorgular için

**Model İsim Formatı:**
- `"2025 Audi A3 Sportback"`
- `"2024 BMW 320i"`
- `"2023 Mercedes C200"`

**Özellikler:**
- Model adı yıl ile başlar (YYYY)
- Body type bilgisi saklanır
- Fotoğraflar array olarak saklanır

---

### vehicle_engines Tablosu

```sql
CREATE TABLE vehicle_engines (
    id SERIAL PRIMARY KEY,
    model_id INT NOT NULL REFERENCES vehicle_models(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    -- Engine specs
    cylinders VARCHAR(20),
    displacement_cc INT,
    power_hp INT,
    power_kw DECIMAL(10,2),
    torque_nm INT,
    fuel_type VARCHAR(50),
    fuel_system VARCHAR(100),
    -- Performance
    top_speed_kmh INT,
    acceleration_0_100 DECIMAL(4,1),
    -- Transmission
    drive_type VARCHAR(50),
    gearbox VARCHAR(100),
    -- Dimensions
    length_mm INT,
    width_mm INT,
    height_mm INT,
    wheelbase_mm INT,
    cargo_volume_l INT,
    -- Weight
    weight_kg INT,
    -- Fuel economy
    fuel_city_l100km DECIMAL(4,1),
    fuel_highway_l100km DECIMAL(4,1),
    fuel_combined_l100km DECIMAL(4,1),
    -- CO2
    co2_emissions INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Indexes:**
- `idx_vehicle_engines_model` (model_id) - Model bazlı sorgular için

**Motor Adı Formatı:**
- `"2.0 TDI 150 HP"`
- `"1.6 TSI 180 HP"`
- `"3.0 V6 300 HP"`

**Özellikler:**
- Detaylı teknik özellikler
- Performans verileri
- Yakıt tüketimi
- CO2 emisyonları

---

## 🔄 API Gateway Routing

**Dosya:** `backend/services/api-gateway/src/index.ts`

```typescript
// Catalog routes (PUBLIC - for vehicle brand/model/engine data)
app.use('/api/v1/catalog', express.json())
app.use('/api/v1/catalog', createProxyMiddleware({
  target: services.inventory,  // http://inventory-service:3003
  changeOrigin: true,
  pathRewrite: { '^/api/v1/catalog': '/catalog' },
  onError: (err, req, res) => {
    logger.error('Catalog proxy error', { error: err.message })
    if (!res.headersSent) {
      res.status(500).json({ error: 'Catalog service unavailable' })
    }
  },
  onProxyReq: fixRequestBody
}))
```

**Özellikler:**
- Public endpoint (authentication gerekmez)
- Inventory Service'e proxy edilir
- Path rewrite: `/api/v1/catalog` → `/catalog`

---

## 📊 Static Options (Frontend)

Bazı özellikler statik olarak frontend'de tanımlanmıştır (API'den çekilmez):

### Yakıt Tipleri

```typescript
const fuelTypes = ref<SelectOption[]>([
  { value: 'Benzin', label: 'Benzin' },
  { value: 'Dizel', label: 'Dizel' },
  { value: 'Elektrik', label: 'Elektrik' },
  { value: 'Hibrit', label: 'Hibrit' },
  { value: 'LPG', label: 'LPG' },
  { value: 'Benzin + LPG', label: 'Benzin + LPG' }
])
```

**Not:** Backend'de de endpoint var: `GET /catalog/fuel-types`

---

### Vites Tipleri

```typescript
const transmissions = ref<SelectOption[]>([
  { value: 'Manuel', label: 'Manuel' },
  { value: 'Otomatik', label: 'Otomatik' },
  { value: 'Yarı Otomatik', label: 'Yarı Otomatik' }
])
```

**Not:** Backend'de de endpoint var: `GET /catalog/transmissions`

---

### Kasa Tipleri

```typescript
const bodyTypes = ref<SelectOption[]>([
  { value: 'Sedan', label: 'Sedan' },
  { value: 'Hatchback', label: 'Hatchback' },
  { value: 'SUV', label: 'SUV' },
  { value: 'Coupe', label: 'Coupe' },
  { value: 'Cabrio', label: 'Cabrio' },
  { value: 'Station', label: 'Station Wagon' },
  { value: 'Pickup', label: 'Pickup' },
  { value: 'MPV', label: 'MPV' },
  { value: 'Crossover', label: 'Crossover' }
])
```

**Not:** Backend'de de endpoint var: `GET /catalog/body-types`

---

### Çekiş Tipleri

```typescript
const drivetrains = ref<SelectOption[]>([
  { value: 'Önden Çekiş', label: 'Önden Çekiş' },
  { value: 'Arkadan İtiş', label: 'Arkadan İtiş' },
  { value: '4x4 (Sürekli)', label: '4x4 (Sürekli)' },
  { value: '4x4 (Yarı Zamanlı)', label: '4x4 (Yarı Zamanlı)' },
  { value: 'AWD', label: 'AWD' }
])
```

**Not:** Backend'de de endpoint var: `GET /catalog/drivetrains`

---

### Renkler

```typescript
const colors = ref<SelectOption[]>([
  { value: 'Siyah', label: 'Siyah' },
  { value: 'Beyaz', label: 'Beyaz' },
  { value: 'Gri', label: 'Gri' },
  { value: 'Gümüş', label: 'Gümüş' },
  { value: 'Lacivert', label: 'Lacivert' },
  { value: 'Mavi', label: 'Mavi' },
  { value: 'Kırmızı', label: 'Kırmızı' },
  { value: 'Bordo', label: 'Bordo' },
  { value: 'Kahverengi', label: 'Kahverengi' },
  { value: 'Bej', label: 'Bej' },
  { value: 'Yeşil', label: 'Yeşil' },
  { value: 'Turuncu', label: 'Turuncu' },
  { value: 'Sarı', label: 'Sarı' },
  { value: 'Mor', label: 'Mor' },
  { value: 'Diğer', label: 'Diğer' }
])
```

**Not:** Backend'de de endpoint var: `GET /catalog/colors`

---

## 🎯 Kullanım Senaryoları

### Senaryo 1: Basit Araç Ekleme

```
1. Kullanıcı /vehicles/new sayfasına gider
2. Markalar yüklenir (GET /catalog/brands)
3. Kullanıcı "BMW" seçer
   → Modeller yüklenir (GET /catalog/brands/11/models)
   → Yıllar extract edilir: [2025, 2024, 2023, ...]
4. Kullanıcı "2024" seçer
   → Modeller filtrelenir: ["BMW 320i", "BMW 520i", ...]
5. Kullanıcı "BMW 320i" seçer
   → Motorlar yüklenir (GET /catalog/models/123/engines)
   → Form alanları otomatik doldurulur (body_type, year)
6. Kullanıcı "2.0 TDI 150 HP" motor seçer (opsiyonel)
   → Form alanları otomatik doldurulur:
     - enginePower: 150
     - engineCc: 1968
     - fuelType: "Dizel"
     - drivetrain: "Önden Çekiş"
     - transmission: "Manuel" (gearbox'tan parse)
7. Kullanıcı diğer alanları doldurur ve kaydeder
```

---

### Senaryo 2: Motor Seçmeden Araç Ekleme

```
1. Kullanıcı marka, yıl, model seçer
2. Motor seçmez (opsiyonel)
3. Teknik özellikleri manuel doldurur:
   - Yakıt tipi
   - Vites tipi
   - Motor gücü
   - Motor hacmi
   - Çekiş tipi
4. Formu kaydeder
```

---

## 🔍 Özel Özellikler

### 1. Yıl Extract Etme

**Problem:** Model isimleri format: `"YYYY Brand Model"`

**Çözüm:**
```typescript
// Regex ile yıl extract et
const yearMatch = model.name.match(/^(\d{4})\s+/)
if (yearMatch && yearMatch[1]) {
  const year = parseInt(yearMatch[1], 10)
  if (year >= 1900 && year <= new Date().getFullYear() + 1) {
    extractedYears.add(year)
  }
}
```

**Özellikler:**
- Regex: `/^(\d{4})\s+/` - 4 haneli yıl + boşluk
- Validation: 1900 - (şu anki yıl + 1)
- Duplicate yıllar Set ile filtrelenir

---

### 2. Model İsimlerinden Yıl Prefix'i Kaldırma

**Problem:** Model isimleri `"2025 Audi A3"` formatında, ama UI'da `"Audi A3"` gösterilmeli

**Çözüm:**
```typescript
// Yıl prefix'ini kaldır
name: model.name.replace(/^\d{4}\s+/, '')
```

**Özellikler:**
- Regex: `/^\d{4}\s+/` - Baştan 4 haneli yıl + boşluk
- Orijinal isim `original_name` olarak saklanır (form'a kaydedilir)

---

### 3. Vites Tipi Parse Etme

**Problem:** Motor verilerinde `gearbox` alanı: `"6-speed Manual"` veya `"8-speed Automatic"`

**Çözüm:**
```typescript
if (engine.gearbox) {
  const gearbox = engine.gearbox.toLowerCase()
  if (gearbox.includes('automatic') || gearbox.includes('otomatik')) {
    form.transmission = 'Otomatik'
  } else if (gearbox.includes('manual') || gearbox.includes('manuel')) {
    form.transmission = 'Manuel'
  }
}
```

**Özellikler:**
- Case-insensitive arama
- İngilizce ve Türkçe destek
- "Yarı Otomatik" parse edilmez (manuel seçilmeli)

---

## 🚀 Performans Optimizasyonları

### 1. Client-side Filtering

**Yıllar:**
- Backend'den tüm modeller gelir
- Yıllar frontend'de extract edilir
- Duplicate yıllar Set ile filtrelenir

**Modeller:**
- Backend'den tüm modeller gelir (marka bazlı)
- Seçilen yıla göre frontend'de filtrelenir
- Yıl prefix'i frontend'de kaldırılır

**Avantajlar:**
- Daha az API çağrısı
- Daha hızlı kullanıcı deneyimi
- Backend yükü azalır

**Dezavantajlar:**
- İlk yüklemede daha fazla veri transferi
- Büyük markalarda performans sorunu olabilir

---

### 2. Caching

**Frontend:**
- Markalar sayfa yüklendiğinde bir kez çekilir
- Modeller marka değiştiğinde cache'lenebilir

**Backend:**
- Redis cache eklenebilir (gelecek)
- Sık kullanılan sorgular cache'lenebilir

---

## 🐛 Hata Senaryoları

### 1. Markalar Yüklenemedi

**Durum:** API hatası veya network hatası

**Frontend:**
```typescript
catch (error: any) {
  console.error('Markalar yüklenemedi:', error)
  toast.error('Markalar yüklenemedi')
}
```

**UI:** Dropdown boş kalır, kullanıcıya hata mesajı gösterilir

---

### 2. Model İsimlerinde Yıl Yok

**Durum:** Model ismi `"2025 Audi A3"` formatında değil

**Çözüm:**
- Regex match başarısız olur
- Yıl extract edilmez
- Kullanıcı yıl seçemez (dropdown disabled)

**Alternatif:**
- Backend'de `year_start` ve `year_end` alanları kullanılabilir
- Frontend'de bu alanlar kullanılabilir

---

### 3. Motor Verileri Eksik

**Durum:** Motor seçildiğinde bazı alanlar `null`

**Çözüm:**
```typescript
// Sadece dolu alanları doldur
if (engine.power_hp) form.enginePower = engine.power_hp
if (engine.displacement_cc) form.engineCc = engine.displacement_cc
```

**UI:** Eksik alanlar kullanıcı tarafından manuel doldurulur

---

## 🔧 Geliştirme Notları

### Frontend'de Yapılacaklar

**1. Caching:**
- Markalar localStorage'da cache'lenebilir
- Modeller marka bazlı cache'lenebilir

**2. Debouncing:**
- Arama için debounce eklenebilir
- API çağrıları optimize edilebilir

**3. Error Handling:**
- Retry mekanizması
- Fallback veriler

**4. Loading States:**
- Skeleton loading
- Progressive loading

---

### Backend'de Yapılacaklar

**1. Redis Caching:**
- Markalar cache'lenebilir
- Modeller marka bazlı cache'lenebilir
- Motorlar model bazlı cache'lenebilir

**2. Query Optimization:**
- Index optimizasyonu
- EXPLAIN ANALYZE ile sorgu analizi

**3. Pagination:**
- Büyük markalarda modeller paginate edilebilir
- Arama sonuçları paginate edilebilir

**4. Full-text Search:**
- Meilisearch entegrasyonu
- Model arama iyileştirmesi

---

## 📊 API Endpoints Özeti

### Public Endpoints (Authentication Gerekmez)

| Endpoint | Method | Açıklama |
|----------|--------|----------|
| `/catalog/brands` | GET | Tüm markalar |
| `/catalog/brands/:brandId/models` | GET | Markanın modelleri |
| `/catalog/models/:modelId/engines` | GET | Modelin motorları |
| `/catalog/engines/:engineId` | GET | Motor detayları |
| `/catalog/search` | GET | Marka/model arama |
| `/catalog/fuel-types` | GET | Yakıt tipleri |
| `/catalog/transmissions` | GET | Vites tipleri |
| `/catalog/body-types` | GET | Kasa tipleri |
| `/catalog/drivetrains` | GET | Çekiş tipleri |
| `/catalog/colors` | GET | Renkler |

---

## 🔗 İlgili Dokümantasyonlar

- [VEHICLE-FETCH-ARCHITECTURE.md](./VEHICLE-FETCH-ARCHITECTURE.md) - Araç çekme yapısı
- [GALERI-PANEL.md](./GALERI-PANEL.md) - Frontend panel dokümantasyonu
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Genel mimari

---

**Son Güncelleme**: 2024-01-XX
**Versiyon**: 1.0
**Durum**: Production Ready

---

*Bu dokümantasyon canlı bir belgedir ve sistem geliştikçe güncellenecektir.*
