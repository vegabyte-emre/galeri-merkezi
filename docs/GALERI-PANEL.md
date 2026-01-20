# Galeri Paneli - Teknik Dokümantasyon

## 📋 Genel Bakış

Galeri Paneli, galericilerin işlerini yönetmeleri için geliştirilmiş modern bir web uygulamasıdır. SPA (Single Page Application) mimarisi ile çalışır ve gerçek zamanlı özellikler sunar.

**URL:** `http://localhost:3002` (Development)

---

## 🛠️ Teknoloji Stack

### Frontend Framework

**Nuxt.js 3**
- Versiyon: 3.9.0+
- SSR: **Kapalı** (SPA mode)
- Routing: File-based routing
- Auto-imports: Aktif

### Core Technologies

**Vue 3**
- Composition API
- Reactive state management
- TypeScript desteği

**Tailwind CSS**
- Versiyon: 6.12.0+
- Utility-first CSS framework
- Dark mode desteği
- Custom configuration

**Pinia**
- Versiyon: 2.1.7+
- State management
- Store pattern

**VueUse**
- Versiyon: 10.7.0+
- Composition utilities
- Reactive utilities

### UI Libraries

**Headless UI**
- Versiyon: 1.7.16+
- Unstyled, accessible components

**Lucide Vue Next**
- Versiyon: 0.303.0+
- Icon library
- 1000+ icons

### Real-time Communication

**Socket.IO Client**
- Versiyon: 4.6.1+
- WebSocket bağlantısı
- Real-time mesajlaşma

---

## 🎨 Arayüz ve Tasarım

### Tasarım Sistemi

**Renk Paleti:**
- Primary: Gradient (Primary-500 → Primary-600)
- Background: Gray-50 → Gray-100 (Light), Gray-900 → Gray-800 (Dark)
- Text: Gray-900 (Light), White (Dark)
- Accent: Emerald, Blue, Green, Orange, Purple

**Tipografi:**
- Font Family: System fonts (SF Pro, Roboto)
- Headings: Bold, 2xl-3xl
- Body: Regular, base size
- Small: xs-sm

**Spacing:**
- Tailwind spacing scale (4px base)
- Consistent padding/margin

**Border Radius:**
- Small: lg (12px)
- Medium: xl (16px)
- Large: 2xl (24px)

### Layout Yapısı

**Sidebar Navigation:**
- Fixed left sidebar (256px width)
- Collapsible (mobile)
- Logo ve branding
- Navigation items
- User section (bottom)

**Top Bar:**
- Sticky header
- Page title ve subtitle
- Notifications icon
- Quick actions (Yeni Araç butonu)

**Main Content:**
- Responsive grid layouts
- Card-based design
- Gradient backgrounds
- Shadow effects

### Dark Mode

**Özellikler:**
- System preference detection
- Manual toggle (sidebar)
- LocalStorage persistence
- Smooth transitions
- Full theme support

**Implementation:**
```typescript
// Theme toggle
const toggleDarkMode = () => {
  isDark.value = !isDark.value
  applyTheme(isDark.value)
}
```

---

## 📱 Sayfalar ve Özellikler

### 1. Dashboard (`/`)

**Özellikler:**
- Hoş geldiniz banner (gradient)
- İstatistik kartları (4 adet):
  - Toplam Araç
  - Aktif Teklif
  - Okunmamış Mesaj
  - Bu Ay Satış
- Grafikler (placeholder):
  - Satış Trendi
  - Teklif Durumu
- Son Eklenen Araçlar (list)
- Hızlı İşlemler:
  - Yeni Araç Ekle
  - Toplu Yükleme
  - Rapor İndir
  - Ayarlar
- Son Teklifler (list)

**API Endpoints:**
- `GET /dashboard` - Dashboard verileri
- `GET /vehicles?limit=5` - Son araçlar
- `GET /offers?limit=5` - Son teklifler

---

### 2. Oto Pazarı (`/marketplace`)

**Özellikler:**
- Tüm galerilerin araçlarını görüntüleme
- Arama ve filtreleme:
  - Marka, model
  - Şehir
  - Fiyat aralığı
  - Yıl aralığı
  - Yakıt tipi
  - Vites tipi
- Sıralama:
  - En yeni
  - En eski
  - Fiyat (artan/azalan)
