<template>
  <div class="space-y-6">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Ayarlar</h1>
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Galeri ayarlarınızı yönetin</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Settings Navigation -->
      <div class="lg:col-span-1">
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-4">
          <nav class="space-y-2">
            <button
              v-for="tab in tabs"
              :key="tab.id"
              @click="activeTab = tab.id"
              class="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-colors"
              :class="activeTab === tab.id 
                ? 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 font-semibold' 
                : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'"
            >
              <component :is="tab.icon" class="w-5 h-5" />
              <span>{{ tab.label }}</span>
            </button>
          </nav>
        </div>
      </div>

      <!-- Settings Content -->
      <div class="lg:col-span-2">
        <!-- Loading State -->
        <div v-if="loading" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-12 flex items-center justify-center">
          <Loader2 class="w-8 h-8 text-primary-500 animate-spin" />
        </div>

        <!-- Profile Settings -->
        <div v-else-if="activeTab === 'profile'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Galeri Bilgileri</h2>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Galeri Adı</label>
              <input
                v-model="profile.name"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">E-posta</label>
              <input
                v-model="profile.email"
                type="email"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Telefon</label>
              <input
                v-model="profile.phone"
                type="tel"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">WhatsApp</label>
              <input
                v-model="profile.whatsapp"
                type="tel"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="+90 5XX XXX XX XX"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Sehir</label>
              <input
                v-model="profile.city"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Ilce</label>
              <input
                v-model="profile.district"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Adres</label>
              <textarea
                v-model="profile.address"
                rows="3"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              ></textarea>
            </div>
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Calisma Saatleri</label>
              <input
                v-model="profile.working_hours"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="Hafta ici 09:00-18:00, Cumartesi 10:00-16:00"
              />
            </div>
          </div>

          <button 
            @click="saveSettings" 
            :disabled="saving"
            class="px-6 py-2.5 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 flex items-center gap-2"
          >
            <Loader2 v-if="saving" class="w-4 h-4 animate-spin" />
            {{ saving ? 'Kaydediliyor...' : 'Kaydet' }}
          </button>

          <!-- Password Change -->
          <div class="pt-6 border-t border-gray-200 dark:border-gray-700 space-y-4">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Şifre Değiştir</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="md:col-span-2">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Mevcut Şifre</label>
                <input
                  v-model="passwordForm.currentPassword"
                  type="password"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="Mevcut şifreniz"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Yeni Şifre</label>
                <input
                  v-model="passwordForm.newPassword"
                  type="password"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="Yeni şifreniz"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Yeni Şifre (Tekrar)</label>
                <input
                  v-model="passwordForm.newPasswordConfirm"
                  type="password"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="Yeni şifreniz (tekrar)"
                />
              </div>
            </div>

            <button
              @click="changePassword"
              :disabled="passwordChanging"
              class="px-6 py-2.5 bg-gradient-to-r from-gray-800 to-gray-900 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 flex items-center gap-2"
            >
              <Loader2 v-if="passwordChanging" class="w-4 h-4 animate-spin" />
              {{ passwordChanging ? 'Değiştiriliyor...' : 'Şifreyi Değiştir' }}
            </button>
          </div>
        </div>

        <!-- Channel Settings -->
        <div v-else-if="activeTab === 'channels'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Kanal Baglantilari</h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">Araclarinizi yayinlayacaginiz pazar yerlerini yonetin</p>
          
          <div class="space-y-4">
            <div
              v-for="channel in channels"
              :key="channel.id"
              class="flex items-center justify-between p-4 rounded-xl border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 transition-colors"
            >
              <div class="flex items-center gap-3">
                <div 
                  class="w-12 h-12 rounded-xl flex items-center justify-center text-white font-bold text-lg"
                  :class="channel.status === 'connected' 
                    ? 'bg-gradient-to-br from-green-400 to-green-600' 
                    : 'bg-gradient-to-br from-gray-400 to-gray-600'"
                >
                  {{ channel.name.charAt(0) }}
                </div>
                <div>
                  <div class="font-semibold text-gray-900 dark:text-white">{{ channel.name }}</div>
                  <div class="text-sm flex items-center gap-2">
                    <span 
                      class="inline-flex items-center gap-1"
                      :class="channel.status === 'connected' ? 'text-green-600 dark:text-green-400' : 'text-gray-500 dark:text-gray-400'"
                    >
                      <span class="w-2 h-2 rounded-full" :class="channel.status === 'connected' ? 'bg-green-500' : 'bg-gray-400'"></span>
                      {{ channel.status === 'connected' ? 'Bagli' : 'Bagli Degil' }}
                    </span>
                    <span v-if="channel.type" class="text-gray-400">• {{ channel.type }}</span>
                  </div>
                </div>
              </div>
              <button
                @click="toggleChannel(channel.id)"
                class="px-5 py-2.5 rounded-xl font-semibold transition-all"
                :class="channel.status === 'connected' 
                  ? 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 hover:bg-red-200 dark:hover:bg-red-900/50' 
                  : 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 hover:bg-green-200 dark:hover:bg-green-900/50'"
              >
                {{ channel.status === 'connected' ? 'Baglantiyi Kes' : 'Baglan' }}
              </button>
            </div>

            <div v-if="channels.length === 0" class="text-center py-8 text-gray-500 dark:text-gray-400">
              <Link class="w-12 h-12 mx-auto mb-3 opacity-50" />
              <p>Henuz kanal bulunmuyor</p>
            </div>
          </div>
        </div>

        <!-- Notification Settings -->
        <div v-else-if="activeTab === 'notifications'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Bildirim Ayarlari</h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">Hangi durumlarda bildirim almak istediginizi secin</p>
          
          <div class="space-y-4">
            <label class="flex items-center justify-between p-4 rounded-xl border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 transition-colors cursor-pointer">
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Yeni Teklif</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">Araciniza yeni teklif geldiginde bildirim al</div>
              </div>
              <input
                v-model="notifications.newOffer"
                type="checkbox"
                class="w-5 h-5 text-primary-600 rounded focus:ring-primary-500"
              />
            </label>

            <label class="flex items-center justify-between p-4 rounded-xl border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 transition-colors cursor-pointer">
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Yeni Mesaj</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">Yeni mesaj geldiginde bildirim al</div>
              </div>
              <input
                v-model="notifications.newMessage"
                type="checkbox"
                class="w-5 h-5 text-primary-600 rounded focus:ring-primary-500"
              />
            </label>

            <label class="flex items-center justify-between p-4 rounded-xl border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 transition-colors cursor-pointer">
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Teklif Kabul Edildi</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">Gonderdiginiz teklif kabul edildiginde bildirim al</div>
              </div>
              <input
                v-model="notifications.offerAccepted"
                type="checkbox"
                class="w-5 h-5 text-primary-600 rounded focus:ring-primary-500"
              />
            </label>

            <label class="flex items-center justify-between p-4 rounded-xl border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 transition-colors cursor-pointer">
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Teklif Reddedildi</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">Gonderdiginiz teklif reddedildiginde bildirim al</div>
              </div>
              <input
                v-model="notifications.offerRejected"
                type="checkbox"
                class="w-5 h-5 text-primary-600 rounded focus:ring-primary-500"
              />
            </label>

            <label class="flex items-center justify-between p-4 rounded-xl border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 transition-colors cursor-pointer">
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Arac Satildi</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">Araciniz satildiginda bildirim al</div>
              </div>
              <input
                v-model="notifications.vehicleSold"
                type="checkbox"
                class="w-5 h-5 text-primary-600 rounded focus:ring-primary-500"
              />
            </label>
          </div>

          <button 
            @click="saveSettings" 
            :disabled="saving"
            class="px-6 py-2.5 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 flex items-center gap-2"
          >
            <Loader2 v-if="saving" class="w-4 h-4 animate-spin" />
            {{ saving ? 'Kaydediliyor...' : 'Kaydet' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { User, Link, Bell, Loader2 } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'
import { useAuthStore } from '~/stores/auth'

const api = useApi()
const toast = useToast()
const authStore = useAuthStore()

const activeTab = ref('profile')
const loading = ref(true)
const saving = ref(false)

const tabs = [
  { id: 'profile', label: 'Profil', icon: User },
  { id: 'channels', label: 'Kanallar', icon: Link },
  { id: 'notifications', label: 'Bildirimler', icon: Bell }
]

const profile = ref({
  name: '',
  email: '',
  phone: '',
  address: '',
  city: '',
  district: '',
  whatsapp: '',
  working_hours: ''
})

const channels = ref<Array<{id: string, name: string, status: string, type: string}>>([])

const notifications = ref({
  newOffer: true,
  newMessage: true,
  offerAccepted: true,
  offerRejected: true,
  vehicleSold: true
})

const passwordChanging = ref(false)
const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  newPasswordConfirm: ''
})

