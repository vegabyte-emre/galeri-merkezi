# Galericiler Arası Mesajlaşma Sistemi

## 📋 Genel Bakış

Galeri Merkezi platformunda galericiler arası mesajlaşma sistemi, **WebSocket (Socket.IO)** tabanlı real-time bir chat sistemidir. Sistem, galericilerin birbirleriyle araç teklifleri, satış süreçleri ve genel iletişim için mesajlaşmasını sağlar.

---

## 🏗️ Mimari Yapı

### Teknoloji Stack

**Backend:**
- **Socket.IO** (WebSocket server)
- **Express.js** (HTTP API)
- **PostgreSQL** (Veri saklama)
- **JWT** (Authentication)

**Frontend:**
- **Socket.IO Client** (WebSocket client)
- **Axios** (HTTP API calls)

---

## 🔌 WebSocket Yapısı

### Bağlantı

**Endpoint:** `ws://localhost:3005` (Development)
**Production:** `wss://api.galerimerkezi.com` (Secure WebSocket)

**Authentication:**
- JWT token ile authentication
- Token `handshake.auth.token` veya `Authorization` header'ında gönderilir
- Token doğrulanır ve kullanıcı bilgileri socket'e eklenir

```typescript
// Authentication Flow
1. Client connects with JWT token
2. Server verifies token
3. Server extracts userId and galleryId
4. Socket authenticated and ready
```

### Room Yapısı

**Room Types:**
1. **Offer Room** (`offer`): Teklif ile ilgili sohbet
2. **Vehicle Room** (`vehicle`): Araç ile ilgili sohbet
3. **Support Room** (`support`): Destek sohbeti

**Room Organization:**
- Her room iki galeri arasında (`gallery_a_id`, `gallery_b_id`)
- Room'lar `offer_id` veya `vehicle_id` ile ilişkilendirilebilir
- Her galeri kendi room'larına erişebilir

---

## 📡 WebSocket Events

### Client → Server Events

#### 1. `join_room`
**Açıklama:** Kullanıcı bir chat room'una katılır

**Payload:**
```typescript
{
  roomId: string // UUID
}
```

**İşlem:**
- Room erişim kontrolü yapılır
- Kullanıcı `room:{roomId}` namespace'ine eklenir
- Gallery room'una da eklenir: `gallery:{galleryId}`

**Örnek:**
```javascript
socket.emit('join_room', 'room-uuid-here');
```

#### 2. `leave_room`
**Açıklama:** Kullanıcı bir chat room'undan ayrılır

**Payload:**
```typescript
{
  roomId: string
}
```

**Örnek:**
```javascript
socket.emit('leave_room', 'room-uuid-here');
```

#### 3. `typing_start`
**Açıklama:** Kullanıcı yazmaya başladığını bildirir

**Payload:**
```typescript
{
  roomId: string
}
```

**Örnek:**
```javascript
socket.emit('typing_start', { roomId: 'room-uuid' });
```

#### 4. `typing_stop`
**Açıklama:** Kullanıcı yazmayı bıraktığını bildirir

**Payload:**
```typescript
{
  roomId: string
}
```

**Örnek:**
```javascript
socket.emit('typing_stop', { roomId: 'room-uuid' });
```

---

### Server → Client Events

#### 1. `new_message`
**Açıklama:** Yeni mesaj geldiğinde gönderilir

**Payload:**
```typescript
{
  roomId: string,
  message: {
    id: string,
    room_id: string,
    sender_id: string,
    message_type: 'text' | 'file' | 'system' | 'offer_update',
    content: string,
    file_url?: string,
    file_name?: string,
    file_size?: number,
    file_type?: string,
    read_at?: string,
    read_by?: string,
    metadata?: object,
    created_at: string
  }
}
```

**Emit Edildiği Yerler:**
- `gallery:{galleryId}` - Karşı galeriye bildirim için
- `room:{roomId}` - Room'daki tüm kullanıcılara