- Grid/List view toggle
- Pagination
- Araç kartları:
  - Görsel
  - Marka, model, yıl
  - Fiyat
  - Kilometre
  - Durum badge
  - Hızlı aksiyonlar (Mesaj Gönder, Teklif Yap)

**API Endpoints:**
- `GET /marketplace` - Araç listesi
- `POST /chat` - Mesaj gönderme (room oluşturma)

---

### 3. Araçlarım (`/vehicles`)

**Özellikler:**
- Araç listesi (grid layout)
- Arama (marka, model, plaka)
- Durum filtreleme:
  - Tüm Durumlar
  - Yayında
  - Taslak
  - Duraklatıldı
  - Arşivlendi
  - Satıldı
- Araç kartları:
  - Görsel (placeholder)
  - Marka, model
  - Yıl, kilometre, fiyat
  - Durum badge
  - Aksiyonlar (Düzenle, Sil)
- Yeni araç ekleme butonu

**Alt Sayfalar:**
- `/vehicles/new` - Yeni araç ekleme
- `/vehicles/[id]` - Araç detayı
- `/vehicles/[id]/edit` - Araç düzenleme
- `/vehicles/bulk` - Toplu yükleme
- `/vehicles/filters` - Gelişmiş filtreler

**API Endpoints:**
- `GET /vehicles` - Araç listesi
- `GET /vehicles/:id` - Araç detayı
- `POST /vehicles` - Yeni araç
- `PUT /vehicles/:id` - Araç güncelleme
- `DELETE /vehicles/:id` - Araç silme

---

### 4. Teklifler (`/offers`)

**Özellikler:**
- Tab navigation:
  - Gelen Teklifler
  - Giden Teklifler
- Teklif kartları:
  - Araç bilgisi
  - Gönderen/Alıcı galeri
  - Teklif fiyatı
  - Araç fiyatı
  - Durum badge
  - Mesaj (varsa)
- Aksiyonlar:
  - Kabul Et
  - Reddet
  - Karşı Teklif
  - Mesaj Gönder
- Teklif detayı (modal veya sayfa)

**API Endpoints:**
- `GET /offers` - Teklif listesi
- `GET /offers/:id` - Teklif detayı
- `POST /offers` - Yeni teklif
- `PUT /offers/:id/accept` - Teklif kabul
- `PUT /offers/:id/reject` - Teklif reddet
- `POST /offers/:id/counter` - Karşı teklif

---

### 5. Mesajlar (`/chats`)

**Özellikler:**
- Real-time mesajlaşma (WebSocket)
- Chat listesi (sol panel):
  - Galeri avatar'ları
  - Online durumu
  - Son mesaj önizleme
  - Okunmamış mesaj sayısı
  - Araç bilgisi (varsa)
  - Arama
- Mesaj ekranı (sağ panel):
  - Mesaj bubble'ları
  - Tarih ayırıcıları
  - Okundu işaretleri
  - Typing indicator
  - Emoji picker
  - Dosya ekleme (hazırlık aşamasında)
- Responsive (mobile/desktop)

**WebSocket Events:**
- `join_room` - Room'a katılma
- `leave_room` - Room'dan ayrılma
- `typing_start` - Yazmaya başlama
- `typing_stop` - Yazmayı bırakma
- `new_message` - Yeni mesaj
- `user_typing` - Kullanıcı yazıyor

**API Endpoints:**
- `GET /chats` - Room listesi
- `GET /chats/:roomId` - Room detayı
- `GET /chats/:roomId/messages` - Mesajlar
- `POST /chats/:roomId/messages` - Mesaj gönder
- `POST /chats/:roomId/read` - Okundu işaretle

**Detaylı bilgi:** [CHAT-SYSTEM.md](./CHAT-SYSTEM.md)

---

### 6. Favoriler (`/favorites`)

**Özellikler:**
- Favoriye eklenen araçlar listesi
- Grid/List view
- Filtreleme ve sıralama
- Favori ekleme/çıkarma

**API Endpoints:**
- `GET /favorites` - Favori listesi
- `POST /favorites/:vehicleId` - Favori ekle
- `DELETE /favorites/:vehicleId` - Favori çıkar

---

### 7. Raporlar (`/reports`)