// Load settings on mount
onMounted(async () => {
  await loadSettings()
})

const loadSettings = async () => {
  loading.value = true
  try {
    const response = await api.get<{ success: boolean; data: any }>('/gallery/settings')
    if (response.success && response.data) {
      profile.value = { ...profile.value, ...response.data.profile }
      authStore.setGallery({ ...(authStore.gallery || {}), ...(response.data.profile || {}) })
      channels.value = response.data.channels || []
      notifications.value = { ...notifications.value, ...response.data.notifications }
    }
  } catch (error: any) {
    console.error('Ayarlar yuklenemedi:', error)
    toast.error('Ayarlar yuklenemedi')
  } finally {
    loading.value = false
  }
}

const saveSettings = async () => {
  saving.value = true
  try {
    await api.put('/gallery/settings', {
      profile: profile.value,
      notifications: notifications.value
    })
    toast.success('Ayarlar kaydedildi!')
    authStore.setGallery({ ...(authStore.gallery || {}), ...(profile.value || {}) })
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    saving.value = false
  }
}

const changePassword = async () => {
  if (!passwordForm.value.currentPassword || !passwordForm.value.newPassword) {
    toast.error('Mevcut şifre ve yeni şifre gerekli')
    return
  }
  if (passwordForm.value.newPassword !== passwordForm.value.newPasswordConfirm) {
    toast.error('Yeni şifreler eşleşmiyor')
    return
  }
  passwordChanging.value = true
  try {
    await api.put('/user/change-password', {
      currentPassword: passwordForm.value.currentPassword,
      newPassword: passwordForm.value.newPassword
    })
    toast.success('Şifre başarıyla değiştirildi')
    passwordForm.value = { currentPassword: '', newPassword: '', newPasswordConfirm: '' }
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    passwordChanging.value = false
  }
}

const toggleChannel = async (id: string) => {
  const channel = channels.value.find(c => c.id === id)
  if (channel) {
    const newStatus = channel.status === 'connected' ? 'disconnected' : 'connected'
    try {
      // API call to connect/disconnect channel would go here
      // await api.post(`/channels/${id}/${newStatus === 'connected' ? 'connect' : 'disconnect'}`)
      channel.status = newStatus
      toast.success(newStatus === 'connected' ? 'Kanal baglandi' : 'Kanal baglantisi kesildi')
    } catch (error: any) {
      toast.error('Kanal durumu guncellenemedi')
    }
  }
}
</script>

