<template>
  <div class="py-12">
    <div class="container-custom">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">Araç Ara</h1>
        <p class="text-gray-600 dark:text-gray-400">Binlerce araç arasından aradığınızı bulun</p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <!-- Filters Sidebar -->
        <div class="lg:col-span-1">
          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 sticky top-24">
            <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Filtreler</h2>
            
            <!-- Search -->
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Araç Ara</label>
              <div class="relative">
                <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  v-model="filters.search"
                  type="text"
                  placeholder="Marka, model..."
                  class="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>

            <!-- Brand -->
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Marka</label>
              <select
                v-model="filters.brand"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="">Tüm Markalar</option>
                <option value="bmw">BMW</option>
                <option value="mercedes">Mercedes</option>
                <option value="audi">Audi</option>
                <option value="volkswagen">Volkswagen</option>
                <option value="ford">Ford</option>
                <option value="toyota">Toyota</option>
              </select>
            </div>

            <!-- Price Range -->
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Fiyat Aralığı</label>
              <div class="grid grid-cols-2 gap-2">
                <input
                  v-model.number="filters.minPrice"
                  type="number"
                  placeholder="Min"
                  class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
                <input
                  v-model.number="filters.maxPrice"
                  type="number"
                  placeholder="Max"
                  class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>

            <!-- Year Range -->
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Yıl Aralığı</label>
              <div class="grid grid-cols-2 gap-2">
                <input
                  v-model.number="filters.minYear"
                  type="number"
                  placeholder="Min"
                  class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
                <input
                  v-model.number="filters.maxYear"
                  type="number"
                  placeholder="Max"
                  class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>

            <!-- Fuel Type -->
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Yakıt Tipi</label>
              <div class="space-y-2">
                <label v-for="fuel in fuelTypes" :key="fuel" class="flex items-center gap-2">
                  <input
                    v-model="filters.fuelType"
                    type="radio"
                    :value="fuel"
                    class="w-4 h-4 text-primary-600"
                  />
                  <span class="text-sm text-gray-700 dark:text-gray-300">{{ fuel }}</span>
                </label>
              </div>
            </div>

            <button
              @click="resetFilters"
              class="w-full px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold"
            >
              Filtreleri Temizle
            </button>
          </div>
        </div>

        <!-- Results -->
        <div class="lg:col-span-3">
          <!-- Sort and View Toggle -->
          <div class="flex items-center justify-between mb-6">
            <div class="text-sm text-gray-600 dark:text-gray-400">
              <span class="font-semibold text-gray-900 dark:text-white">{{ filteredVehicles.length }}</span> araç bulundu
            </div>
            <div class="flex items-center gap-4">
              <select
                v-model="sortBy"
                class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-sm"
              >
                <option value="price-asc">Fiyat: Düşükten Yükseğe</option>
                <option value="price-desc">Fiyat: Yüksekten Düşüğe</option>
                <option value="year-desc">Yıl: Yeniden Eskiye</option>
                <option value="year-asc">Yıl: Eskiden Yeniye</option>
                <option value="km-asc">Km: Düşükten Yükseğe</option>
              </select>
              <div class="flex items-center gap-2">
                <button
                  @click="viewMode = 'grid'"
                  class="p-2 rounded-lg transition-colors"
                  :class="viewMode === 'grid' ? 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400' : 'bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400'"
                >
                  <Grid class="w-5 h-5" />
                </button>
                <button
                  @click="viewMode = 'list'"
                  class="p-2 rounded-lg transition-colors"
                  :class="viewMode === 'list' ? 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400' : 'bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400'"
                >
                  <List class="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>

          <!-- Grid View -->
          <div v-if="viewMode === 'grid'" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
            <div
              v-for="vehicle in sortedVehicles"
              :key="vehicle.id"
              class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-xl transition-all cursor-pointer group"
              @click="viewVehicle(vehicle.id)"
            >
              <div class="h-48 bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center relative">
                <Car class="w-20 h-20 text-white opacity-50" />
                <div class="absolute top-3 right-3">
                  <span class="px-2 py-1 bg-white/20 backdrop-blur-md text-white text-xs font-semibold rounded-full">
                    {{ vehicle.year }}
                  </span>
                </div>
              </div>
              <div class="p-6">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
                  {{ vehicle.brand }} {{ vehicle.model }}
                </h3>
                <div class="space-y-1 text-sm text-gray-600 dark:text-gray-400 mb-4">
                  <div class="flex items-center gap-2">
                    <span>{{ vehicle.km.toLocaleString() }} km</span>
                    <span>•</span>
                    <span>{{ vehicle.fuelType }}</span>
                    <span>•</span>
                    <span>{{ vehicle.transmission }}</span>
                  </div>
                  <div class="text-gray-500 dark:text-gray-400">{{ vehicle.location }}</div>
                </div>
                <div class="flex items-center justify-between pt-4 border-t border-gray-200 dark:border-gray-700">
                  <span class="text-2xl font-bold text-primary-600 dark:text-primary-400">
                    {{ vehicle.price.toLocaleString() }} ₺
                  </span>
                  <button class="px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold text-sm">
                    Detay
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- List View -->
          <div v-else class="space-y-4">
            <div
              v-for="vehicle in sortedVehicles"
              :key="vehicle.id"
              class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 hover:shadow-xl transition-all cursor-pointer group"
              @click="viewVehicle(vehicle.id)"
            >
              <div class="flex items-center gap-6">
                <div class="w-32 h-32 rounded-xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center flex-shrink-0">
                  <Car class="w-16 h-16 text-white opacity-50" />
                </div>
                <div class="flex-1">
                  <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
                    {{ vehicle.brand }} {{ vehicle.model }}
                  </h3>
                  <div class="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400 mb-2">
                    <span>{{ vehicle.year }}</span>
                    <span>•</span>
                    <span>{{ vehicle.km.toLocaleString() }} km</span>
                    <span>•</span>
                    <span>{{ vehicle.fuelType }}</span>
                    <span>•</span>
                    <span>{{ vehicle.transmission }}</span>
                    <span>•</span>
                    <span>{{ vehicle.location }}</span>
                  </div>
                </div>
                <div class="text-right">
                  <div class="text-2xl font-bold text-primary-600 dark:text-primary-400 mb-2">
                    {{ vehicle.price.toLocaleString() }} ₺
                  </div>
                  <button class="px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold text-sm">
                    Detay
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Search, Grid, List, Car } from 'lucide-vue-next'
import { ref, computed } from 'vue'

