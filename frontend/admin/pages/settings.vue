<template>
  <div class="space-y-6">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Ayarlar</h1>
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Sistem ayarlarını yönetin</p>
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
        <!-- General Settings -->
        <div v-if="activeTab === 'general'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Genel Ayarlar</h2>
          
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Platform Adı</label>
              <input
                v-model="settings.platformName"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">E-posta</label>
              <input
                v-model="settings.email"
                type="email"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Telefon</label>
              <input
                v-model="settings.phone"
                type="tel"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="settings.maintenanceMode"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Bakım Modu</span>
              </label>
            </div>
          </div>

          <button 
            @click="saveGeneralSettings"
            class="px-6 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Kaydet
          </button>
        </div>

        <!-- Security Settings -->
        <div v-if="activeTab === 'security'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Güvenlik Ayarları</h2>
          
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Minimum Şifre Uzunluğu</label>
              <input
                v-model.number="securitySettings.minPasswordLength"
                type="number"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="securitySettings.requireTwoFactor"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">2FA Zorunlu</span>
              </label>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Oturum Süresi (dakika)</label>
              <input
                v-model.number="securitySettings.sessionTimeout"
                type="number"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
          </div>

          <button 
            @click="saveSecuritySettings"
            class="px-6 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Kaydet
          </button>
        </div>

        <!-- Notification Settings -->
        <div v-if="activeTab === 'notifications'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Bildirim Ayarları</h2>
          
          <div class="space-y-4">
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="notificationSettings.emailNotifications"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">E-posta Bildirimleri</span>
              </label>
            </div>
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="notificationSettings.smsNotifications"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">SMS Bildirimleri</span>
              </label>
            </div>
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="notificationSettings.pushNotifications"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Push Bildirimleri</span>
              </label>
            </div>
          </div>

          <button 
            @click="saveNotificationSettings"
            class="px-6 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Kaydet
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Settings, Shield, Bell } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const activeTab = ref('general')

const tabs = [
  { id: 'general', label: 'Genel', icon: Settings },
  { id: 'security', label: 'Güvenlik', icon: Shield },
  { id: 'notifications', label: 'Bildirimler', icon: Bell }
]

const settings = ref({
  platformName: 'Otobia',
  email: 'info@Otobia.com',
  phone: '+90 212 555 0000',
  maintenanceMode: false
})

const securitySettings = ref({
  minPasswordLength: 8,
  requireTwoFactor: false,
  sessionTimeout: 60
})

const notificationSettings = ref({
  emailNotifications: true,
  smsNotifications: false,
  pushNotifications: true
})

const loadSettings = async () => {
  loading.value = true
  try {
    const data = await api.get('/settings')
    if (data.general) {
      settings.value = { ...settings.value, ...data.general }
    }
    if (data.security) {
      securitySettings.value = { ...securitySettings.value, ...data.security }
    }
    if (data.notifications) {
      notificationSettings.value = { ...notificationSettings.value, ...data.notifications }
    }
  } catch (error: any) {
    console.error('Ayarlar yüklenemedi:', error)
    toast.error('Ayarlar yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const saveGeneralSettings = async () => {
  try {
    await api.put('/settings/general', settings.value)
    toast.success('Genel ayarlar kaydedildi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const saveSecuritySettings = async () => {
  try {
    await api.put('/settings/security', securitySettings.value)
    toast.success('Güvenlik ayarları kaydedildi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const saveNotificationSettings = async () => {
  try {
    await api.put('/settings/notifications', notificationSettings.value)
    toast.success('Bildirim ayarları kaydedildi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

onMounted(() => {
  loadSettings()
})
</script>

