<template>
  <div class="space-y-6">
    <!-- Search & Filters Header -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <!-- Search -->
        <div class="md:col-span-2">
          <div class="relative">
            <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Marka, model veya anahtar kelime ara..."
              class="w-full pl-12 pr-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              @keyup.enter="applyFilters"
            />
          </div>
        </div>
        <!-- Brand Filter -->
        <select
          v-model="filters.brand"
          class="px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500"
        >
          <option value="">Tüm Markalar</option>
          <option v-for="brand in availableBrands" :key="brand" :value="brand">{{ brand }}</option>
        </select>
        <!-- City Filter -->
        <select
          v-model="filters.city"
          class="px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500"
        >
          <option value="">Tüm İller</option>
          <option v-for="city in availableCities" :key="city" :value="city">{{ city }}</option>
        </select>
      </div>
      
      <!-- Advanced Filters -->
      <div class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between mb-4">
          <button
            @click="showAdvancedFilters = !showAdvancedFilters"
            class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400"
          >
            <Filter class="w-4 h-4" />
            Gelişmiş Filtreler
            <ChevronDown :class="['w-4 h-4 transition-transform', showAdvancedFilters && 'rotate-180']" />
          </button>
          <div class="flex items-center gap-3">
            <button
              @click="resetFilters"
              class="text-sm text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
            >
              Temizle
            </button>
            <button
              @click="applyFilters"
              class="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors flex items-center gap-2"
            >
              <Search class="w-4 h-4" />
              Ara
            </button>
          </div>
        </div>
        
        <div v-if="showAdvancedFilters" class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
          <!-- Price Range -->
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Min Fiyat</label>
            <input
              v-model.number="filters.minPrice"
              type="number"
              placeholder="0"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
            />
          </div>
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Max Fiyat</label>
            <input
              v-model.number="filters.maxPrice"
              type="number"
              placeholder="10000000"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
            />
          </div>
          <!-- Year Range -->
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Min Yıl</label>
            <input
              v-model.number="filters.minYear"
              type="number"
              placeholder="2000"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
            />
          </div>
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Max Yıl</label>
            <input
              v-model.number="filters.maxYear"
              type="number"
              placeholder="2024"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
            />
          </div>
          <!-- Fuel Type -->
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Yakıt</label>
            <select
              v-model="filters.fuelType"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
            >
              <option value="">Tümünü Göster</option>
              <option value="benzin">Benzin</option>
              <option value="dizel">Dizel</option>
              <option value="elektrik">Elektrik</option>
              <option value="hibrit">Hibrit</option>
              <option value="lpg">LPG</option>
            </select>
          </div>
          <!-- Transmission -->
          <div>
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Vites</label>
            <select
              v-model="filters.transmission"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
            >
              <option value="">Tümünü Göster</option>
              <option value="manuel">Manuel</option>
              <option value="otomatik">Otomatik</option>
              <option value="yari_otomatik">Yarı Otomatik</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Results Header -->
    <div class="flex items-center justify-between">
      <p class="text-gray-600 dark:text-gray-400">
        <span class="font-bold text-gray-900 dark:text-white">{{ pagination.total }}</span> araç bulundu
      </p>
      <select
        v-model="sortBy"
        @change="applyFilters"
        class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
      >
        <option value="newest">En Yeni</option>
        <option value="price_asc">Fiyat (Düşükten Yükseğe)</option>
        <option value="price_desc">Fiyat (Yüksekten Düşüğe)</option>
        <option value="year_desc">Model Yılı (Yeni)</option>
        <option value="mileage_asc">Kilometre (Düşük)</option>
      </select>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <div v-for="i in 6" :key="i" class="bg-gray-200 dark:bg-gray-700 rounded-2xl h-[400px] animate-pulse"></div>
    </div>

    <!-- Vehicle Grid -->
    <div v-else-if="vehicles.length > 0" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <div
        v-for="vehicle in vehicles"
        :key="vehicle.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-xl transition-all duration-300 group"
      >
        <!-- Image -->
        <div class="relative h-48 bg-gray-100 dark:bg-gray-700 overflow-hidden">
          <img
            v-if="vehicle.primary_image"
            :src="vehicle.primary_image"
            :alt="vehicle.brand + ' ' + vehicle.model"
            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          />
          <div v-else class="w-full h-full flex items-center justify-center">
            <Car class="w-16 h-16 text-gray-300 dark:text-gray-600" />
          </div>
          <!-- Badges -->
          <div class="absolute top-3 left-3 flex gap-2">
            <span v-if="vehicle.has_warranty" class="px-2 py-1 bg-green-500 text-white text-xs font-bold rounded-lg">
              Garantili
            </span>
            <span class="px-2 py-1 bg-primary-500 text-white text-xs font-bold rounded-lg">
              {{ vehicle.year }}
            </span>
          </div>
          <!-- Image Count -->
          <div v-if="vehicle.image_count > 0" class="absolute bottom-3 left-3 px-2 py-1 bg-black/60 text-white text-xs rounded-lg flex items-center gap-1">
            <ImageIcon class="w-3 h-3" />
            {{ vehicle.image_count }}
          </div>
        </div>

        <!-- Content -->
        <div class="p-5">
          <!-- Title & Price -->
          <div class="flex items-start justify-between mb-3">
            <div>
              <h3 class="font-bold text-gray-900 dark:text-white text-lg">
                {{ vehicle.brand }} {{ vehicle.model }}
              </h3>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ vehicle.series || '' }}</p>
            </div>
            <p class="text-xl font-black text-primary-600">
              {{ formatPrice(vehicle.base_price) }}
            </p>
          </div>

          <!-- Specs -->
          <div class="grid grid-cols-2 gap-2 mb-4 text-sm">
            <div class="flex items-center gap-2 text-gray-600 dark:text-gray-400">
              <Gauge class="w-4 h-4 text-primary-500" />
              {{ formatMileage(vehicle.mileage) }}
            </div>
            <div class="flex items-center gap-2 text-gray-600 dark:text-gray-400">
              <Fuel class="w-4 h-4 text-primary-500" />
              {{ vehicle.fuel_type || '-' }}
            </div>
            <div class="flex items-center gap-2 text-gray-600 dark:text-gray-400">
              <Settings2 class="w-4 h-4 text-primary-500" />
              {{ vehicle.transmission || '-' }}
            </div>
            <div class="flex items-center gap-2 text-gray-600 dark:text-gray-400">
              <Palette class="w-4 h-4 text-primary-500" />
              {{ vehicle.color || '-' }}
            </div>
          </div>

          <!-- Gallery Info -->
          <div class="flex items-center gap-3 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-xl mb-4">
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-bold text-sm">
              {{ vehicle.gallery_name?.charAt(0) || 'G' }}
            </div>
            <div class="flex-1 min-w-0">
              <p class="font-semibold text-gray-900 dark:text-white text-sm truncate">{{ vehicle.gallery_name }}</p>
              <p class="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1">
                <MapPin class="w-3 h-3" />
                {{ vehicle.city }}{{ vehicle.district ? ', ' + vehicle.district : '' }}
              </p>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex gap-2">
            <button
              @click="sendMessage(vehicle)"
              :disabled="sendingMessage === vehicle.id"
              class="flex-1 py-2 bg-primary-500 text-white font-semibold rounded-xl hover:bg-primary-600 transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
            >
              <Loader2 v-if="sendingMessage === vehicle.id" class="w-4 h-4 animate-spin" />
              <MessageSquare v-else class="w-4 h-4" />
              {{ sendingMessage === vehicle.id ? 'Bekleyin...' : 'Mesaj' }}
            </button>
            <button
              @click="makeOffer(vehicle)"
              class="flex-1 py-2 bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white font-semibold rounded-xl hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors flex items-center justify-center gap-2"
            >
              <Tag class="w-4 h-4" />
              Teklif Ver
            </button>
            <button
              @click="toggleFavorite(vehicle)"
              :class="[
                'p-2 rounded-xl transition-colors',
                vehicle.isFavorite 
                  ? 'bg-red-100 dark:bg-red-900/30 text-red-500' 
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-400 hover:text-red-500'
              ]"
            >
              <Heart :class="['w-5 h-5', vehicle.isFavorite && 'fill-current']" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-16">
      <Car class="w-20 h-20 text-gray-300 dark:text-gray-600 mx-auto mb-4" />
      <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">Araç Bulunamadı</h3>
      <p class="text-gray-500 dark:text-gray-400 mb-4">Aradığınız kriterlere uygun araç yok.</p>
      <button
        @click="resetFilters"
        class="px-6 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors"
      >
        Filtreleri Temizle
      </button>
    </div>

    <!-- Pagination -->
    <div v-if="pagination.totalPages > 1" class="flex justify-center items-center gap-4">
      <button
        @click="changePage(pagination.page - 1)"
        :disabled="pagination.page === 1"
        class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
      >
        Önceki
      </button>
      <span class="text-gray-600 dark:text-gray-400">
        Sayfa <span class="font-bold text-gray-900 dark:text-white">{{ pagination.page }}</span> / {{ pagination.totalPages }}
      </span>
      <button
        @click="changePage(pagination.page + 1)"
        :disabled="pagination.page === pagination.totalPages"
        class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
      >
        Sonraki
      </button>
    </div>

    <!-- Toast Container -->
    <div class="fixed bottom-4 right-4 z-50 space-y-2">
      <div
        v-for="toast in toasts"
        :key="toast.id"
        :class="[
          'px-4 py-3 rounded-lg shadow-lg text-white font-medium flex items-center gap-2 animate-slide-in',
          toast.type === 'success' && 'bg-green-500',
          toast.type === 'error' && 'bg-red-500',
          toast.type === 'warning' && 'bg-yellow-500',
          toast.type === 'info' && 'bg-blue-500'
        ]"
      >
        <CheckCircle v-if="toast.type === 'success'" class="w-5 h-5" />
        <AlertCircle v-else-if="toast.type === 'error'" class="w-5 h-5" />
        <AlertTriangle v-else-if="toast.type === 'warning'" class="w-5 h-5" />
        <Info v-else class="w-5 h-5" />
        {{ toast.message }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { 
  Search, Filter, ChevronDown, Car, MapPin, MessageSquare, Tag, Heart, 
  Gauge, Fuel, Settings2, Palette, Image as ImageIcon, Loader2,
  CheckCircle, AlertCircle, AlertTriangle, Info
} from 'lucide-vue-next'
import { ref, reactive, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'

const api = useApi()

const loading = ref(false)
const vehicles = ref<any[]>([])
const searchQuery = ref('')
const showAdvancedFilters = ref(false)
const sortBy = ref('newest')
const sendingMessage = ref<string | null>(null)

// Toast state
const toasts = ref<{ id: string; type: string; message: string }[]>([])

const showToast = (type: string, message: string) => {
  const id = Math.random().toString(36).substring(7)
  toasts.value.push({ id, type, message })
  setTimeout(() => {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }, 4000)
}

const filters = reactive({
  brand: '',
  city: '',
  minPrice: null as number | null,
  maxPrice: null as number | null,
  minYear: null as number | null,
  maxYear: null as number | null,
  fuelType: '',
  transmission: ''
})

const pagination = reactive({
  page: 1,
  limit: 12,
  total: 0,
  totalPages: 0
})

const availableBrands = ref<string[]>(['BMW', 'Mercedes', 'Audi', 'Volkswagen', 'Ford', 'Toyota', 'Honda', 'Renault', 'Fiat'])
const availableCities = ref<string[]>(['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana'])

const formatPrice = (price: number) => {
  if (!price) return '-'
  return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(price)
}

const formatMileage = (mileage: number) => {
  if (!mileage) return '-'
  return new Intl.NumberFormat('tr-TR').format(mileage) + ' km'
}

const fetchVehicles = async () => {
  loading.value = true
  try {
    const params: Record<string, any> = {
      page: pagination.page,
      limit: pagination.limit,
      sort: sortBy.value
    }

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

const applyFilters = () => {
  pagination.page = 1
  fetchVehicles()
}

const resetFilters = () => {
  filters.brand = ''
  filters.city = ''
  filters.minPrice = null
  filters.maxPrice = null
  filters.minYear = null
  filters.maxYear = null
  filters.fuelType = ''
  filters.transmission = ''
  searchQuery.value = ''
  sortBy.value = 'newest'
  applyFilters()
}

const changePage = (newPage: number) => {
  if (newPage > 0 && newPage <= pagination.totalPages) {
    pagination.page = newPage
    fetchVehicles()
  }
}

const sendMessage = async (vehicle: any) => {
  // Check if user is logged in
  const authToken = useCookie('auth_token')
  if (!authToken.value) {
    showToast('warning', 'Mesaj göndermek için giriş yapmanız gerekiyor!')
    setTimeout(() => {
      navigateTo('/login')
    }, 1500)
    return
  }
  
  sendingMessage.value = vehicle.id
  
  try {
    console.log('Sending message to vehicle:', vehicle.id, 'gallery:', vehicle.gallery_id)
    
    const response = await api.post('/chat', {
      roomType: 'vehicle',
      vehicleId: vehicle.id,
      otherGalleryId: vehicle.gallery_id
    })
    
    console.log('Chat response:', response)
    
    if (response.success && response.data?.id) {
      showToast('success', 'Sohbet odası oluşturuldu!')
      setTimeout(() => {
        navigateTo(`/chats?roomId=${response.data.id}`)
      }, 500)
    } else {
      throw new Error(response.error || 'Sohbet oluşturulamadı')
    }
  } catch (error: any) {
    console.error('Message error:', error)
    const errorMsg = error.message || error.error || 'Mesaj gonderilemedi'
    showToast('error', errorMsg)
  } finally {
    sendingMessage.value = null
  }
}

const makeOffer = async (vehicle: any) => {
  // Check if user is logged in
  const authToken = useCookie('auth_token')
  if (!authToken.value) {
    showToast('warning', 'Teklif vermek için giriş yapmanız gerekiyor!')
    setTimeout(() => {
      navigateTo('/login')
    }, 1500)
    return
  }

  const offerPrice = prompt(`${vehicle.brand} ${vehicle.model} için teklif fiyatı girin:\n\nAraç Fiyatı: ${formatPrice(vehicle.base_price)}`, vehicle.base_price?.toString() || '')
  
  if (!offerPrice || isNaN(Number(offerPrice))) {
    return
  }

  const note = prompt('Teklif için not eklemek ister misiniz? (Opsiyonel)', '')
  
  try {
    const response = await api.post('/offers', {
      vehicleId: vehicle.id,
      amount: Number(offerPrice),
      note: note || undefined
    })
    
    if (response.success) {
      showToast('success', 'Teklifiniz başarıyla gönderildi!')
    } else {
      throw new Error(response.error || 'Teklif gönderilemedi')
    }
  } catch (error: any) {
    console.error('Offer error:', error)
    showToast('error', error.message || 'Teklif gönderilemedi')
  }
}

const toggleFavorite = async (vehicle: any) => {
  // Check if user is logged in
  const authToken = useCookie('auth_token')
  if (!authToken.value) {
    showToast('warning', 'Favorilere eklemek için giriş yapmanız gerekiyor!')
    setTimeout(() => {
      navigateTo('/login')
    }, 1500)
    return
  }

  try {
    if (vehicle.isFavorite) {
      await api.delete(`/favorites/${vehicle.id}`)
      vehicle.isFavorite = false
      showToast('success', 'Favorilerden kaldırıldı!')
    } else {
      await api.post(`/favorites/${vehicle.id}`)
      vehicle.isFavorite = true
      showToast('success', 'Favorilere eklendi!')
    }
  } catch (error: any) {
    console.error('Favorite error:', error)
    showToast('error', error.message || 'İşlem başarısız')
  }
}

onMounted(() => {
  fetchVehicles()
})
</script>

<style scoped>
@keyframes slide-in {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.animate-slide-in {
  animation: slide-in 0.3s ease-out;
}
</style>
