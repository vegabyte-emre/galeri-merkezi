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
          <!-- NetGSM (SMS) -->
          <div v-if="(configuringIntegration?.type || '').toLowerCase() === 'sms' || (configuringIntegration?.name || '').toLowerCase().includes('netgsm')" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                NetGSM Kullanıcı Adı
              </label>
              <input
                v-model="smsUsername"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="NETGSM_USERNAME"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                NetGSM Şifre
              </label>
              <input
                v-model="smsPassword"
                type="password"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="Değiştirmek için yazın (boş bırakılırsa korunur)"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Mesaj Başlığı (msgHeader)
              </label>
              <input
                v-model="smsMsgHeader"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="GALERIPLATFORM"
              />
            </div>
          </div>

          <!-- Generic API key (optional) -->
          <div v-else>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              API Anahtarı (opsiyonel)
            </label>
            <input
              v-model="configApiKey"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="API anahtarınızı girin"
            />
            <div class="mt-4">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Config (JSON) (opsiyonel)
              </label>
              <textarea
                v-model="configJson"
                rows="6"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white font-mono text-xs"
                placeholder="{\n  \"enabled\": true\n}"
              ></textarea>
            </div>
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
const configJson = ref('')
const smsUsername = ref('')
const smsPassword = ref('')
const smsMsgHeader = ref('')

const decorateIntegration = (i: any) => {
  const connected = i.status === 'active'
  const type = (i.type || '').toLowerCase()
  const name = (i.name || '').toLowerCase()

  const base = {
    ...i,
    connected,
    category: 'Diğer',
    description: 'Entegrasyon ayarlarını yönetin',
    icon: Zap,
    iconBg: 'bg-primary-100 dark:bg-primary-900/30',
    iconColor: 'text-primary-600 dark:text-primary-400'
  }

  if (type.includes('sms') || name.includes('netgsm')) {
    return {
      ...base,
      category: 'SMS',
      description: 'SMS gönderimi için sağlayıcı ayarları (NetGSM)',
      icon: MessageSquare,
      iconBg: 'bg-green-100 dark:bg-green-900/30',
      iconColor: 'text-green-700 dark:text-green-400'
    }
  }
  if (type.includes('email')) {
    return {
      ...base,
      category: 'E-posta',
      description: 'E-posta gönderimi için sağlayıcı ayarları',
      icon: Mail,
      iconBg: 'bg-blue-100 dark:bg-blue-900/30',
      iconColor: 'text-blue-700 dark:text-blue-400'
    }
  }
  if (type.includes('push')) {
    return {
      ...base,
      category: 'Push',
      description: 'Push bildirim sağlayıcısı ayarları',
      icon: Zap,
      iconBg: 'bg-purple-100 dark:bg-purple-900/30',
      iconColor: 'text-purple-700 dark:text-purple-400'
    }
  }
  if (type.includes('listing')) {
    return {
      ...base,
      category: 'İlan',
      description: 'İlan platformu entegrasyonu ayarları',
      icon: BarChart3,
      iconBg: 'bg-orange-100 dark:bg-orange-900/30',
      iconColor: 'text-orange-700 dark:text-orange-400'
    }
  }
  if (type.includes('payment')) {
    return {
      ...base,
      category: 'Ödeme',
      description: 'Ödeme sağlayıcısı entegrasyonu ayarları',
      icon: CreditCard,
      iconBg: 'bg-yellow-100 dark:bg-yellow-900/30',
      iconColor: 'text-yellow-700 dark:text-yellow-400'
    }
  }
  if (type.includes('security')) {
    return {
      ...base,
      category: 'Güvenlik',
      description: 'Güvenlik entegrasyonu ayarları',
      icon: Shield,
      iconBg: 'bg-gray-100 dark:bg-gray-700',
      iconColor: 'text-gray-700 dark:text-gray-300'
    }
  }

  return base
}

const loadIntegrations = async () => {
  loading.value = true
  try {
    const data = await api.get<any>('/admin/integrations')
    const list = data.integrations || data || []
    integrations.value = (Array.isArray(list) ? list : []).map(decorateIntegration)
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
      await api.put(`/admin/integrations/${id}`, { status: 'active' })
      integration.connected = true
      integration.status = 'active'
      toast.success(`${integration.name} aktif edildi!`)
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
        await api.put(`/admin/integrations/${id}`, { status: 'inactive' })
        integration.connected = false
        integration.status = 'inactive'
        toast.success('Entegrasyon pasif edildi!')
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

    const cfg = integration.config || {}
    configJson.value = JSON.stringify(cfg, null, 2)

    if ((integration.type || '').toLowerCase() === 'sms' || (integration.name || '').toLowerCase().includes('netgsm')) {
      smsUsername.value = cfg.username || ''
      smsMsgHeader.value = cfg.msgHeader || 'GALERIPLATFORM'
      // Do not prefill password
      smsPassword.value = ''
    }
  }
}

const saveConfiguration = async () => {
  try {
    const integration = configuringIntegration.value
    if (!integration?.id) return

    let nextConfig: any = {}

    // If SMS/NetGSM: use structured fields
    if ((integration.type || '').toLowerCase() === 'sms' || (integration.name || '').toLowerCase().includes('netgsm')) {
      nextConfig = {
        ...(integration.config || {}),
        enabled: true,
        username: smsUsername.value,
        msgHeader: smsMsgHeader.value || 'GALERIPLATFORM'
      }
      // Only update password if provided
      if (smsPassword.value && smsPassword.value.trim()) {
        nextConfig.password = smsPassword.value.trim()
      }
    } else if (configApiKey.value && configApiKey.value.trim()) {
      // Basic API key field for other integrations
      nextConfig = {
        ...(integration.config || {}),
        apiKey: configApiKey.value.trim(),
        enabled: true
      }
    } else {
      // Fallback JSON editor
      try {
        nextConfig = JSON.parse(configJson.value || '{}')
      } catch {
        toast.error('Config JSON geçersiz')
        return
      }
    }

    await api.put(`/admin/integrations/${integration.id}`, {
      config: nextConfig,
      status: integration.connected ? 'active' : integration.status || 'inactive'
    })

    toast.success('Yapılandırma kaydedildi!')
    showConfigModal.value = false
    configApiKey.value = ''
    configJson.value = ''
    smsUsername.value = ''
    smsPassword.value = ''
    smsMsgHeader.value = ''
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