**Özellikler:**
- Satış raporları
- Envanter raporları
- Teklif analizi
- Grafik görüntüleme (placeholder)
- PDF/Excel export

**API Endpoints:**
- `GET /reports/sales` - Satış raporları
- `GET /reports/inventory` - Envanter raporları
- `GET /reports/offers` - Teklif raporları
- `GET /reports/export` - Rapor export

---

### 8. Kanallar (`/channels`)

**Özellikler:**
- Bağlı kanallar listesi (Sahibinden, Arabam, vb.)
- Kanal durumu
- Senkronizasyon durumu
- Kanal ayarları
- Toplu senkronizasyon

**API Endpoints:**
- `GET /channels` - Kanal listesi
- `GET /channels/:id` - Kanal detayı
- `POST /channels/:id/sync` - Senkronizasyon

---

### 9. Aktivite (`/activity`)

**Özellikler:**
- Tüm işlemlerin kaydı
- Filtreleme (tarih, tip, kullanıcı)
- Detaylı log görüntüleme
- Export

**API Endpoints:**
- `GET /activity` - Aktivite listesi
- `GET /activity/:id` - Aktivite detayı

---

### 10. Medya (`/media`)

**Özellikler:**
- Medya kütüphanesi
- Görsel yönetimi
- Upload/Delete
- Kategorilendirme
- Arama

**API Endpoints:**
- `GET /media` - Medya listesi
- `POST /media` - Medya yükleme
- `DELETE /media/:id` - Medya silme

---

### 11. Bildirimler (`/notifications`)

**Özellikler:**
- Bildirim listesi
- Okunmamış/okunmuş ayrımı
- Kategori filtreleme
- Toplu okundu işaretleme
- Bildirim detayı

**API Endpoints:**
- `GET /notifications` - Bildirim listesi
- `PUT /notifications/:id/read` - Okundu işaretle
- `POST /notifications/read-all` - Tümünü okundu işaretle

---

### 12. Yardım (`/help`)

**Özellikler:**
- FAQ (Sık Sorulan Sorular)
- Kullanım kılavuzu
- Video tutorial'lar
- Destek iletişim

---

### 13. Ayarlar (`/settings`)

**Özellikler:**
- Galeri bilgileri
- Kullanıcı profili
- Bildirim tercihleri
- Güvenlik ayarları
- Entegrasyonlar

**API Endpoints:**
- `GET /user` - Kullanıcı bilgileri
- `PUT /user` - Kullanıcı güncelleme
- `GET /galleries/:id` - Galeri bilgileri
- `PUT /galleries/:id` - Galeri güncelleme

---

### 14. Login (`/login`)

**Özellikler:**
- Email/Telefon ile giriş
- Şifre girişi
- "Şifremi Unuttum" linki
- Hata mesajları
- Redirect (zaten giriş yapılmışsa)

**API Endpoints:**
- `POST /auth/login` - Giriş
- `POST /auth/logout` - Çıkış

---

## 🔧 Composables

### useApi

**Açıklama:** HTTP istekleri için composable

**Kullanım:**
```typescript
const api = useApi()

// GET request
const data = await api.get('/vehicles')

// POST request
const result = await api.post('/vehicles', { brand: 'BMW', model: '320i' })

// PUT request
await api.put('/vehicles/123', { price: 850000 })

// DELETE request
await api.delete('/vehicles/123')
```

**Özellikler:**
- JWT token otomatik ekleme
- Error handling
- Timeout (30 saniye)
- Blob response desteği
- Query parameters

---

### useWebSocket

**Açıklama:** WebSocket bağlantısı için composable

**Kullanım:**
```typescript
const { connect, disconnect, joinRoom, leaveRoom, send, on, isConnected } = useWebSocket()

// Bağlan
connect()

// Room'a katıl
joinRoom('room-id')

// Event dinle
on('new_message', (data) => {
  console.log('New message:', data)
})

// Event gönder
send('typing_start', { roomId: 'room-id' })
```

**Özellikler:**
- JWT authentication
- Auto-reconnect
- Event management
- Connection state

**Detaylı bilgi:** [CHAT-SYSTEM.md](./CHAT-SYSTEM.md)

---

### useToast

**Açıklama:** Toast notification için composable

