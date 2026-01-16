<template>
  <div class="space-y-6" v-if="vehicle">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <NuxtLink
          to="/vehicles"
          class="text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 mb-2 inline-flex items-center gap-1"
        >
          <ArrowLeft class="w-4 h-4" />
          Araçlara Dön
        </NuxtLink>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
          {{ vehicle.brand }} {{ vehicle.model }}
        </h1>
      </div>
      <div class="flex items-center gap-3">
        <NuxtLink
          :to="`/vehicles/${vehicle.id}/edit`"
          class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold"
        >
          Düzenle
        </NuxtLink>
        <button
          @click="deleteVehicle"
          class="px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold"
        >
          Sil
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Main Content -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Images -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Fotoğraflar</h2>
          <div class="grid grid-cols-3 gap-4">
            <div
              v-for="(image, index) in vehicleImages"
              :key="index"
              class="aspect-square rounded-xl overflow-hidden bg-gradient-to-br from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-800 cursor-pointer hover:scale-105 transition-transform"
              @click="selectedImageIndex = index"
            >
              <img
                v-if="image"
                :src="image"
                :alt="`${vehicle.brand} ${vehicle.model} - Fotoğraf ${index + 1}`"
                class="w-full h-full object-cover"
              />
              <div v-else class="w-full h-full flex items-center justify-center">
                <Car class="w-12 h-12 text-gray-400 dark:text-gray-500 opacity-50" />
              </div>
            </div>
          </div>
          <button class="mt-4 w-full px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold">
            Fotoğraf Ekle
          </button>
        </div>

        <!-- Details -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Detaylar</h2>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Marka</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ vehicle.brand }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Model</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ vehicle.model }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Yıl</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ vehicle.year }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Km</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ vehicle.km?.toLocaleString() || 0 }} km</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Yakıt Tipi</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ vehicle.fuelType || 'Belirtilmemiş' }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Vites</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ vehicle.transmission || 'Belirtilmemiş' }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Renk</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ vehicle.color || 'Belirtilmemiş' }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Durum</div>
              <span
                class="inline-block px-2 py-1 text-xs font-semibold rounded-full"
                :class="{
                  'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': vehicle.status === 'active' || vehicle.status === 'published',
                  'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400': vehicle.status === 'sold',
                  'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': vehicle.status === 'pending' || vehicle.status === 'draft'
                }"
              >
                {{ statusLabels[vehicle.status] || vehicle.status }}
              </span>
            </div>
          </div>
        </div>

        <!-- Description -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Açıklama</h2>
          <p class="text-gray-600 dark:text-gray-400">
            {{ vehicle.description || 'Açıklama eklenmemiş.' }}
          </p>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="space-y-6">
        <!-- Price Card -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <div class="text-sm text-gray-600 dark:text-gray-400 mb-2">Fiyat</div>
          <div class="text-3xl font-bold text-primary-600 dark:text-primary-400 mb-4">
            {{ vehicle.price?.toLocaleString() || 0 }} ₺
          </div>
          <button @click="updatePrice" class="w-full px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all">
            Fiyat Güncelle
          </button>
        </div>

        <!-- Quick Stats -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">İstatistikler</h3>
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-600 dark:text-gray-400">Görüntülenme</span>
              <span class="font-semibold text-gray-900 dark:text-white">{{ vehicle.viewCount || 0 }}</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-600 dark:text-gray-400">Teklif Sayısı</span>
              <span class="font-semibold text-gray-900 dark:text-white">{{ vehicle.offerCount || 0 }}</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-600 dark:text-gray-400">Favori</span>
              <span class="font-semibold text-gray-900 dark:text-white">{{ vehicle.favoriteCount || 0 }}</span>
            </div>
          </div>
        </div>

        <!-- Channel Status -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Kanal Durumu</h3>
          <div class="space-y-3">
            <div
              v-for="channel in channels"
              :key="channel.id"
              class="flex items-center justify-between"
            >
              <span class="text-sm text-gray-700 dark:text-gray-300">{{ channel.name }}</span>
              <span
                class="px-2 py-1 text-xs font-semibold rounded-full"
                :class="channel.status === 'active' 
                  ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' 
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400'"
              >
                {{ channel.status === 'active' ? 'Aktif' : 'Pasif' }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft, Car } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useApi } from '~/composables/useApi'

const route = useRoute()
const router = useRouter()
const api = useApi()

const statusLabels: Record<string, string> = {
  active: 'Aktif',
  published: 'Yayında',
  sold: 'Satıldı',
  pending: 'Beklemede',
  draft: 'Taslak',
  paused: 'Duraklatıldı',
  archived: 'Arşivlendi'
}

const vehicle = ref<any>(null)
const selectedImageIndex = ref(0)

const channels = ref([
  { id: 1, name: 'Sahibinden', status: 'active' },
  { id: 2, name: 'Arabam', status: 'active' }
])

const vehicleImages = computed(() => {
  if (vehicle.value?.images && vehicle.value.images.length > 0) {
    return vehicle.value.images
  }
  // Default placeholder images
  return [
    'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=400&h=400&fit=crop',
    null,
    null,
    null
  ]
})

onMounted(async () => {
  try {
    const response = await api.get<{ success: boolean; data: any }>(`/vehicles/${route.params.id}`)
    if (response.success && response.data) {
      const v = response.data
      vehicle.value = {
        id: v.id,
        brand: v.brand,
        model: v.model,
        year: v.year,
        km: v.mileage || 0,
        price: v.base_price || 0,
        fuelType: v.fuel_type,
        transmission: v.transmission,
        color: v.color,
        status: v.status,
        description: v.description,
        images: v.images || [],
        viewCount: v.view_count || 0,
        offerCount: v.offer_count || 0,
        favoriteCount: v.favorite_count || 0
      }
    }
  } catch (error: any) {
    console.error('Araç yüklenemedi:', error)
    // Fallback data
    vehicle.value = {
      id: route.params.id as string,
      brand: 'BMW',
      model: '320i',
      year: 2020,
      km: 45000,
      price: 850000,
      fuelType: 'Benzin',
      transmission: 'Otomatik',
      color: 'Beyaz',
      status: 'active',
      description: 'Araç çok temiz, bakımlı, hasarsız. Öğretmenden alındı.',
      images: ['https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&h=600&fit=crop']
    }
  }
})

const deleteVehicle = async () => {
  if (confirm('Bu aracı silmek istediğinize emin misiniz?')) {
    try {
      await api.delete(`/vehicles/${vehicle.value?.id}`)
      router.push('/vehicles')
    } catch (error: any) {
      alert('Hata: ' + error.message)
    }
  }
}

const updatePrice = () => {
  const newPrice = prompt('Yeni fiyat:', vehicle.value?.price?.toString())
  if (newPrice && !isNaN(Number(newPrice))) {
    api.put(`/vehicles/${vehicle.value?.id}`, { basePrice: Number(newPrice) })
      .then(() => {
        if (vehicle.value) {
          vehicle.value.price = Number(newPrice)
        }
        alert('Fiyat güncellendi!')
      })
      .catch((error: any) => {
        alert('Hata: ' + error.message)
      })
  }
}
</script>






