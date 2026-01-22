<template>
  <div class="space-y-6" v-if="gallery">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <NuxtLink
          to="/galleries"
          class="text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 mb-2 inline-flex items-center gap-1"
        >
          <ArrowLeft class="w-4 h-4" />
          Galerilere Dön
        </NuxtLink>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
          {{ gallery.name }}
        </h1>
      </div>
      <div class="flex items-center gap-3">
        <button
          v-if="gallery.status === 'pending'"
          @click="approveGallery"
          class="px-4 py-2 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-lg hover:bg-green-200 dark:hover:bg-green-900/50 transition-colors font-semibold"
        >
          Onayla
        </button>
        <button
          v-if="gallery.status === 'pending'"
          @click="rejectGallery"
          class="px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold"
        >
          Reddet
        </button>
        <button
          v-if="gallery.status === 'active'"
          @click="suspendGallery"
          class="px-4 py-2 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400 rounded-lg hover:bg-yellow-200 dark:hover:bg-yellow-900/50 transition-colors font-semibold"
        >
          Askıya Al
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Main Content -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Gallery Info -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Galeri Bilgileri</h2>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Galeri Adı</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ gallery.name }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Durum</div>
              <span
                class="inline-block px-2 py-1 text-xs font-semibold rounded-full"
                :class="{
                  'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': gallery.status === 'pending',
                  'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': gallery.status === 'active',
                  'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400': gallery.status === 'suspended'
                }"
              >
                {{ statusLabels[gallery.status] }}
              </span>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Konum</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ gallery.location }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Kayıt Tarihi</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ formatDate(gallery.createdAt) }}</div>
            </div>
          </div>
        </div>

        <!-- Contact Info -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">İletişim Bilgileri</h2>
          <div class="space-y-3">
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">E-posta</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ gallery.email }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Telefon</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ gallery.phone }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Adres</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ gallery.address || 'Belirtilmemiş' }}</div>
            </div>
          </div>
        </div>

        <!-- Statistics -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">İstatistikler</h2>
          <div class="grid grid-cols-3 gap-4">
            <div class="text-center p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
              <div class="text-2xl font-bold text-gray-900 dark:text-white mb-1">{{ gallery.vehicleCount }}</div>
              <div class="text-sm text-gray-600 dark:text-gray-400">Araç</div>
            </div>
            <div class="text-center p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
              <div class="text-2xl font-bold text-gray-900 dark:text-white mb-1">{{ gallery.activeOffers }}</div>
              <div class="text-sm text-gray-600 dark:text-gray-400">Aktif Teklif</div>
            </div>
            <div class="text-center p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
              <div class="text-2xl font-bold text-gray-900 dark:text-white mb-1">{{ gallery.totalSales }}</div>
              <div class="text-sm text-gray-600 dark:text-gray-400">Toplam Satış</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="space-y-6">
        <!-- Owner Info -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Galeri Sahibi</h3>
          <div class="flex items-center gap-3 mb-4">
            <div class="w-12 h-12 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold">
              {{ gallery.ownerName.charAt(0) }}
            </div>
            <div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ gallery.ownerName }}</div>
              <div class="text-sm text-gray-500 dark:text-gray-400">{{ gallery.ownerEmail }}</div>
            </div>
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400">
            <div class="mb-1">Telefon: {{ gallery.ownerPhone }}</div>
            <div>Kayıt: {{ formatDate(gallery.ownerCreatedAt) }}</div>
          </div>
        </div>

        <!-- Recent Activity -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Son Aktiviteler</h3>
          <div class="space-y-3">
            <div
              v-for="(activity, index) in activities"
              :key="index"
              class="text-sm"
            >
              <div class="font-medium text-gray-900 dark:text-white">{{ activity.action }}</div>
              <div class="text-xs text-gray-500 dark:text-gray-400">{{ formatDate(activity.date) }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const route = useRoute()
const router = useRouter()
const toast = useToast()

const statusLabels: Record<string, string> = {
  pending: 'Bekleyen',
  active: 'Aktif',
  suspended: 'Askıya Alınmış'
}

const gallery = ref<any>(null)

const activities = ref([
  { action: 'Yeni araç eklendi', date: '2024-01-20' },
  { action: 'Teklif gönderildi', date: '2024-01-19' },
  { action: 'Galeri onaylandı', date: '2024-01-10' }
])

const loadGallery = async () => {
  try {
    const api = useApi()
    const response = await api.get(`/admin/galleries/${route.params.id}`)
    gallery.value = response.data || response
  } catch (error: any) {
    toast.error('Galeri bilgileri yüklenemedi: ' + error.message)
    router.push('/galleries')
  }
}

onMounted(() => {
  loadGallery()
})

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR')
}

const approveGallery = async () => {
  if (gallery.value) {
    try {
      const api = useApi()
      await api.post(`/admin/galleries/${gallery.value.id}/approve`)
      gallery.value.status = 'active'
      toast.success('Galeri onaylandı!')
      await loadGallery()
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const rejectGallery = async () => {
  if (confirm('Bu galeriyi reddetmek istediğinize emin misiniz?')) {
    if (gallery.value) {
      try {
        const api = useApi()
        await api.post(`/admin/galleries/${gallery.value.id}/reject`, { reason: 'Reddedildi' })
        gallery.value.status = 'rejected'
        toast.success('Galeri reddedildi!')
        await loadGallery()
      } catch (error: any) {
        toast.error('Hata: ' + error.message)
      }
    }
  }
}

const suspendGallery = async () => {
  if (confirm('Bu galeriyi askıya almak istediğinize emin misiniz?')) {
    if (gallery.value) {
      try {
        const api = useApi()
        await api.post(`/admin/galleries/${gallery.value.id}/suspend`)
        gallery.value.status = 'suspended'
        toast.success('Galeri askıya alındı!')
        await loadGallery()
      } catch (error: any) {
        toast.error('Hata: ' + error.message)
      }
    }
  }
}
</script>

