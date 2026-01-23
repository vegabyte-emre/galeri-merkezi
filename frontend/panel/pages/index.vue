<template>
  <div class="space-y-6">
    <!-- Welcome Banner -->
    <div class="bg-gradient-to-r from-primary-600 via-primary-700 to-primary-800 rounded-2xl p-8 text-white shadow-xl relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full -translate-y-1/2 translate-x-1/2"></div>
      <div class="relative z-10">
        <h1 class="text-3xl font-bold mb-2">Hoş Geldiniz, {{ galleryName }}</h1>
        <p class="text-primary-100 text-lg">Bugün işleriniz nasıl gidiyor? İşte özet bilgileriniz.</p>
      </div>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <NuxtLink
        v-for="(stat, index) in stats"
        :key="stat.label"
        :to="stat.link"
        class="group relative bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-gray-100 dark:border-gray-700 cursor-pointer"
        :style="{ animationDelay: `${index * 100}ms` }"
      >
        <!-- Gradient Background -->
        <div 
          class="absolute top-0 right-0 w-32 h-32 rounded-bl-full opacity-10"
          :class="stat.gradient"
        ></div>
        
        <div class="relative">
          <div class="flex items-center justify-between mb-4">
            <div 
              class="w-12 h-12 rounded-xl flex items-center justify-center shadow-lg"
              :class="stat.iconBg"
            >
              <component :is="stat.icon" class="w-6 h-6" :class="stat.iconColor" />
            </div>
            <span
              v-if="stat.change"
              class="text-xs font-semibold px-2 py-1 rounded-full"
              :class="stat.changeClass"
            >
              {{ stat.change }}
            </span>
          </div>
          <div class="mb-1">
            <span class="text-3xl font-bold text-gray-900 dark:text-white">{{ stat.value }}</span>
            <span v-if="stat.unit" class="text-lg text-gray-500 dark:text-gray-400 ml-1">{{ stat.unit }}</span>
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400">{{ stat.label }}</div>
        </div>
      </NuxtLink>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Sales Chart -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-100 dark:border-gray-700">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Satış Trendi</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">Son 6 ay</p>
          </div>
          <select class="px-3 py-1.5 text-sm border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300">
            <option>Son 6 Ay</option>
            <option>Son 1 Yıl</option>
          </select>
        </div>
        <div class="h-64 flex items-center justify-center bg-gradient-to-br from-primary-50 to-primary-100 dark:from-primary-900/20 dark:to-primary-800/20 rounded-xl">
          <div class="text-center">
            <TrendingUp class="w-16 h-16 text-primary-400 mx-auto mb-2" />
            <p class="text-sm text-gray-500 dark:text-gray-400">Grafik buraya gelecek</p>
          </div>
        </div>
      </div>

      <!-- Offer Status Chart -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-100 dark:border-gray-700">
        <div class="mb-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white">Teklif Durumu</h3>
          <p class="text-sm text-gray-500 dark:text-gray-400">Bu ay</p>
        </div>
        <div class="h-64 flex items-center justify-center bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20 rounded-xl">
          <div class="text-center">
            <BarChart3 class="w-16 h-16 text-green-400 mx-auto mb-2" />
            <p class="text-sm text-gray-500 dark:text-gray-400">Grafik buraya gelecek</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Recent Vehicles -->
      <div class="lg:col-span-2 bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-100 dark:border-gray-700">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Son Eklenen Araçlar</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">Envanterinizdeki son araçlar</p>
          </div>
          <NuxtLink
            to="/vehicles"
            class="px-4 py-2 text-sm font-semibold text-primary-600 dark:text-primary-400 hover:bg-primary-50 dark:hover:bg-primary-900/30 rounded-lg transition-colors"
          >
            Tümünü Gör
          </NuxtLink>
        </div>
        <div class="space-y-4">
          <div
            v-for="(vehicle, index) in recentVehicles"
            :key="index"
            class="flex items-center gap-4 p-4 rounded-xl bg-gray-50 dark:bg-gray-700/50 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors group cursor-pointer"
            @click="$router.push(`/vehicles/${vehicle.id}`)"
          >
            <!-- Vehicle Image -->
            <div class="w-20 h-20 rounded-xl overflow-hidden flex-shrink-0 shadow-lg group-hover:scale-105 transition-transform bg-gradient-to-br from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-800">
              <img
                v-if="vehicle.image"
                :src="vehicle.image"
                :alt="`${vehicle.brand} ${vehicle.model}`"
                class="w-full h-full object-cover"
              />
              <div v-else class="w-full h-full flex items-center justify-center">
                <Car class="w-10 h-10 text-gray-400 dark:text-gray-500" />
              </div>
            </div>
            <div class="flex-1 min-w-0">
              <h4 class="font-semibold text-gray-900 dark:text-white mb-1 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
                {{ vehicle.brand }} {{ vehicle.model }}
              </h4>
              <div class="flex items-center gap-3 text-sm text-gray-500 dark:text-gray-400">
                <span>{{ vehicle.year }}</span>
                <span>•</span>
                <span>{{ vehicle.km }} km</span>
                <span>•</span>
                <span class="font-semibold text-primary-600 dark:text-primary-400">{{ vehicle.price }} ₺</span>
              </div>
            </div>
            <div class="flex flex-col items-end gap-2">
              <span 
                class="px-2 py-1 text-xs font-semibold rounded-full"
                :class="vehicle.status === 'Aktif' ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400'"
              >
                {{ vehicle.status }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Quick Actions & Recent Offers -->
      <div class="space-y-6">
        <!-- Quick Actions -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-100 dark:border-gray-700">
          <div class="mb-6">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Hızlı İşlemler</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">Sık kullanılan işlemler</p>
          </div>
          <div class="space-y-3">
            <button
              v-for="action in quickActions"
              :key="action.label"
              @click="action.action"
              class="w-full flex items-center gap-3 p-4 rounded-xl bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-700 dark:to-gray-800 hover:from-primary-50 hover:to-primary-100 dark:hover:from-primary-900/30 dark:hover:to-primary-800/30 border border-gray-200 dark:border-gray-600 hover:border-primary-300 dark:hover:border-primary-700 transition-all duration-300 hover:scale-105 group"
            >
              <div 
                class="w-10 h-10 rounded-lg flex items-center justify-center"
                :class="action.iconBg"
              >
                <component :is="action.icon" class="w-5 h-5" :class="action.iconColor" />
              </div>
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ action.label }}</span>
            </button>
          </div>
        </div>

        <!-- Recent Offers -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-100 dark:border-gray-700">
          <div class="mb-6">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Son Teklifler</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ recentOffers.length }} yeni teklif</p>
          </div>
          <div class="space-y-3">
            <div
              v-for="(offer, index) in recentOffers"
              :key="index"
              class="p-4 rounded-xl bg-gray-50 dark:bg-gray-700/50 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors cursor-pointer"
              @click="$router.push('/offers')"
            >
              <div class="flex items-start justify-between mb-2">
                <div>
                  <h4 class="text-sm font-semibold text-gray-900 dark:text-white">{{ offer.vehicle }}</h4>
                  <p class="text-xs text-gray-500 dark:text-gray-400">{{ offer.from }}</p>
                </div>
                <span 
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="offer.status === 'Bekliyor' ? 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400' : 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400'"
                >
                  {{ offer.status }}
                </span>
              </div>
              <p class="text-sm font-bold text-primary-600 dark:text-primary-400">{{ offer.price }} ₺</p>
            </div>
          </div>
          <NuxtLink
            to="/offers"
            class="block mt-4 text-center text-sm font-semibold text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300"
          >
            Tüm Teklifleri Gör →
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Use default layout for dashboard
definePageMeta({
  layout: 'default'
})
import {
  Car,
  CarFront,
  Users,
  MessageSquare,
  TrendingUp,
  Plus,
  Upload,
  Download,
  Settings,
  BarChart3
} from 'lucide-vue-next'
import { ref, onMounted, computed } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'
import { useAuthStore } from '~/stores/auth'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const authStore = useAuthStore()
const galleryName = computed(() => authStore.gallery?.name || 'Galeri')