**Kullanım:**
```typescript
const toast = useToast()

toast.success('İşlem başarılı!')
toast.error('Bir hata oluştu')
toast.info('Bilgilendirme')
toast.warning('Uyarı')
```

---

## 🗄️ State Management (Pinia)

### Auth Store

**Store:** `stores/auth.ts`

**State:**
```typescript
{
  user: null,
  gallery: null,
  token: null
}
```

**Getters:**
- `isAuthenticated` - Giriş yapılmış mı?
- `galleryId` - Galeri ID

**Actions:**
- `setUser(user)` - Kullanıcı bilgilerini ayarla
- `setGallery(gallery)` - Galeri bilgilerini ayarla
- `setToken(token)` - Token'ı ayarla
- `logout()` - Çıkış yap

**Kullanım:**
```typescript
const authStore = useAuthStore()

// State'e erişim
const isAuth = authStore.isAuthenticated
const galleryId = authStore.galleryId

// Action çağırma
authStore.setUser(userData)
authStore.logout()
```

---

## 🔐 Authentication

### Middleware

**Dosya:** `middleware/auth.ts`

**Özellikler:**
- Tüm sayfalar için auth kontrolü
- Login sayfası için özel kontrol
- Token kontrolü (cookie)
- Otomatik redirect

**Kullanım:**
```typescript
// Sayfa meta'da
definePageMeta({
  middleware: ['auth']
})
```

### Token Yönetimi

**Storage:** Cookie (`auth_token`)

**Kullanım:**
```typescript
const token = useCookie('auth_token')

// Token'ı ayarla
token.value = 'jwt-token-here'

// Token'ı oku
const currentToken = token.value

// Token'ı sil
token.value = null
```

---

## 📡 API Entegrasyonu

### Base URL

**Development:**
```
http://localhost:8000/api/v1
```

**Production:**
```
https://api.Otobia.com/api/v1
```

### Configuration

**nuxt.config.ts:**
```typescript
runtimeConfig: {
  public: {
    apiUrl: process.env.NUXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1',
    wsUrl: process.env.NUXT_PUBLIC_WS_URL || 'http://localhost:3005'
  }
}
```

### Request Headers

**Otomatik Eklenen:**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`

### Error Handling

**API Errors:**
- 401: Unauthorized → Login'e yönlendir
- 403: Forbidden → Hata mesajı göster
- 404: Not Found → Hata mesajı göster
- 500: Server Error → Hata mesajı göster

---

## 🎯 Özellikler

### Real-time Updates

**WebSocket:**
- Mesajlaşma (real-time)
- Typing indicators
- Online durumu
- Bildirimler (gelecek)

### Responsive Design

**Breakpoints:**
- Mobile: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px

**Adaptive Features:**
- Sidebar collapse (mobile)
- Grid → List view (mobile)
- Touch-friendly buttons
- Mobile navigation

### Dark Mode

**Özellikler:**
- System preference detection
- Manual toggle
- LocalStorage persistence
- Smooth transitions
- Full theme support

### Performance

**Optimizations:**
- Lazy loading (components)
- Code splitting
- Image optimization
- Caching strategies

---

## 🎨 UI Components

### Custom Components

**ToastContainer:**
- Toast notification container
- Auto-dismiss
- Multiple types (success, error, info, warning)

### Headless UI Components

**Kullanılan:**
- Dialog (modal)
- Menu (dropdown)
- Transition (animations)

### Icon System

**Lucide Vue Next:**
- 1000+ icons
- Tree-shakeable
- Customizable size/color

**Kullanım:**
```vue
<template>
  <Car class="w-5 h-5 text-gray-600" />
</template>

<script setup>
import { Car } from 'lucide-vue-next'
</script>
```

---

## 📦 Build ve Deployment

### Development

```bash
cd frontend/panel
npm install
npm run dev
```

**URL:** `http://localhost:3002`

### Production Build

```bash
npm run build
npm run preview
```

### Docker

**Dockerfile.dev:**
- Development container
- Hot reload
- Volume mounting

**Dockerfile:**
- Production container
- Optimized build
- Nginx serving

---

## 🔄 Routing

### File-based Routing

