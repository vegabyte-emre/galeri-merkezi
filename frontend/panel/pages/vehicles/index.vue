<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Araçlarım</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Araç envanterinizi yönetin</p>
      </div>
      <div class="flex items-center gap-3">
        <div class="flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-800 rounded-lg">
          <Search class="w-4 h-4 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Araç ara..."
            class="bg-transparent border-0 outline-0 text-sm text-gray-700 dark:text-gray-300 placeholder-gray-400 w-64"
          />
        </div>
        <select
          v-model="filterStatus"
          class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-700 dark:text-gray-300"
        >
          <option value="">Tüm Durumlar</option>
          <option value="published">Yayında</option>
          <option value="draft">Taslak</option>
          <option value="paused">Duraklatıldı</option>
          <option value="archived">Arşivlendi</option>
          <option value="sold">Satıldı</option>
        </select>
        <NuxtLink
          to="/vehicles/new"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all inline-flex items-center"
        >
          <Plus class="w-4 h-4 mr-2" />
          Yeni Araç
        </NuxtLink>
      </div>
    </div>

    <!-- Vehicles Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="vehicle in filteredVehicles"
        :key="vehicle.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-xl transition-all group"
      >
        <!-- Vehicle Image -->
        <div class="h-48 bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center relative">
          <Car class="w-20 h-20 text-white opacity-50" />
          <div class="absolute top-3 right-3">
            <span
              class="px-2 py-1 text-xs font-semibold rounded-full"
              :class="{
                'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': vehicle.status === 'published',
                'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400': vehicle.status === 'draft' || vehicle.status === 'archived',
                'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': vehicle.status === 'paused',
                'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400': vehicle.status === 'sold'
              }"
            >
              {{ statusLabels[vehicle.status] }}
            </span>
          </div>
        </div>

        <!-- Vehicle Info -->
        <div class="p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2">
            {{ vehicle.brand }} {{ vehicle.model }}
          </h3>
          <div class="space-y-2 text-sm text-gray-600 dark:text-gray-400 mb-4">
            <div class="flex items-center gap-2">
              <span>Yıl:</span>
              <span class="font-medium text-gray-900 dark:text-white">{{ vehicle.year }}</span>
            </div>
            <div class="flex items-center gap-2">
              <span>Km:</span>
              <span class="font-medium text-gray-900 dark:text-white">{{ formatNumber(vehicle.mileage) }} km</span>
            </div>
            <div class="flex items-center gap-2">
              <span>Fiyat:</span>
              <span class="font-bold text-primary-600 dark:text-primary-400 text-lg">{{ formatCurrency(vehicle.base_price) }}</span>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex items-center gap-2 pt-4 border-t border-gray-200 dark:border-gray-700">
            <button
              @click="editVehicle(vehicle.id)"
              class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-sm font-semibold"
            >
              Düzenle
            </button>
            <button
              @click="deleteVehicle(vehicle.id)"
              class="px-3 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors text-sm font-semibold"
            >
              Sil
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Add Vehicle Modal -->
    <div
      v-if="showAddModal"
      class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      @click="showAddModal = false"
    >
      <div
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto"
        @click.stop
      >
        <div class="p-6 border-b border-gray-200 dark:border-gray-700">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Yeni Araç Ekle</h2>
        </div>
        <div class="p-6 space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Marka</label>
              <input
                v-model="newVehicle.brand"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="BMW"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Model</label>
              <input
                v-model="newVehicle.model"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="320i"
              />
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Yıl</label>
              <input
                v-model.number="newVehicle.year"
                type="number"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="2020"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Km</label>
              <input
                v-model.number="newVehicle.km"
                type="number"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="45000"
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Fiyat</label>
            <input
              v-model.number="newVehicle.price"
              type="number"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="850000"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Açıklama</label>
            <textarea
              v-model="newVehicle.description"
              rows="3"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="Araç açıklaması..."
            ></textarea>
          </div>
        </div>
        <div class="p-6 border-t border-gray-200 dark:border-gray-700 flex items-center justify-end gap-3">
          <button
            @click="showAddModal = false"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          >
            İptal
          </button>
          <button
            @click="addVehicle"
            class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Kaydet
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Search, Plus, Car } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const loading = ref(false)

const searchQuery = ref('')
const filterStatus = ref('')
const showAddModal = ref(false)

const statusLabels: Record<string, string> = {
  published: 'Aktif',
  draft: 'Taslak',
  paused: 'Duraklatıldı',
  archived: 'Arşivlendi',
  sold: 'Satıldı'
}

const newVehicle = ref({
  brand: '',
  model: '',
  year: null as number | null,
  km: null as number | null,
  price: null as number | null,
  description: ''
})

const vehicles = ref<any[]>([])

const loadVehicles = async () => {
  loading.value = true
  try {
    const response = await api.get<{ success: boolean; data?: any[]; pagination?: any }>('/vehicles')
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

const filteredVehicles = computed(() => {
  let filtered = vehicles.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(v => 
      v.brand.toLowerCase().includes(query) ||
      v.model.toLowerCase().includes(query)
    )
  }

  if (filterStatus.value) {
    filtered = filtered.filter(v => v.status === filterStatus.value)
  }

  return filtered
})

const addVehicle = async () => {
  if (newVehicle.value.brand && newVehicle.value.model && newVehicle.value.year && newVehicle.value.price) {
    try {
      await api.post('/vehicles', {
        brand: newVehicle.value.brand,
        model: newVehicle.value.model,
        year: newVehicle.value.year,
        mileage: newVehicle.value.km || 0,
        basePrice: newVehicle.value.price,
        description: newVehicle.value.description,
        fuelType: 'benzin',
        transmission: 'manuel',
        bodyType: 'sedan',
        color: 'Beyaz',
        vehicleCondition: 'İkinci El',
        sellerType: 'gallery'
      })
      
      // Reset form
      newVehicle.value = {
        brand: '',
        model: '',
        year: null,
        km: null,
        price: null,
        description: ''
      }
      showAddModal.value = false
      toast.success('Araç başarıyla eklendi!')
      await loadVehicles()
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  } else {
    toast.warning('Lütfen tüm gerekli alanları doldurun')
  }
}

const editVehicle = (id: string) => {
  navigateTo(`/vehicles/${id}/edit`)
}

const deleteVehicle = async (id: number) => {
  if (confirm('Bu aracı silmek istediğinize emin misiniz?')) {
    try {
      await api.delete(`/vehicles/${id}`)
      
      const index = vehicles.value.findIndex(v => v.id === id)
      if (index > -1) {
        vehicles.value.splice(index, 1)
      }
      toast.success('Araç başarıyla silindi!')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const formatNumber = (num: number) => {
  return new Intl.NumberFormat('tr-TR').format(num || 0)
}

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('tr-TR', {
    style: 'currency',
    currency: 'TRY',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(amount || 0)
}

onMounted(() => {
  loadVehicles()
})
</script>