const stats = ref([
  {
    icon: CarFront,
    label: 'Toplam Araç',
    value: '0',
    unit: '',
    change: '+0',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400',
    gradient: 'bg-gradient-to-br from-blue-400 to-blue-600',
    key: 'totalVehicles',
    link: '/vehicles'
  },
  {
    icon: Users,
    label: 'Aktif Teklif',
    value: '0',
    unit: '',
    change: '+0',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400',
    gradient: 'bg-gradient-to-br from-green-400 to-green-600',
    key: 'activeOffers',
    link: '/offers'
  },
  {
    icon: MessageSquare,
    label: 'Okunmamış Mesaj',
    value: '0',
    unit: '',
    change: null,
    changeClass: '',
    iconBg: 'bg-purple-100 dark:bg-purple-900/30',
    iconColor: 'text-purple-600 dark:text-purple-400',
    gradient: 'bg-gradient-to-br from-purple-400 to-purple-600',
    key: 'unreadMessages',
    link: '/chats'
  },
  {
    icon: TrendingUp,
    label: 'Bu Ay Satış',
    value: '0',
    unit: '',
    change: '+0%',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    iconBg: 'bg-orange-100 dark:bg-orange-900/30',
    iconColor: 'text-orange-600 dark:text-orange-400',
    gradient: 'bg-gradient-to-br from-orange-400 to-orange-600',
    key: 'monthlySales',
    link: '/reports'
  }
])