**Yapı:**
```
pages/
  index.vue          → /
  login.vue          → /login
  vehicles/
    index.vue        → /vehicles
    new.vue          → /vehicles/new
    [id]/
      index.vue      → /vehicles/:id
      edit.vue       → /vehicles/:id/edit
```

### Navigation Guards

**Middleware:**
- `auth.ts` - Authentication kontrolü
- Sayfa bazlı middleware

---

## 🎭 Animations

### Transitions

**Vue Transitions:**
- Fade
- Slide
- Scale
- Custom animations

**Kullanım:**
```vue
<Transition name="fade">
  <div v-if="show">Content</div>
</Transition>
```

### CSS Animations

**Keyframes:**
- Fade in up
- Slide in
- Bounce
- Pulse

---

## 📊 Sidebar Navigation

### Navigation Items

**Items:**
1. Dashboard (`/`)
2. Oto Pazarı (`/marketplace`) - Highlight: Orange
3. Araçlarım (`/vehicles`) - Badge: Count
4. Teklifler (`/offers`) - Badge: Pending count
5. Mesajlar (`/chats`) - Badge: Unread count
6. Favoriler (`/favorites`)
7. Raporlar (`/reports`)
8. Kanallar (`/channels`)
9. Aktivite (`/activity`)
10. Medya (`/media`)
11. Bildirimler (`/notifications`) - Badge: Unread count
12. Yardım (`/help`)
13. Ayarlar (`/settings`)

### Dynamic Badges

**Auto-update:**
- Her 30 saniyede bir güncellenir
- API'den count'lar çekilir
- Real-time güncellemeler

---

## 🎨 Styling

### Tailwind Configuration

**Custom Colors:**
- Primary (gradient)
- Accent colors
- Status colors

**Custom Utilities:**
- Gradient backgrounds
- Shadow effects
- Border radius

### CSS Custom Properties

**Dark Mode:**
- CSS variables
- Theme switching
- Smooth transitions

---

## 🚀 Özellik Roadmap

### Mevcut Özellikler ✅

- ✅ Dashboard
- ✅ Oto Pazarı
- ✅ Araç Yönetimi
- ✅ Teklif Yönetimi
- ✅ Real-time Mesajlaşma
- ✅ Favoriler
- ✅ Bildirimler
- ✅ Dark Mode
- ✅ Responsive Design

### Gelecek Özellikler 🔲

- 🔲 Gelişmiş Raporlar (Grafikler)
- 🔲 Toplu Araç Yükleme (Excel)
- 🔲 Görsel Yükleme/Düzenleme
- 🔲 Push Notifications
- 🔲 Offline Support
- 🔲 Multi-language (i18n)
- 🔲 Advanced Search
- 🔲 Export/Import

---

## 📝 Best Practices

### Code Organization

**Yapı:**
```
frontend/panel/
├── pages/          # Routes
├── components/     # Reusable components
├── composables/    # Composition functions
├── stores/         # Pinia stores
├── layouts/        # Layout components
├── middleware/     # Route middleware
└── assets/         # Static assets
```

### Naming Conventions

**Files:**
- Components: PascalCase (`VehicleCard.vue`)
- Composables: camelCase (`useApi.ts`)
- Pages: kebab-case (`vehicles/index.vue`)

**Variables:**
- camelCase (`selectedChatId`)
- Constants: UPPER_SNAKE_CASE (`API_URL`)

---

## 🐛 Debugging

### DevTools

**Nuxt DevTools:**
- Component inspector
- Performance profiler
- State inspector

### Console Logging

**Development:**
- API requests/responses
- WebSocket events
- State changes

---

## 📚 Kaynaklar

### Dokümantasyon

- [Nuxt.js Docs](https://nuxt.com)
- [Vue 3 Docs](https://vuejs.org)
- [Tailwind CSS Docs](https://tailwindcss.com)
- [Pinia Docs](https://pinia.vuejs.org)
- [Socket.IO Docs](https://socket.io/docs)

### İlgili Dokümantasyonlar

- [CHAT-SYSTEM.md](./CHAT-SYSTEM.md) - Mesajlaşma sistemi
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Genel mimari

---

**Son Güncelleme**: 2024-01-XX
**Versiyon**: 1.0
**Durum**: Production Ready

---

*Bu dokümantasyon canlı bir belgedir ve sistem geliştikçe güncellenecektir.*
