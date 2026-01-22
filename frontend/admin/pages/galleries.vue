<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Galeriler</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Tüm galerileri görüntüleyin ve yönetin</p>
      </div>
      <div class="flex items-center gap-3">
        <div class="flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-800 rounded-lg">
          <Search class="w-4 h-4 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Galeri ara..."
            class="bg-transparent border-0 outline-0 text-sm text-gray-700 dark:text-gray-300 placeholder-gray-400 w-64"
          />
        </div>
        <select
          v-model="filterStatus"
          class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-700 dark:text-gray-300"
        >
          <option value="">Tüm Durumlar</option>
          <option value="pending">Bekleyen</option>
          <option value="active">Aktif</option>
          <option value="suspended">Askıya Alınmış</option>
        </select>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400">Toplam Galeri</div>
        <div class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ stats.total || galleries.length }}</div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400">Bekleyen</div>
        <div class="text-2xl font-bold text-yellow-600 dark:text-yellow-400 mt-1">{{ stats.pending || pendingCount }}</div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400">Aktif</div>
        <div class="text-2xl font-bold text-green-600 dark:text-green-400 mt-1">{{ stats.active || activeCount }}</div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400">Askıya Alınmış</div>
        <div class="text-2xl font-bold text-red-600 dark:text-red-400 mt-1">{{ stats.suspended || suspendedCount }}</div>
      </div>
    </div>

    <!-- Galleries Table -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Galeri</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">İletişim</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Durum</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Araç Sayısı</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Kayıt Tarihi</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">İşlemler</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="gallery in filteredGalleries"
              :key="gallery.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold">
                    {{ gallery.name.charAt(0) }}
                  </div>
                  <div>
                    <div class="font-medium text-gray-900 dark:text-white">{{ gallery.name }}</div>
                    <div class="text-sm text-gray-500 dark:text-gray-400">{{ gallery.location }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-900 dark:text-white">{{ gallery.email }}</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">{{ gallery.phone }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': gallery.status === 'pending',
                    'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': gallery.status === 'active',
                    'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400': gallery.status === 'suspended'
                  }"
                >
                  {{ statusLabels[gallery.status] }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                {{ gallery.vehicleCount }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatDate(gallery.createdAt) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex items-center justify-end gap-2">
                  <button
                    v-if="gallery.status === 'pending'"
                    @click="approveGallery(gallery.id)"
                    class="px-3 py-1.5 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-lg hover:bg-green-200 dark:hover:bg-green-900/50 transition-colors text-xs font-semibold"
                  >
                    Onayla
                  </button>
                  <button
                    v-if="gallery.status === 'pending'"
                    @click="rejectGallery(gallery.id)"
                    class="px-3 py-1.5 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors text-xs font-semibold"
                  >
                    Reddet
                  </button>
                  <button
                    v-if="gallery.status === 'active'"
                    @click="suspendGallery(gallery.id)"
                    class="px-3 py-1.5 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400 rounded-lg hover:bg-yellow-200 dark:hover:bg-yellow-900/50 transition-colors text-xs font-semibold"
                  >
                    Askıya Al
                  </button>
                  <button
                    @click="viewDetails(gallery.id)"
                    class="px-3 py-1.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-xs font-semibold"
                  >
                    Detay
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Reject Modal -->
    <div
      v-if="showRejectModal"
      class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      @click.self="showRejectModal = false"
    >
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-md w-full p-6">
        <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">
          Galeriyi Reddet
        </h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Reddetme Sebebi
            </label>
            <textarea
              v-model="rejectReason"
              rows="4"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="Reddetme sebebini giriniz..."
            ></textarea>
          </div>
        </div>
        <div class="flex items-center justify-end gap-3 mt-6">
          <button
            @click="showRejectModal = false; rejectingGallery = null; rejectReason = ''"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          >
            İptal
          </button>
          <button
            @click="confirmReject"
            class="px-4 py-2 bg-red-600 text-white font-semibold rounded-lg hover:bg-red-700 transition-colors"
          >
            Reddet
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Search } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const router = useRouter()
const api = useApi()
const toast = useToast()
const loading = ref(false)

const searchQuery = ref('')
const filterStatus = ref('')

const statusLabels: Record<string, string> = {
  pending: 'Bekleyen',
  active: 'Aktif',
  suspended: 'Askıya Alınmış'
}

const galleries = ref<any[]>([])
const stats = ref({
  total: 0,
  pending: 0,
  active: 0,
  suspended: 0
})
const showRejectModal = ref(false)
const rejectingGallery = ref<any>(null)
const rejectReason = ref('')

const filteredGalleries = computed(() => {
  let filtered = galleries.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(g => 
      g.name.toLowerCase().includes(query) ||
      g.location.toLowerCase().includes(query) ||
      g.email.toLowerCase().includes(query)
    )
  }

  if (filterStatus.value) {
    filtered = filtered.filter(g => g.status === filterStatus.value)
  }

  return filtered
})

const pendingCount = computed(() => galleries.value.filter(g => g.status === 'pending').length)
const activeCount = computed(() => galleries.value.filter(g => g.status === 'active').length)
const suspendedCount = computed(() => galleries.value.filter(g => g.status === 'suspended').length)

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR')
}

