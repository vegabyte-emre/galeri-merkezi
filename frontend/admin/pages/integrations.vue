<template>
  <div class="space-y-6">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Entegrasyonlar</h1>
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Üçüncü parti servislerle entegrasyonları yönetin</p>
    </div>

    <!-- Integration Cards -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="integration in integrations"
        :key="integration.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border-2 p-6 transition-all"
        :class="integration.connected 
          ? 'border-green-500' 
          : 'border-gray-200 dark:border-gray-700'"
      >
        <!-- Header -->
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center gap-3">
            <div
              class="w-12 h-12 rounded-xl flex items-center justify-center"
              :class="integration.iconBg"
            >
              <component :is="integration.icon" class="w-6 h-6" :class="integration.iconColor" />
            </div>
            <div>
              <h3 class="font-bold text-gray-900 dark:text-white">{{ integration.name }}</h3>
              <p class="text-xs text-gray-500 dark:text-gray-400">{{ integration.category }}</p>
            </div>
          </div>
          <span
            class="px-2 py-1 text-xs font-semibold rounded-full"
            :class="integration.connected 
              ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' 
              : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400'"
          >
            {{ integration.connected ? 'Bağlı' : 'Bağlı Değil' }}
          </span>
        </div>

        <!-- Description -->
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
          {{ integration.description }}
        </p>

        <!-- Actions -->
        <div class="flex items-center gap-2">
          <button
            v-if="!integration.connected"
            @click="connectIntegration(integration.id)"
            class="flex-1 px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold text-sm"
          >
            Bağlan
          </button>
          <button
            v-if="integration.connected"
            @click="configureIntegration(integration.id)"
            class="flex-1 px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold text-sm"
          >
            Yapılandır
          </button>
          <button
            v-if="integration.connected"
            @click="disconnectIntegration(integration.id)"
            class="px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold text-sm"
          >
            Bağlantıyı Kes
          </button>
        </div>
      </div>
    </div>

    <!-- API Keys -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">API Anahtarları</h3>
      <div class="space-y-4">
        <div
          v-for="apiKey in apiKeys"
          :key="apiKey.id"
          class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl"
        >
          <div>
            <div class="font-semibold text-gray-900 dark:text-white">{{ apiKey.name }}</div>
            <div class="text-sm text-gray-500 dark:text-gray-400 font-mono">{{ apiKey.key }}</div>
          </div>
          <div class="flex items-center gap-2">
            <button
              @click="copyApiKey(apiKey.key)"
              class="px-3 py-1.5 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold text-xs"
            >
              Kopyala
            </button>
            <button
              @click="regenerateApiKey(apiKey.id)"
              class="px-3 py-1.5 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400 rounded-lg hover:bg-yellow-200 dark:hover:bg-yellow-900/50 transition-colors font-semibold text-xs"
            >
              Yenile
            </button>
            <button
              @click="deleteApiKey(apiKey.id)"
              class="px-3 py-1.5 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold text-xs"
            >
              Sil
            </button>
          </div>
        </div>
        <button
          @click="openCreateApiKeyModal"
          class="w-full px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold"
        >
          + Yeni API Anahtarı Oluştur
        </button>
      </div>
    </div>

    <!-- Configure Integration Modal -->
    <div
      v-if="showConfigModal"
      class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      @click.self="showConfigModal = false"
    >
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-md w-full p-6">
        <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">
          {{ configuringIntegration?.name }} Yapılandırma
        </h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              API Anahtarı
            </label>
            <input
              v-model="configApiKey"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="API anahtarınızı girin"
            />
          </div>
        </div>
        <div class="flex items-center justify-end gap-3 mt-6">
          <button
            @click="showConfigModal = false; configApiKey = ''"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          >
            İptal
          </button>
          <button
            @click="saveConfiguration"
            class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Kaydet
          </button>
        </div>
      </div>
    </div>

    <!-- Create API Key Modal -->
    <div
      v-if="showCreateApiKeyModal"
      class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      @click.self="showCreateApiKeyModal = false"
    >
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-md w-full p-6">
        <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">
          Yeni API Anahtarı Oluştur
        </h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              API Anahtarı Adı
            </label>
            <input
              v-model="newApiKeyName"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="Örn: Production API Key"
            />
          </div>
        </div>
        <div class="flex items-center justify-end gap-3 mt-6">
          <button
            @click="showCreateApiKeyModal = false; newApiKeyName = ''"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          >
            İptal
          </button>
          <button
            @click="createApiKey"
            class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Oluştur
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  Mail,
  MessageSquare,
  CreditCard,
  BarChart3,
  Shield,
  Zap
} from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const showConfigModal = ref(false)
const showCreateApiKeyModal = ref(false)
const configuringIntegration = ref<any>(null)
const configApiKey = ref('')
const newApiKeyName = ref('')

