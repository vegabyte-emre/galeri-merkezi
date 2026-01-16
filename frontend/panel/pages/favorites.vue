<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Favorilerim</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Beğendiğiniz araçları buradan yönetin</p>
      </div>
      <div class="flex items-center gap-3">
        <select
          v-model="sortBy"
          class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-700 dark:text-gray-300"
        >
          <option value="date">Tarihe Göre</option>
          <option value="price-asc">Fiyat: Düşükten Yükseğe</option>
          <option value="price-desc">Fiyat: Yüksekten Düşüğe</option>
          <option value="year">Yıla Göre</option>
        </select>
        <button
          @click="clearAll"
          class="px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold"
        >
          Tümünü Temizle
        </button>
      </div>
    </div>

    <!-- Favorites Grid -->
    <div v-if="favorites.length > 0" class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="vehicle in sortedFavorites"
        :key="vehicle.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-xl transition-all cursor-pointer group"
        @click="$router.push(`/vehicles/${vehicle.vehicleId}`)"
      >
        <!-- Image -->
        <div class="h-48 bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center relative">
          <Car class="w-24 h-24 text-white opacity-50" />
          <button
            @click.stop="removeFavorite(vehicle.vehicleId)"
            class="absolute top-4 right-4 p-2 bg-white/90 dark:bg-gray-800/90 rounded-full hover:bg-white dark:hover:bg-gray-800 transition-colors shadow-lg"
          >
            <Heart class="w-5 h-5 text-red-500 fill-current" />
          </button>
          <div class="absolute top-4 left-4 px-3 py-1 bg-primary-500 text-white rounded-full text-xs font-semibold">
            Favori
          </div>
        </div>

        <!-- Content -->
        <div class="p-6">
          <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
            {{ vehicle.vehicle?.brand }} {{ vehicle.vehicle?.model }}
          </h3>
          <div class="flex items-center gap-3 text-sm text-gray-600 dark:text-gray-400 mb-4">
            <span>{{ vehicle.vehicle?.year }}</span>
            <span>•</span>
            <span>{{ vehicle.vehicle?.mileage?.toLocaleString('tr-TR') }} km</span>
          </div>
          <div class="flex items-center justify-between">
            <div class="text-2xl font-bold text-primary-600 dark:text-primary-400">
              {{ vehicle.vehicle?.basePrice?.toLocaleString('tr-TR') }} ₺
            </div>
            <div class="text-xs text-gray-500 dark:text-gray-400">
              {{ formatDate(vehicle.createdAt) }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div
      v-else
      class="text-center py-16 bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700"
    >
      <Heart class="w-24 h-24 text-gray-400 mx-auto mb-4" />
      <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Henüz Favori Yok</h3>
      <p class="text-gray-600 dark:text-gray-400 mb-6">
        Beğendiğiniz araçları favorilere ekleyerek kolayca erişebilirsiniz
      </p>
      <NuxtLink
        to="/marketplace"
        class="inline-block px-6 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
      >
        Oto Pazarı'na Git
      </NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Heart, Car } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const sortBy = ref('date')
const loading = ref(false)

const favorites = ref<any[]>([])

const sortedFavorites = computed(() => {
  const sorted = [...favorites.value]
  
  switch (sortBy.value) {
    case 'price-asc':
      return sorted.sort((a, b) => (a.vehicle?.basePrice || 0) - (b.vehicle?.basePrice || 0))
    case 'price-desc':
      return sorted.sort((a, b) => (b.vehicle?.basePrice || 0) - (a.vehicle?.basePrice || 0))
    case 'year':
      return sorted.sort((a, b) => (b.vehicle?.year || 0) - (a.vehicle?.year || 0))
    default:
      return sorted.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
  }
})

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR')
}

const loadFavorites = async () => {
  try {
    loading.value = true
    const response = await api.get<{ success: boolean; data: any[] }>('/favorites')
    if (response.success && response.data) {
      favorites.value = response.data
    }
  } catch (error: any) {
    toast.error('Favoriler yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const removeFavorite = async (vehicleId: string) => {
  try {
    await api.delete(`/favorites/${vehicleId}`)
    favorites.value = favorites.value.filter(f => f.vehicleId !== vehicleId)
    toast.success('Favorilerden kaldırıldı')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const clearAll = async () => {
  if (confirm('Tüm favorileri temizlemek istediğinize emin misiniz?')) {
    try {
      for (const fav of favorites.value) {
        await api.delete(`/favorites/${fav.vehicleId}`)
      }
      favorites.value = []
      toast.success('Tüm favoriler temizlendi')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

onMounted(() => {
  loadFavorites()
})
</script>