const loadGalleries = async () => {
  loading.value = true
  try {
    const response = await api.get<any>('/admin/galleries')
    // Handle both response formats
    if (response.success) {
      galleries.value = response.galleries || []
      // Update stats from response
      if (response.stats) {
        stats.value = {
          total: response.stats.total || 0,
          pending: response.stats.pending || 0,
          active: response.stats.active || 0,
          suspended: response.stats.suspended || 0
        }
      } else if (response.pagination) {
        // Fallback: use pagination total and count from loaded galleries
        stats.value = {
          total: response.pagination.total || galleries.value.length,
          pending: pendingCount.value,
          active: activeCount.value,
          suspended: suspendedCount.value
        }
      }
    } else if (Array.isArray(response)) {
      galleries.value = response
    } else if (response.data && Array.isArray(response.data)) {
      galleries.value = response.data
    } else {
      galleries.value = []
    }
  } catch (error: any) {
    console.error('Galeriler yüklenemedi:', error)
    toast.error('Galeriler yüklenemedi: ' + error.message)
    galleries.value = []
  } finally {
    loading.value = false
  }
}

const approveGallery = async (id: number) => {
  const gallery = galleries.value.find(g => g.id === id)
  if (!gallery) return
  
  if (!confirm('Bu galeriyi onaylamak istediğinize emin misiniz?')) return
  
  try {
    await api.post(`/admin/galleries/${id}/approve`)
    toast.success('Galeri onaylandı!')
    await loadGalleries()
  } catch (error: any) {
    toast.error('Onaylama hatası: ' + error.message)
  }
}

const rejectGallery = (id: number) => {
  const gallery = galleries.value.find(g => g.id === id)
  if (gallery) {
    rejectingGallery.value = gallery
    rejectReason.value = ''
    showRejectModal.value = true
  }
}

const confirmReject = async () => {
  if (!rejectingGallery.value || !rejectReason.value.trim()) {
    toast.warning('Lütfen reddetme sebebini giriniz')
    return
  }
  
  try {
    await api.post(`/admin/galleries/${rejectingGallery.value.id}/reject`, { reason: rejectReason.value })
    toast.success('Galeri reddedildi!')
    showRejectModal.value = false
    rejectingGallery.value = null
    rejectReason.value = ''
    await loadGalleries()
  } catch (error: any) {
    toast.error('Reddetme hatası: ' + error.message)
  }
}

const suspendGallery = async (id: number) => {
  const gallery = galleries.value.find(g => g.id === id)
  if (!gallery) return
  
  if (!confirm('Bu galeriyi askıya almak istediğinize emin misiniz?')) return
  
  try {
    await api.post(`/admin/galleries/${id}/suspend`)
    toast.success('Galeri askıya alındı!')
    await loadGalleries()
  } catch (error: any) {
    toast.error('Askıya alma hatası: ' + error.message)
  }
}

const viewDetails = (id: number) => {
  router.push(`/galleries/${id}`)
}

onMounted(() => {
  loadGalleries()
})
</script>

