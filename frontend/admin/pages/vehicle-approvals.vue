<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Araç Onayları</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Galerilerden gelen araç onay taleplerini yönetin</p>
      </div>
      <div class="flex items-center gap-3">
        <div class="px-4 py-2 bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-400 rounded-lg font-semibold">
          {{ pendingCount }} Onay Bekliyor
        </div>
      </div>
    </div>

    <!-- Pending Vehicles List -->
    <div v-if="loading" class="flex items-center justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"></div>
    </div>

    <div v-else-if="vehicles.length === 0" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-12 text-center">
      <CheckCircle class="w-16 h-16 text-green-500 mx-auto mb-4" />
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">Tüm Onaylar Tamamlandı</h3>
      <p class="text-gray-500 dark:text-gray-400">Şu anda onay bekleyen araç bulunmuyor.</p>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="vehicle in vehicles"
        :key="vehicle.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden"
      >
        <div class="p-6">
          <div class="flex items-start justify-between">
            <!-- Vehicle Info -->
            <div class="flex items-start gap-4">
              <div class="w-32 h-24 bg-gradient-to-br from-primary-400 to-primary-600 rounded-xl flex items-center justify-center">
                <Car class="w-12 h-12 text-white opacity-50" />
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white">
                  {{ vehicle.brand }} {{ vehicle.model }}
                </h3>
                <div class="mt-2 space-y-1 text-sm text-gray-600 dark:text-gray-400">
                  <p><span class="font-medium">Yıl:</span> {{ vehicle.year }}</p>
                  <p><span class="font-medium">Kilometre:</span> {{ formatNumber(vehicle.mileage) }} km</p>
                  <p><span class="font-medium">Fiyat:</span> {{ formatCurrency(vehicle.base_price) }}</p>
                  <p><span class="font-medium">Yakıt:</span> {{ vehicle.fuel_type }} | <span class="font-medium">Vites:</span> {{ vehicle.transmission }}</p>
                </div>
              </div>
            </div>

            <!-- Gallery Info -->
            <div class="text-right">
              <div class="px-3 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400 rounded-full text-sm font-medium">
                {{ vehicle.gallery_name || 'Galeri' }}
              </div>
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
                {{ vehicle.gallery_city || '' }}
              </p>
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                Gönderilme: {{ formatDate(vehicle.submitted_at) }}
              </p>
            </div>
          </div>

          <!-- Description -->
          <div v-if="vehicle.description" class="mt-4 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
            <p class="text-sm text-gray-600 dark:text-gray-400 line-clamp-2">{{ vehicle.description }}</p>
          </div>

          <!-- Actions -->
          <div class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700 flex items-center justify-between">
            <button
              @click="showRejectModal(vehicle)"
              :disabled="actionLoading === vehicle.id"
              class="px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold flex items-center gap-2"
            >
              <XCircle class="w-4 h-4" />
              Reddet
            </button>
            <button
              @click="approveVehicle(vehicle.id)"
              :disabled="actionLoading === vehicle.id"
              class="px-6 py-2 bg-gradient-to-r from-green-500 to-green-600 text-white rounded-lg hover:shadow-lg transition-all font-semibold flex items-center gap-2"
            >
              <CheckCircle class="w-4 h-4" />
              {{ actionLoading === vehicle.id ? 'İşleniyor...' : 'Onayla ve Yayınla' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Reject Modal -->
    <div
      v-if="rejectModalOpen"
      class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      @click="rejectModalOpen = false"
    >
      <div
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-md w-full"
        @click.stop
      >
        <div class="p-6 border-b border-gray-200 dark:border-gray-700">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Aracı Reddet</h2>
          <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
            {{ selectedVehicle?.brand }} {{ selectedVehicle?.model }}
          </p>
        </div>
        <div class="p-6">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Reddedilme Sebebi *
          </label>
          <textarea
            v-model="rejectReason"
            rows="4"
            class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            placeholder="Reddedilme sebebini açıklayın..."
          ></textarea>
        </div>
        <div class="p-6 border-t border-gray-200 dark:border-gray-700 flex items-center justify-end gap-3">
          <button
            @click="rejectModalOpen = false"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          >
            İptal
          </button>
          <button
            @click="rejectVehicle"
            :disabled="!rejectReason.trim() || actionLoading"
            class="px-4 py-2 bg-red-500 text-white font-semibold rounded-lg hover:bg-red-600 transition-colors disabled:opacity-50"
          >
            {{ actionLoading ? 'İşleniyor...' : 'Reddet' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Car, CheckCircle, XCircle } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()

const loading = ref(true)
const actionLoading = ref<string | null>(null)
const vehicles = ref<any[]>([])
const rejectModalOpen = ref(false)
const selectedVehicle = ref<any>(null)
const rejectReason = ref('')

const pendingCount = computed(() => vehicles.value.length)

const loadPendingVehicles = async () => {
  loading.value = true
  try {
    const response = await api.get<any>('/vehicles/pending-approval')
    if (response.success && response.data) {
      vehicles.value = response.data
    }
  } catch (error: any) {
    console.error('Onay bekleyen araçlar yüklenemedi:', error)
    toast.error('Onay bekleyen araçlar yüklenemedi')
  } finally {
    loading.value = false
  }
}

const approveVehicle = async (vehicleId: string) => {
  actionLoading.value = vehicleId
  try {
    await api.post(`/vehicles/${vehicleId}/approve`)
    toast.success('Araç onaylandı ve Oto Pazarı\'nda yayınlandı!')
    vehicles.value = vehicles.value.filter(v => v.id !== vehicleId)
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    actionLoading.value = null
  }
}

const showRejectModal = (vehicle: any) => {
  selectedVehicle.value = vehicle
  rejectReason.value = ''
  rejectModalOpen.value = true
}

const rejectVehicle = async () => {
  if (!selectedVehicle.value || !rejectReason.value.trim()) return

  actionLoading.value = selectedVehicle.value.id
  try {
    await api.post(`/vehicles/${selectedVehicle.value.id}/reject`, {
      reason: rejectReason.value
    })
    toast.success('Araç reddedildi')
    vehicles.value = vehicles.value.filter(v => v.id !== selectedVehicle.value.id)
    rejectModalOpen.value = false
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    actionLoading.value = null
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

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('tr-TR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  loadPendingVehicles()
})
</script>