useHead({
  title: 'Araç Ara - Galeri Merkezi'
})

const viewMode = ref<'grid' | 'list'>('grid')
const sortBy = ref('price-asc')

const filters = ref({
  search: '',
  brand: '',
  minPrice: null as number | null,
  maxPrice: null as number | null,
  minYear: null as number | null,
  maxYear: null as number | null,
  fuelType: ''
})

const fuelTypes = ['Benzin', 'Dizel', 'Elektrik', 'Hibrit', 'LPG']

const vehicles = ref([
  {
    id: 1,
    brand: 'BMW',
    model: '320i',
    year: 2020,
    km: 45000,
    price: 850000,
    fuelType: 'Benzin',
    transmission: 'Otomatik',
    location: 'İstanbul'
  },
  {
    id: 2,
    brand: 'Mercedes',
    model: 'C200',
    year: 2019,
    km: 60000,
    price: 920000,
    fuelType: 'Dizel',
    transmission: 'Otomatik',
    location: 'Ankara'
  },
  {
    id: 3,
    brand: 'Audi',
    model: 'A4',
    year: 2021,
    km: 30000,
    price: 1150000,
    fuelType: 'Benzin',
    transmission: 'Otomatik',
    location: 'İzmir'
  },
  {
    id: 4,
    brand: 'Volkswagen',
    model: 'Passat',
    year: 2018,
    km: 75000,
    price: 650000,
    fuelType: 'Dizel',
    transmission: 'Manuel',
    location: 'Bursa'
  },
  {
    id: 5,
    brand: 'Ford',
    model: 'Focus',
    year: 2020,
    km: 50000,
    price: 580000,
    fuelType: 'Benzin',
    transmission: 'Manuel',
    location: 'Ankara'
  },
  {
    id: 6,
    brand: 'Toyota',
    model: 'Corolla',
    year: 2021,
    km: 25000,
    price: 720000,
    fuelType: 'Hibrit',
    transmission: 'Otomatik',
    location: 'İstanbul'
  }
])

const filteredVehicles = computed(() => {
  let filtered = vehicles.value

  if (filters.value.search) {
    const query = filters.value.search.toLowerCase()
    filtered = filtered.filter(v => 
      v.brand.toLowerCase().includes(query) ||
      v.model.toLowerCase().includes(query)
    )
  }

  if (filters.value.brand) {
    filtered = filtered.filter(v => v.brand.toLowerCase() === filters.value.brand)
  }

  if (filters.value.minPrice) {
    filtered = filtered.filter(v => v.price >= filters.value.minPrice!)
  }

  if (filters.value.maxPrice) {
    filtered = filtered.filter(v => v.price <= filters.value.maxPrice!)
  }

  if (filters.value.minYear) {
    filtered = filtered.filter(v => v.year >= filters.value.minYear!)
  }

  if (filters.value.maxYear) {
    filtered = filtered.filter(v => v.year <= filters.value.maxYear!)
  }

  if (filters.value.fuelType) {
    filtered = filtered.filter(v => v.fuelType === filters.value.fuelType)
  }

  return filtered
})

const sortedVehicles = computed(() => {
  const sorted = [...filteredVehicles.value]
  
  switch (sortBy.value) {
    case 'price-asc':
      return sorted.sort((a, b) => a.price - b.price)
    case 'price-desc':
      return sorted.sort((a, b) => b.price - a.price)
    case 'year-desc':
      return sorted.sort((a, b) => b.year - a.year)
    case 'year-asc':
      return sorted.sort((a, b) => a.year - b.year)
    case 'km-asc':
      return sorted.sort((a, b) => a.km - b.km)
    default:
      return sorted
  }
})

const resetFilters = () => {
  filters.value = {
    search: '',
    brand: '',
    minPrice: null,
    maxPrice: null,
    minYear: null,
    maxYear: null,
    fuelType: ''
  }
}

const viewVehicle = (id: number) => {
  // Navigate to vehicle detail page (would be implemented when vehicle detail page is ready)
  window.open(`/vehicles/${id}`, '_blank')
}
</script>