const integrations = ref<any[]>([])
const apiKeys = ref<any[]>([])

const loadIntegrations = async () => {
  loading.value = true
  try {
    const data = await api.get<any>('/admin/integrations')
    integrations.value = data.integrations || data || []
  } catch (error: any) {
    console.error('Entegrasyonlar yüklenemedi:', error)
    toast.error('Entegrasyonlar yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const loadApiKeys = async () => {
  try {
    const data = await api.get<any>('/admin/api-keys')
    apiKeys.value = data.apiKeys || data || []
  } catch (error: any) {
    console.error('API anahtarları yüklenemedi:', error)
    // Ignore error, use empty list
    apiKeys.value = []
  }
}

const connectIntegration = async (id: number) => {
  const integration = integrations.value.find(i => i.id === id)
  if (integration) {
    try {
      await api.post(`/admin/integrations/${id}/connect`)
      integration.connected = true
      toast.success(`${integration.name} bağlantısı kuruldu!`)
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const disconnectIntegration = async (id: number) => {
  if (confirm('Bu entegrasyonun bağlantısını kesmek istediğinize emin misiniz?')) {
    const integration = integrations.value.find(i => i.id === id)
    if (integration) {
      try {
        await api.post(`/admin/integrations/${id}/disconnect`)
        integration.connected = false
        toast.success('Bağlantı kesildi!')
      } catch (error: any) {
        toast.error('Hata: ' + error.message)
      }
    }
  }
}

const configureIntegration = (id: number) => {
  const integration = integrations.value.find(i => i.id === id)
  if (integration) {
    configuringIntegration.value = integration
    showConfigModal.value = true
    configApiKey.value = ''
  }
}

const saveConfiguration = async () => {
  if (!configApiKey.value.trim()) {
    toast.warning('API anahtarı gereklidir')
    return
  }
  
  try {
    await api.post(`/admin/integrations/${configuringIntegration.value.id}/configure`, { 
      apiKey: configApiKey.value 
    })
    toast.success('Yapılandırma kaydedildi!')
    showConfigModal.value = false
    configApiKey.value = ''
    await loadIntegrations()
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const copyApiKey = (key: string) => {
  navigator.clipboard.writeText(key)
  toast.success('API anahtarı kopyalandı!')
}

const regenerateApiKey = async (id: number) => {
  if (confirm('Bu API anahtarını yenilemek istediğinize emin misiniz? Eski anahtar geçersiz olacaktır.')) {
    const apiKey = apiKeys.value.find(k => k.id === id)
    if (apiKey) {
      try {
        const response = await api.post(`/admin/api-keys/${id}/regenerate`)
        apiKey.key = response.key
        toast.success('API anahtarı yenilendi!')
      } catch (error: any) {
        toast.error('Hata: ' + error.message)
      }
    }
  }
}

const deleteApiKey = async (id: number) => {
  if (confirm('Bu API anahtarını silmek istediğinize emin misiniz?')) {
    try {
      await api.delete(`/admin/api-keys/${id}`)
      apiKeys.value = apiKeys.value.filter(k => k.id !== id)
      toast.success('API anahtarı silindi!')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const openCreateApiKeyModal = () => {
  newApiKeyName.value = ''
  showCreateApiKeyModal.value = true
}

const createApiKey = async () => {
  if (!newApiKeyName.value.trim()) {
    toast.warning('API anahtarı adı gereklidir')
    return
  }
  
  try {
    const response = await api.post('/admin/api-keys', { name: newApiKeyName.value })
    apiKeys.value.push({
      id: response.id,
      name: response.name,
      key: response.key
    })
    toast.success('Yeni API anahtarı oluşturuldu!')
    showCreateApiKeyModal.value = false
    newApiKeyName.value = ''
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

onMounted(() => {
  loadIntegrations()
  loadApiKeys()
})
</script>