**Örnek:**
```javascript
socket.on('new_message', (data) => {
  console.log('New message:', data.message);
  // Update UI with new message
});
```

#### 2. `user_typing`
**Açıklama:** Başka bir kullanıcı yazıyor

**Payload:**
```typescript
{
  userId: string,
  roomId: string
}
```

**Örnek:**
```javascript
socket.on('user_typing', (data) => {
  // Show typing indicator for data.userId
});
```

#### 3. `user_stopped_typing`
**Açıklama:** Kullanıcı yazmayı bıraktı

**Payload:**
```typescript
{
  userId: string,
  roomId: string
}
```

**Örnek:**
```javascript
socket.on('user_stopped_typing', (data) => {
  // Hide typing indicator for data.userId
});
```

---

## 🌐 HTTP API Endpoints

### Base URL
- **Development:** `http://localhost:3005`
- **Production:** `https://api.galerimerkezi.com/api/v1/chats`

### Authentication
Tüm endpoint'ler JWT token gerektirir:
```
Authorization: Bearer <token>
```

---

### 1. GET `/chats`
**Açıklama:** Kullanıcının tüm chat room'larını listeler

**Headers:**
```
Authorization: Bearer <token>
x-gallery-id: <gallery-id>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "room_type": "offer",
      "offer_id": "uuid",
      "vehicle_id": "uuid",
      "gallery_a_id": "uuid",
      "gallery_b_id": "uuid",
      "gallery_a_name": "Galeri A",
      "gallery_b_name": "Galeri B",
      "vehicle_brand": "BMW",
      "vehicle_model": "320i",
      "vehicle_price": 850000,
      "vehicle_title": "BMW 320i",
      "is_active": true,
      "last_message_at": "2024-01-15T10:30:00Z",
      "last_message_preview": "Merhaba, araç hakkında...",
      "unread_count": 3,
      "created_at": "2024-01-10T08:00:00Z"
    }
  ]
}
```

**Özellikler:**
- Sadece kullanıcının galerisinin room'ları
- Son mesaj tarihine göre sıralı
- Okunmamış mesaj sayısı dahil
- Galeri ve araç bilgileri join edilmiş

---