const recentVehicles = ref([
  { id: 1, brand: 'BMW', model: '320i', year: 2020, km: '45.000', price: '850.000', status: 'Aktif', image: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=200&h=200&fit=crop' },
  { id: 2, brand: 'Mercedes', model: 'C200', year: 2019, km: '60.000', price: '920.000', status: 'Aktif', image: 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=200&h=200&fit=crop' },
  { id: 3, brand: 'Audi', model: 'A4', year: 2021, km: '30.000', price: '1.150.000', status: 'Aktif', image: 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=200&h=200&fit=crop' },
  { id: 4, brand: 'Volkswagen', model: 'Passat', year: 2018, km: '75.000', price: '650.000', status: 'Beklemede', image: null }
])

const quickActions = [
  {
    icon: Plus,
    label: 'Yeni Araç Ekle',
    iconBg: 'bg-primary-100 dark:bg-primary-900/30',
    iconColor: 'text-primary-600 dark:text-primary-400',
    action: () => navigateTo('/vehicles/new')
  },
  {
    icon: Upload,
    label: 'Toplu Yükleme',
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400',
    action: () => navigateTo('/vehicles/bulk')
  },
  {
    icon: Download,
    label: 'Rapor İndir',
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400',
    action: async () => {
      try {
        const response = await api.get('/reports/export', undefined, { responseType: 'blob' })
        const url = window.URL.createObjectURL(response)
        const a = document.createElement('a')
        a.href = url
        a.download = `rapor-${new Date().toISOString().split('T')[0]}.xlsx`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        window.URL.revokeObjectURL(url)
        toast.success('Rapor indirildi!')
      } catch (error: any) {
        toast.error('Rapor indirilemedi: ' + error.message)
      }
    }
  },
  {
    icon: Settings,
    label: 'Ayarlar',
    iconBg: 'bg-gray-100 dark:bg-gray-700',
    iconColor: 'text-gray-600 dark:text-gray-400',
    action: () => navigateTo('/settings')
  }
]

const recentOffers = ref([
  { vehicle: 'BMW 320i', from: 'İstanbul Oto', price: '820.000', status: 'Bekliyor' },
  { vehicle: 'Mercedes C200', from: 'Ankara Motors', price: '900.000', status: 'Kabul' },
  { vehicle: 'Audi A4', from: 'İzmir Auto', price: '1.100.000', status: 'Bekliyor' }
])

const loadDashboardData = async () => {
  loading.value = true
  try {
    // Load dashboard stats
    const dashboardRes = await api.get<{ success: boolean; stats?: any; recentVehicles?: any[] }>('/dashboard')
    
    if (dashboardRes.success) {
      // Update stats
      if (dashboardRes.stats) {
        const totalVehiclesStat = stats.value.find(s => s.key === 'totalVehicles')
        if (totalVehiclesStat && dashboardRes.stats.totalVehicles) {
          totalVehiclesStat.value = dashboardRes.stats.totalVehicles.value?.toString() || '0'
          totalVehiclesStat.change = dashboardRes.stats.totalVehicles.change || '+0'
        }

        const monthlySalesStat = stats.value.find(s => s.key === 'monthlySales')
        if (monthlySalesStat && dashboardRes.stats.monthlySales) {
          monthlySalesStat.value = dashboardRes.stats.monthlySales.value?.toString() || '0'
          monthlySalesStat.change = dashboardRes.stats.monthlySales.change || '+0%'
        }
      }
      
      // Update recent vehicles
      if (dashboardRes.recentVehicles && dashboardRes.recentVehicles.length > 0) {
        recentVehicles.value = dashboardRes.recentVehicles.map((v: any) => ({
          id: v.id,
          brand: v.brand,
          model: v.model,
          year: v.year,
          km: v.mileage?.toLocaleString('tr-TR') || '0',
          price: v.base_price?.toLocaleString('tr-TR') || '0',
          status: v.status === 'published' ? 'Aktif' : v.status === 'draft' ? 'Taslak' : 'Beklemede',
          image: v.cover_image_url || null
        }))
      }
    }

    // Load active offers count
    try {
      const offersRes = await api.get<{ success: boolean; data?: any[] }>('/offers')
      if (offersRes.success && offersRes.data) {
        const activeOffersStat = stats.value.find(s => s.key === 'activeOffers')
        if (activeOffersStat) {
          const activeCount = offersRes.data.filter((o: any) => o.status === 'pending' || o.status === 'accepted').length
          activeOffersStat.value = activeCount.toString()
        }
      }
    } catch (e) {
      console.error('Offers load error:', e)
    }

    // Load unread messages count
    try {
      const chatsRes = await api.get<{ success: boolean; data?: any[] }>('/chats')
      if (chatsRes.success && chatsRes.data) {
        const unreadMessagesStat = stats.value.find(s => s.key === 'unreadMessages')
        if (unreadMessagesStat) {
          const unreadCount = chatsRes.data.reduce((sum: number, chat: any) => sum + (chat.unread_count || 0), 0)
          unreadMessagesStat.value = unreadCount.toString()
        }
      }
    } catch (e) {
      console.error('Chats load error:', e)
    }

    // Load recent offers
    try {
      const offersRes = await api.get<{ success: boolean; data?: any[] }>('/offers?limit=5')
      if (offersRes.success && offersRes.data && offersRes.data.length > 0) {
        recentOffers.value = offersRes.data.map((o: any) => ({
          vehicle: `${o.vehicle_brand || ''} ${o.vehicle_model || ''}`.trim() || 'Araç',
          from: o.buyer_gallery_name || o.seller_gallery_name || 'Galeri',
          price: o.price?.toLocaleString('tr-TR') || '0',
          status: o.status === 'pending' ? 'Bekliyor' : o.status === 'accepted' ? 'Kabul' : 'Reddedildi'
        }))
      }
    } catch (e) {
      console.error('Recent offers load error:', e)
    }
  } catch (error: any) {
    console.error('Dashboard verileri yüklenemedi:', error)
    // Keep default values on error
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadDashboardData()
})
</script>

<style scoped>
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.group {
  animation: fade-in-up 0.6s ease-out both;
}
</style>
