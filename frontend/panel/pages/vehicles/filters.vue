<template>
  <div class="space-y-6">
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
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Gelişmiş Filtreler</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Araçlarınızı detaylı şekilde filtreleyin</p>
      </div>
      <div class="flex items-center gap-3">
        <button
          @click="resetFilters"
          class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold"
        >
          Filtreleri Temizle
        </button>
        <button
          @click="applyFilters"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          Filtreleri Uygula
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
      <!-- Filters Sidebar -->
      <div class="lg:col-span-1 space-y-6">
        <!-- Basic Filters -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="font-bold text-gray-900 dark:text-white mb-4">Temel Filtreler</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Marka
              </label>
              <select
                v-model="filters.brand"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="">Tümü</option>
                <option value="BMW">BMW</option>
                <option value="Mercedes">Mercedes</option>
                <option value="Audi">Audi</option>
                <option value="Volkswagen">Volkswagen</option>
                <option value="Ford">Ford</option>
                <option value="Toyota">Toyota</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Model
              </label>
              <input
                v-model="filters.model"
                type="text"
                placeholder="Model ara..."
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Yıl Aralığı
              </label>
              <div class="grid grid-cols-2 gap-2">
                <input
                  v-model.number="filters.yearFrom"
                  type="number"
                  placeholder="Min"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
                <input
                  v-model.number="filters.yearTo"
                  type="number"
                  placeholder="Max"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Price Range -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="font-bold text-gray-900 dark:text-white mb-4">Fiyat Aralığı</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Minimum Fiyat (₺)
              </label>
              <input
                v-model.number="filters.priceFrom"
                type="number"
                placeholder="0"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Maksimum Fiyat (₺)
              </label>
              <input
                v-model.number="filters.priceTo"
                type="number"
                placeholder="Sınırsız"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
          </div>
        </div>

        <!-- Vehicle Details -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="font-bold text-gray-900 dark:text-white mb-4">Araç Detayları</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Yakıt Tipi
              </label>
              <div class="space-y-2">
                <label class="flex items-center gap-2">
                  <input type="checkbox" v-model="filters.fuelTypes" value="Benzin" class="rounded" />
                  <span class="text-sm text-gray-700 dark:text-gray-300">Benzin</span>
                </label>
                <label class="flex items-center gap-2">
                  <input type="checkbox" v-model="filters.fuelTypes" value="Dizel" class="rounded" />
                  <span class="text-sm text-gray-700 dark:text-gray-300">Dizel</span>
                </label>
                <label class="flex items-center gap-2">
                  <input type="checkbox" v-model="filters.fuelTypes" value="Elektrik" class="rounded" />
                  <span class="text-sm text-gray-700 dark:text-gray-300">Elektrik</span>
                </label>
                <label class="flex items-center gap-2">
                  <input type="checkbox" v-model="filters.fuelTypes" value="Hibrit" class="rounded" />
                  <span class="text-sm text-gray-700 dark:text-gray-300">Hibrit</span>
                </label>
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Vites
              </label>
              <select
                v-model="filters.transmission"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="">Tümü</option>
                <option value="Manuel">Manuel</option>
                <option value="Otomatik">Otomatik</option>
                <option value="Yarı Otomatik">Yarı Otomatik</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Durum
              </label>
              <select
                v-model="filters.status"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="">Tümü</option>
                <option value="active">Aktif</option>
                <option value="pending">Beklemede</option>
                <option value="sold">Satıldı</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Results -->
      <div class="lg:col-span-3">
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <div class="flex items-center justify-between mb-6">
            <h3 class="font-bold text-gray-900 dark:text-white">
              Sonuçlar ({{ filteredVehicles.length }})
            </h3>
            <select
              v-model="viewMode"
              class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
            >
              <option value="grid">Grid Görünüm</option>
              <option value="list">Liste Görünüm</option>
            </select>
          </div>

          <!-- Grid View -->
          <div v-if="viewMode === 'grid'" class="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div
              v-for="vehicle in filteredVehicles"
              :key="vehicle.id"
              class="bg-gray-50 dark:bg-gray-700/50 rounded-xl p-4 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors cursor-pointer"
              @click="$router.push(`/vehicles/${vehicle.id}`)"
            >
              <div class="font-semibold text-gray-900 dark:text-white mb-2">
                {{ vehicle.brand }} {{ vehicle.model }}
              </div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-2">
                {{ vehicle.year }} • {{ vehicle.km }} km
              </div>
              <div class="text-lg font-bold text-primary-600 dark:text-primary-400">
                {{ vehicle.price }} ₺
              </div>
            </div>
          </div>

          <!-- List View -->
          <div v-else class="space-y-3">
            <div
              v-for="vehicle in filteredVehicles"
              :key="vehicle.id"
              class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors cursor-pointer"
              @click="$router.push(`/vehicles/${vehicle.id}`)"
            >
              <div>
                <div class="font-semibold text-gray-900 dark:text-white">
                  {{ vehicle.brand }} {{ vehicle.model }}
                </div>
                <div class="text-sm text-gray-600 dark:text-gray-400">
                  {{ vehicle.year }} • {{ vehicle.km }} km • {{ vehicle.fuelType }}
                </div>
              </div>
              <div class="text-xl font-bold text-primary-600 dark:text-primary-400">
                {{ vehicle.price }} ₺
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft } from 'lucide-vue-next'
import { reactive, ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const viewMode = ref('grid')

const filters = reactive({
  brand: '',
  model: '',
  yearFrom: null as number | null,
  yearTo: null as number | null,
  priceFrom: null as number | null,
  priceTo: null as number | null,
  fuelTypes: [] as string[],
  transmission: '',
  status: ''
})

const vehicles = ref([
  { id: 1, brand: 'BMW', model: '320i', year: 2020, km: '45.000', fuelType: 'Benzin', price: '850.000', status: 'active' },
  { id: 2, brand: 'Mercedes', model: 'C200', year: 2019, km: '60.000', fuelType: 'Dizel', price: '920.000', status: 'active' },
  { id: 3, brand: 'Audi', model: 'A4', year: 2021, km: '30.000', fuelType: 'Benzin', price: '1.150.000', status: 'active' },
  { id: 4, brand: 'Volkswagen', model: 'Passat', year: 2018, km: '75.000', fuelType: 'Dizel', price: '650.000', status: 'pending' }
])

const filteredVehicles = computed(() => {
  return vehicles.value.filter(vehicle => {
    if (filters.brand && vehicle.brand !== filters.brand) return false
    if (filters.model && !vehicle.model.toLowerCase().includes(filters.model.toLowerCase())) return false
    if (filters.yearFrom && vehicle.year < filters.yearFrom) return false
    if (filters.yearTo && vehicle.year > filters.yearTo) return false
    if (filters.priceFrom && parseInt(vehicle.price.replace(/\./g, '')) < filters.priceFrom) return false
    if (filters.priceTo && parseInt(vehicle.price.replace(/\./g, '')) > filters.priceTo) return false
    if (filters.fuelTypes.length > 0 && !filters.fuelTypes.includes(vehicle.fuelType)) return false
    if (filters.transmission && vehicle.transmission !== filters.transmission) return false
    if (filters.status && vehicle.status !== filters.status) return false
    return true
  })
})

const resetFilters = () => {
  filters.brand = ''
  filters.model = ''
  filters.yearFrom = null
  filters.yearTo = null
  filters.priceFrom = null
  filters.priceTo = null
  filters.fuelTypes = []
  filters.transmission = ''
  filters.status = ''
}

const applyFilters = () => {
  // Filters are already applied via computed property
  // This can be used to save filters or navigate
  router.push('/vehicles')
}
</script>