### 2. GET `/chats/:roomId`
**Açıklama:** Belirli bir room'un detaylarını ve son mesajlarını getirir

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "room_type": "offer",
    "offer_id": "uuid",
    "vehicle_id": "uuid",
    "gallery_a_id": "uuid",
    "gallery_b_id": "uuid",
    "is_active": true,
    "last_message_at": "2024-01-15T10:30:00Z",
    "last_message_preview": "Merhaba...",
    "created_at": "2024-01-10T08:00:00Z",
    "messages": [
      {
        "id": "uuid",
        "room_id": "uuid",
        "sender_id": "uuid",
        "first_name": "Ahmet",
        "last_name": "Yılmaz",
        "message_type": "text",
        "content": "Merhaba, araç hakkında bilgi alabilir miyim?",
        "read_at": null,
        "read_by": null,
        "created_at": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

**Özellikler:**
- Son 50 mesaj dahil
- Gönderen kullanıcı bilgileri join edilmiş
- Mesajlar tarih sırasına göre (en eski → en yeni)

---

### 3. POST `/chats`
**Açıklama:** Yeni bir chat room oluşturur

**Request Body:**
```json
{
  "roomType": "offer" | "vehicle" | "support",
  "offerId": "uuid", // offer room için
  "vehicleId": "uuid", // vehicle room için
  "otherGalleryId": "uuid" // Opsiyonel, otomatik belirlenebilir
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "room_type": "offer",
    "offer_id": "uuid",
    "vehicle_id": null,
    "gallery_a_id": "uuid",
    "gallery_b_id": "uuid",
    "is_active": true,
    "created_at": "2024-01-15T10:00:00Z"
  }
}
```

**Özellikler:**
- Eğer room zaten varsa, mevcut room ID'si döner
- Gallery ID'ler otomatik belirlenir (offer/vehicle'dan)
- Aynı galeri ile room oluşturulamaz

---

### 4. GET `/chats/:roomId/messages`
**Açıklama:** Room'daki mesajları sayfalama ile getirir

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 50)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "room_id": "uuid",
      "sender_id": "uuid",
      "first_name": "Ahmet",
      "last_name": "Yılmaz",
      "message_type": "text",
      "content": "Mesaj içeriği",
      "read_at": "2024-01-15T10:35:00Z",
      "read_by": "uuid",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 150,
    "totalPages": 3
  }
}
```

**Özellikler:**
- Mesajlar en eski → en yeni sıralı
- Pagination desteği
- Gönderen bilgileri dahil

---

### 5. POST `/chats/:roomId/messages`
**Açıklama:** Yeni mesaj gönderir

**Request Body:**
```json
{
  "content": "Mesaj içeriği",
  "messageType": "text" | "file" | "system" | "offer_update",
  "metadata": {} // Opsiyonel, ek bilgiler
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "room_id": "uuid",
    "sender_id": "uuid",
    "message_type": "text",
    "content": "Mesaj içeriği",
    "read_at": null,
    "read_by": null,
    "metadata": null,
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**Özellikler:**
- Mesaj veritabanına kaydedilir
- Room'un `last_message_at` güncellenir
- WebSocket ile real-time bildirim gönderilir
- Karşı galeriye `new_message` event'i emit edilir

---

### 6. POST `/chats/:roomId/read`
**Açıklama:** Room'daki tüm mesajları okundu işaretler

**Response:**
```json
{
  "success": true,
  "message": "All messages marked as read"
}
```

**Özellikler:**
- Sadece karşı tarafın mesajları okundu işaretlenir
- `read_at` ve `read_by` güncellenir

---

### 7. PUT `/chats/:roomId/messages/:id/read`
**Açıklama:** Belirli bir mesajı okundu işaretler

**Response:**
```json
{
  "success": true,
  "message": "Message marked as read"
}
```

---

### 8. POST `/chats/:roomId/upload`
**Açıklama:** Dosya gönderir (görsel, PDF, vb.)

**Request Body:**
```json
{
  "fileUrl": "https://minio.../file.jpg",
  "fileName": "arac-goruntusu.jpg",
  "fileSize": 1024000,
  "fileType": "image/jpeg"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "room_id": "uuid",
    "sender_id": "uuid",
    "message_type": "file",
    "file_url": "https://minio.../file.jpg",
    "file_name": "arac-goruntusu.jpg",
    "file_size": 1024000,
    "file_type": "image/jpeg",
    "content": null,
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**Özellikler:**
- Dosya URL'i MinIO'dan gelir
- `message_type` otomatik `file` olur
- Room'un `last_message_preview` güncellenir

---

### 9. DELETE `/chats/:roomId`
**Açıklama:** Room'u siler (soft delete)

**Response:**
```json
{
  "success": true,
  "message": "Room deleted successfully"
}
```

**Özellikler:**
- Soft delete: `is_active = false`
- Mesajlar silinmez (opsiyonel olarak silinebilir)

---

## 💾 Veritabanı Yapısı

### `chat_rooms` Tablosu

```sql
CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY,
    room_type VARCHAR(20) NOT NULL, -- 'offer', 'vehicle', 'support'
    offer_id UUID REFERENCES offers(id),
    vehicle_id UUID REFERENCES vehicles(id),
    gallery_a_id UUID NOT NULL REFERENCES galleries(id),
    gallery_b_id UUID NOT NULL REFERENCES galleries(id),
    is_active BOOLEAN DEFAULT TRUE,
    closed_at TIMESTAMP,
    last_message_at TIMESTAMP,
    last_message_preview VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

**Indexes:**
- `idx_chat_rooms_offer` (offer_id)
- `idx_chat_rooms_vehicle` (vehicle_id)
- `idx_chat_rooms_gallery_a` (gallery_a_id)
- `idx_chat_rooms_gallery_b` (gallery_b_id)
- `idx_chat_rooms_active` (is_active, last_message_at DESC)

---

### `chat_messages` Tablosu

```sql
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY,
    room_id UUID NOT NULL REFERENCES chat_rooms(id),
    sender_id UUID NOT NULL REFERENCES users(id),
    message_type VARCHAR(20) NOT NULL, -- 'text', 'file', 'system', 'offer_update'
    content TEXT,
    file_url VARCHAR(500),
    file_name VARCHAR(255),
    file_size INTEGER,
    file_type VARCHAR(100),
    read_at TIMESTAMP,
    read_by UUID REFERENCES users(id),
    metadata JSONB,
    created_at TIMESTAMP
);
```

**Indexes:**
- `idx_chat_messages_room` (room_id)
- `idx_chat_messages_sender` (sender_id)
- `idx_chat_messages_created` (created_at DESC)
- `idx_chat_messages_unread` (room_id, read_at) WHERE read_at IS NULL

---

## 🔐 Güvenlik

### Authentication

1. **JWT Token:**
   - Tüm HTTP istekleri JWT token gerektirir
   - Token `Authorization` header'ında gönderilir
   - WebSocket bağlantıları da JWT ile authenticate edilir

2. **Room Access Control:**
   - Kullanıcı sadece kendi galerisinin room'larına erişebilir
   - Her istekte room erişim kontrolü yapılır
   - `gallery_a_id` veya `gallery_b_id` kontrolü

3. **Message Ownership:**
   - Kullanıcı sadece kendi galerisinin room'larında mesaj gönderebilir
   - Mesaj gönderen bilgisi kaydedilir

---

## 📱 Frontend Entegrasyonu

### Socket.IO Client Setup

```typescript
import { io } from 'socket.io-client';

const socket = io('ws://localhost:3005', {
  auth: {
    token: 'your-jwt-token'
  },
  transports: ['websocket']
});

// Connection events
socket.on('connect', () => {
  console.log('Connected to chat server');
});

socket.on('disconnect', () => {
  console.log('Disconnected from chat server');
});

// Join room
socket.emit('join_room', 'room-uuid');

// Listen for new messages
socket.on('new_message', (data) => {
  console.log('New message:', data.message);
  // Update UI
});

// Typing indicator
socket.on('user_typing', (data) => {
  // Show typing indicator
});

// Send typing event
socket.emit('typing_start', { roomId: 'room-uuid' });
```

---

## 🔄 Mesajlaşma Akışı

### 1. Room Oluşturma

```
1. Kullanıcı bir araç/teklif üzerinden mesaj göndermek ister
2. POST /chats ile room oluşturulur (veya mevcut room döner)
3. Room ID alınır
4. WebSocket ile room'a join edilir
```

### 2. Mesaj Gönderme

```
1. Kullanıcı mesaj yazar
2. POST /chats/:roomId/messages ile mesaj gönderilir
3. Mesaj veritabanına kaydedilir
4. WebSocket ile karşı tarafa new_message event'i gönderilir
5. Room'un last_message_at güncellenir
```

### 3. Mesaj Alma

```
1. WebSocket'ten new_message event'i alınır
2. Mesaj UI'a eklenir
3. Okunmamış sayısı güncellenir
4. Push notification gönderilir (opsiyonel)
```

### 4. Okundu İşaretleme

```
1. Kullanıcı mesajları görüntüler
2. POST /chats/:roomId/read ile tüm mesajlar okundu işaretlenir
3. read_at ve read_by güncellenir
4. Karşı tarafa bildirim gönderilebilir (opsiyonel)
```

---

## 🎯 Özellikler

### Mevcut Özellikler

✅ **Real-time Mesajlaşma**
- WebSocket ile anlık mesaj gönderme/alma
- Typing indicator
- Online durumu

✅ **Room Yönetimi**
- Offer-based rooms
- Vehicle-based rooms
- Support rooms

✅ **Mesaj Türleri**
- Text messages
- File messages (görsel, PDF, vb.)
- System messages
- Offer update messages

✅ **Okundu Bilgisi**
- Read receipts
- Okunmamış mesaj sayısı
- Toplu okundu işaretleme

✅ **Güvenlik**
- JWT authentication
- Room access control
- Gallery isolation

---

## 🚀 Gelecek Özellikler

### Planlanan Özellikler

🔲 **Push Notifications**
- Yeni mesaj bildirimleri
- Background notification handling

🔲 **Mesaj Arama**
- Room içinde mesaj arama
- Tüm mesajlarda arama

🔲 **Mesaj Düzenleme/Silme**
- Gönderilen mesajları düzenleme
- Mesaj silme (kendi mesajlarını)

🔲 **Medya Paylaşımı**
- Görsel galeri
- Video paylaşımı
- Doküman paylaşımı

🔲 **Mesaj Tepkileri**
- Emoji reactions
- Mesaj beğenme

🔲 **Sesli Mesaj**
- Voice message recording
- Audio playback

---

## 📊 Performans Optimizasyonları

### Mevcut Optimizasyonlar

1. **Database Indexes:**
   - Room ve mesaj sorguları için indexler
   - Unread messages için özel index

2. **Pagination:**
   - Mesajlar sayfalama ile getirilir
   - İlk yüklemede son 50 mesaj

3. **WebSocket Efficiency:**
   - Room-based broadcasting
   - Gallery-based notifications

### Önerilen Optimizasyonlar

1. **Message Caching:**
   - Redis ile son mesajlar cache'lenebilir
   - Sık kullanılan room'lar cache'lenebilir

2. **Lazy Loading:**
   - Eski mesajlar scroll ile yüklenir
   - Infinite scroll implementasyonu

3. **Connection Pooling:**
   - WebSocket connection pooling
   - Reconnection handling

---

## 🐛 Hata Yönetimi

### Common Errors

**401 Unauthorized:**
- JWT token geçersiz veya eksik
- Çözüm: Token'ı yenile

**403 Forbidden:**
- Room erişim yetkisi yok
- Çözüm: Room ID'yi kontrol et

**404 Not Found:**
- Room bulunamadı
- Çözüm: Room ID'yi kontrol et

**500 Internal Server Error:**
- Sunucu hatası
- Çözüm: Logları kontrol et, support'a bildir

---

## 📝 Örnek Kullanım Senaryoları

### Senaryo 1: Teklif Üzerinden Mesajlaşma

```
1. Galeri A, Galeri B'ye teklif gönderir
2. Teklif oluşturulurken otomatik room oluşturulur
3. Galeri B teklifi görüntüler
4. Galeri B room'a join eder
5. Galeri B mesaj gönderir: "Teklifinizi değerlendiriyorum"
6. Galeri A real-time mesajı alır
7. İki galeri arasında mesajlaşma devam eder
```

### Senaryo 2: Araç Hakkında Soru Sorma

```
1. Galeri A bir araç görüntüler
2. "Mesaj Gönder" butonuna tıklar
3. Room oluşturulur (vehicle-based)
4. Galeri A mesaj gönderir: "Araç hakkında bilgi alabilir miyim?"
5. Araç sahibi galeri (Galeri B) mesajı alır
6. Galeri B yanıt verir
7. İletişim devam eder
```

---

## 🔗 İlgili Dokümantasyon

- [API Gateway Routing](../backend/services/api-gateway/src/index.ts)
- [Database Migrations](../database/migrations/)
- [WebSocket Implementation](../backend/services/chat-service/src/websocket.ts)

---

**Son Güncelleme**: 2024-01-XX
**Versiyon**: 1.0
**Durum**: Production Ready

---

*Bu dokümantasyon canlı bir belgedir ve sistem geliştikçe güncellenecektir.*
