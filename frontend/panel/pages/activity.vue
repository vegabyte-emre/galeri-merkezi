<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Aktivite Geçmişi</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Tüm işlemlerinizin kaydı</p>
      </div>
      <div class="flex items-center gap-3">
        <select
          v-model="filterType"
          class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-700 dark:text-gray-300"
        >
          <option value="">Tüm Aktiviteler</option>
          <option value="vehicle">Araç İşlemleri</option>
          <option value="offer">Teklif İşlemleri</option>
          <option value="message">Mesaj İşlemleri</option>
          <option value="settings">Ayarlar</option>
        </select>
        <button
          @click="exportActivity"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          <Download class="w-4 h-4 inline mr-2" />
          Dışa Aktar
        </button>
      </div>
    </div>

    <!-- Activity Timeline -->
    <div class="space-y-4">
      <div
        v-for="activity in filteredActivities"
        :key="activity.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6"
      >
        <div class="flex items-start gap-4">
          <!-- Icon -->
          <div
            class="w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0"
            :class="getActivityIconBg(activity.action_type || activity.entity_type || '')"
          >
            <component :is="getActivityIcon(activity.action_type || activity.entity_type || '')" class="w-6 h-6" :class="getActivityIconColor(activity.action_type || activity.entity_type || '')" />
          </div>

          <!-- Content -->
          <div class="flex-1 min-w-0">
            <div class="flex items-start justify-between mb-2">
              <div>
                <h3 class="font-semibold text-gray-900 dark:text-white">{{ activity.action_type || 'Aktivite' }}</h3>
                <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">{{ activity.description || `${activity.entity_type} işlemi` }}</p>
              </div>
              <span class="text-xs text-gray-500 dark:text-gray-400 whitespace-nowrap ml-4">
                {{ formatDateTime(activity.created_at) }}
              </span>
            </div>
            
            <!-- Details -->
            <div v-if="activity.entity_id" class="mt-3 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
              <div class="text-sm text-gray-600 dark:text-gray-400">
                <div class="flex items-center gap-2 mb-1">
                  <span class="font-medium">Varlık Tipi:</span>
                  <span>{{ activity.entity_type }}</span>
                </div>
                <div class="flex items-center gap-2 mb-1">
                  <span class="font-medium">Varlık ID:</span>
                  <span>{{ activity.entity_id }}</span>
                </div>
              </div>
            </div>

            <!-- IP Address -->
            <div class="mt-2 text-xs text-gray-500 dark:text-gray-400">
              <span v-if="activity.ip_address">IP: {{ activity.ip_address }}</span>
              <span v-if="activity.ip_address && activity.user_agent"> • </span>
              <span v-if="activity.user_agent">{{ activity.user_agent }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div class="flex items-center justify-center gap-2">
      <button class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
        Önceki
      </button>
      <button class="px-4 py-2 bg-primary-500 text-white rounded-lg font-semibold">1</button>
      <button class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
        2
      </button>
      <button class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
        Sonraki
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Download, Car, Users, MessageSquare, Settings, User } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const filterType = ref('')
const loading = ref(false)

const activities = ref<any[]>([])

const getActivityIcon = (actionType: string) => {
  if (actionType.includes('vehicle')) return Car
  if (actionType.includes('offer')) return Users
  if (actionType.includes('message')) return MessageSquare
  if (actionType.includes('settings')) return Settings
  return User
}

const getActivityIconBg = (actionType: string) => {
  if (actionType.includes('vehicle')) return 'bg-blue-100 dark:bg-blue-900/30'
  if (actionType.includes('offer')) return 'bg-green-100 dark:bg-green-900/30'
  if (actionType.includes('message')) return 'bg-purple-100 dark:bg-purple-900/30'
  if (actionType.includes('settings')) return 'bg-orange-100 dark:bg-orange-900/30'
  return 'bg-gray-100 dark:bg-gray-900/30'
}

const getActivityIconColor = (actionType: string) => {
  if (actionType.includes('vehicle')) return 'text-blue-600 dark:text-blue-400'
  if (actionType.includes('offer')) return 'text-green-600 dark:text-green-400'
  if (actionType.includes('message')) return 'text-purple-600 dark:text-purple-400'
  if (actionType.includes('settings')) return 'text-orange-600 dark:text-orange-400'
  return 'text-gray-600 dark:text-gray-400'
}

const filteredActivities = computed(() => {
  if (!filterType.value) return activities.value
  return activities.value.filter(a => a.action_type?.includes(filterType.value) || a.entity_type === filterType.value)
})

const loadActivities = async () => {
  try {
    loading.value = true
    const params: any = {}
    if (filterType.value) {
      params.type = filterType.value
    }
    const response = await api.get<{ success: boolean; data: any[] }>('/activity', { params })
    if (response.success && response.data) {
      activities.value = response.data
    }
  } catch (error: any) {
    toast.error('Aktivite geçmişi yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const formatDateTime = (timestamp: string) => {
  const date = new Date(timestamp)
  return date.toLocaleString('tr-TR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const exportActivity = async () => {
  try {
    // Convert activities to CSV
    const headers = ['Tarih', 'Aktivite Tipi', 'Varlık Tipi', 'Açıklama', 'IP Adresi']
    const rows = activities.value.map(a => [
      formatDateTime(a.created_at),
      a.action_type || '',
      a.entity_type || '',
      a.description || '',
      a.ip_address || ''
    ])
    
    const csv = [headers.join(','), ...rows.map(r => r.map(c => `"${c}"`).join(','))].join('\n')
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `activity-${new Date().toISOString().split('T')[0]}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
    toast.success('Aktivite geçmişi dışa aktarıldı')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

onMounted(() => {
  loadActivities()
})
</script>

