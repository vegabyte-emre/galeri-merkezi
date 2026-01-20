<template>
  <div class="space-y-6" v-if="user">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <NuxtLink
          to="/users"
          class="text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 mb-2 inline-flex items-center gap-1"
        >
          <ArrowLeft class="w-4 h-4" />
          Kullanıcılara Dön
        </NuxtLink>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
          {{ user.name }}
        </h1>
      </div>
      <div class="flex items-center gap-3">
        <button
          @click="editUser"
          class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold"
        >
          Düzenle
        </button>
        <button
          @click="deleteUser"
          class="px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold"
        >
          Sil
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Main Content -->
      <div class="lg:col-span-2 space-y-6">
        <!-- User Info -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Kullanıcı Bilgileri</h2>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Ad Soyad</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ user.name }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">E-posta</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ user.email }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Telefon</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ user.phone || '-' }}</div>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Rol</div>
              <span
                class="inline-block px-2 py-1 text-xs font-semibold rounded-full"
                :class="{
                  'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400': user.role === 'admin',
                  'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400': user.role === 'gallery_owner',
                  'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400': user.role === 'user'
                }"
              >
                {{ roleLabels[user.role] }}
              </span>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Durum</div>
              <span
                class="inline-block px-2 py-1 text-xs font-semibold rounded-full"
                :class="user.status === 'active' 
                  ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' 
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400'"
              >
                {{ user.status === 'active' ? 'Aktif' : 'Pasif' }}
              </span>
            </div>
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Kayıt Tarihi</div>
              <div class="font-semibold text-gray-900 dark:text-white">{{ formatDate(user.createdAt) }}</div>
            </div>
          </div>
        </div>

        <!-- Gallery Info -->
        <div v-if="user.gallery" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Galeri Bilgileri</h2>
          <div class="flex items-center gap-4">
            <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold text-xl">
              {{ user.gallery.name.charAt(0) }}
            </div>
            <div>
              <div class="font-bold text-gray-900 dark:text-white">{{ user.gallery.name }}</div>
              <div class="text-sm text-gray-500 dark:text-gray-400">{{ user.gallery.location }}</div>
            </div>
            <NuxtLink
              :to="`/galleries/${user.gallery.id}`"
              class="ml-auto px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold text-sm"
            >
              Galeriyi Görüntüle
            </NuxtLink>
          </div>
        </div>

        <!-- Activity Log -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Son Aktiviteler</h2>
          <div class="space-y-3">
            <div
              v-for="(activity, index) in activities"
              :key="index"
              class="flex items-start gap-3 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-xl"
            >
              <div class="w-8 h-8 rounded-lg bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center flex-shrink-0">
                <component :is="activity.icon" class="w-4 h-4 text-primary-600 dark:text-primary-400" />
              </div>
              <div class="flex-1">
                <div class="font-medium text-gray-900 dark:text-white">{{ activity.action }}</div>
                <div class="text-xs text-gray-500 dark:text-gray-400">{{ formatDateTime(activity.timestamp) }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="space-y-6">
        <!-- User Stats -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">İstatistikler</h3>
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-600 dark:text-gray-400">Toplam Giriş</span>
              <span class="font-semibold text-gray-900 dark:text-white">{{ user.totalLogins }}</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-600 dark:text-gray-400">Son Giriş</span>
              <span class="font-semibold text-gray-900 dark:text-white">{{ formatDate(user.lastLogin) }}</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-600 dark:text-gray-400">Araç Sayısı</span>
              <span class="font-semibold text-gray-900 dark:text-white">{{ user.vehicleCount || 0 }}</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-600 dark:text-gray-400">Teklif Sayısı</span>
              <span class="font-semibold text-gray-900 dark:text-white">{{ user.offerCount || 0 }}</span>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Hızlı İşlemler</h3>
          <div class="space-y-2">
            <button
              @click="resetPassword"
              class="w-full px-4 py-2 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400 rounded-lg hover:bg-yellow-200 dark:hover:bg-yellow-900/50 transition-colors font-semibold text-sm"
            >
              Şifreyi Sıfırla
            </button>
            <button
              @click="toggleStatus"
              class="w-full px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold text-sm"
            >
              {{ user.status === 'active' ? 'Hesabı Askıya Al' : 'Hesabı Aktifleştir' }}
            </button>
            <button
              @click="sendEmail"
              class="w-full px-4 py-2 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400 rounded-lg hover:bg-blue-200 dark:hover:bg-blue-900/50 transition-colors font-semibold text-sm"
            >
              E-posta Gönder
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft, Car, Users, Settings } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const route = useRoute()
const router = useRouter()
const toast = useToast()

const roleLabels: Record<string, string> = {
  admin: 'Admin',
  gallery_owner: 'Galeri Sahibi',
  user: 'Kullanıcı'
}

const user = ref<any>(null)

const activities = ref([
  { icon: Car, action: 'Yeni araç eklendi', timestamp: '2024-01-20T14:30:00' },
  { icon: Users, action: 'Teklif gönderildi', timestamp: '2024-01-20T12:15:00' },
  { icon: Settings, action: 'Ayarlar güncellendi', timestamp: '2024-01-19T16:45:00' }
])

onMounted(async () => {
  try {
    const api = useApi()
    user.value = await api.get(`/users/${route.params.id}`)
  } catch (error: any) {
    toast.error('Kullanıcı bilgileri yüklenemedi: ' + error.message)
    router.push('/users')
  }
})

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR')
}

const formatDateTime = (timestamp: string) => {
  return new Date(timestamp).toLocaleString('tr-TR')
}

const editUser = () => {
  // Navigate to edit page or open modal
  router.push(`/users/${user.value?.id}/edit`)
}

const deleteUser = async () => {
  if (confirm('Bu kullanıcıyı silmek istediğinize emin misiniz?')) {
    try {
      const api = useApi()
      await api.delete(`/users/${user.value?.id}`)
      toast.success('Kullanıcı silindi!')
      router.push('/users')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const resetPassword = async () => {
  if (confirm('Bu kullanıcının şifresini sıfırlamak istediğinize emin misiniz?')) {
    try {
      const api = useApi()
      await api.post(`/users/${user.value?.id}/reset-password`)
      alert('Şifre sıfırlama e-postası gönderildi!')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const toggleStatus = async () => {
  if (user.value) {
    try {
      const api = useApi()
      const newStatus = user.value.status === 'active' ? 'inactive' : 'active'
      await api.put(`/users/${user.value.id}/status`, { status: newStatus })
      user.value.status = newStatus
      toast.success(`Kullanıcı durumu ${newStatus === 'active' ? 'aktif' : 'pasif'} olarak güncellendi!`)
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const sendEmail = () => {
  // Open email modal or navigate
  const email = user.value?.email
  if (email) {
    window.location.href = `mailto:${email}`
  }
}
</script>

