<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Sistem Logları</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Sistem aktivitelerini ve hataları takip edin</p>
      </div>
      <div class="flex items-center gap-3">
        <select
          v-model="filterLevel"
          class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-700 dark:text-gray-300"
        >
          <option value="">Tüm Seviyeler</option>
          <option value="error">Hata</option>
          <option value="warning">Uyarı</option>
          <option value="info">Bilgi</option>
          <option value="success">Başarılı</option>
        </select>
        <div class="flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-800 rounded-lg">
          <Search class="w-4 h-4 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Log ara..."
            class="bg-transparent border-0 outline-0 text-sm text-gray-700 dark:text-gray-300 placeholder-gray-400 w-64"
          />
        </div>
        <button
          @click="exportLogs"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          <Download class="w-4 h-4 inline mr-2" />
          Dışa Aktar
        </button>
      </div>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
      <div
        v-for="stat in stats"
        :key="stat.label"
        class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700"
      >
        <div class="flex items-center justify-between mb-4">
          <div
            class="w-12 h-12 rounded-xl flex items-center justify-center"
            :class="stat.iconBg"
          >
            <component :is="stat.icon" class="w-6 h-6" :class="stat.iconColor" />
          </div>
        </div>
        <div class="text-3xl font-bold text-gray-900 dark:text-white mb-1">{{ stat.value }}</div>
        <div class="text-sm text-gray-600 dark:text-gray-400">{{ stat.label }}</div>
      </div>
    </div>

    <!-- Logs Table -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Zaman</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Seviye</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Kullanıcı</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Aktivite</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Detay</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">IP</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="log in filteredLogs"
              :key="log.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatDateTime(log.timestamp) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400': log.level === 'error',
                    'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': log.level === 'warning',
                    'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400': log.level === 'info',
                    'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': log.level === 'success'
                  }"
                >
                  {{ levelLabels[log.level] }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                {{ log.user || 'Sistem' }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-900 dark:text-white">
                {{ log.action }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ log.details }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ log.ip }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div class="p-6 border-t border-gray-200 dark:border-gray-700 flex items-center justify-between">
        <div class="text-sm text-gray-600 dark:text-gray-400">
          Toplam {{ logs.length }} log gösteriliyor
        </div>
        <div class="flex items-center gap-2">
          <button class="px-3 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
            Önceki
          </button>
          <button class="px-3 py-2 bg-primary-500 text-white rounded-lg font-semibold">1</button>
          <button class="px-3 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
            2
          </button>
          <button class="px-3 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
            Sonraki
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Search, Download, AlertCircle, AlertTriangle, Info, CheckCircle } from 'lucide-vue-next'
import { ref, computed, onMounted, watch } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const searchQuery = ref('')
const filterLevel = ref('')

const levelLabels: Record<string, string> = {
  error: 'Hata',
  warning: 'Uyarı',
  info: 'Bilgi',
  success: 'Başarılı'
}

const stats = ref([
  {
    icon: AlertCircle,
    label: 'Toplam Hata',
    value: '0',
    iconBg: 'bg-red-100 dark:bg-red-900/30',
    iconColor: 'text-red-600 dark:text-red-400',
    key: 'error'
  },
  {
    icon: AlertTriangle,
    label: 'Uyarı',
    value: '0',
    iconBg: 'bg-yellow-100 dark:bg-yellow-900/30',
    iconColor: 'text-yellow-600 dark:text-yellow-400',
    key: 'warning'
  },
  {
    icon: Info,
    label: 'Bilgi',
    value: '0',
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400',
    key: 'info'
  },
  {
    icon: CheckCircle,
    label: 'Başarılı',
    value: '0',
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400',
    key: 'success'
  }
])

const logs = ref<any[]>([])

const loadLogs = async () => {
  loading.value = true
  try {
    const params = new URLSearchParams()
    if (filterLevel.value) params.append('level', filterLevel.value)
    if (searchQuery.value) params.append('search', searchQuery.value)
    
    const data = await api.get<any>(`/admin/logs?${params.toString()}`)
    logs.value = data.logs || data || []
    
    // Update stats
    if (data.stats) {
      stats.value.forEach(stat => {
        if (data.stats[stat.key]) {
          stat.value = data.stats[stat.key].toString()
        }
      })
    } else {
      // Calculate stats from logs
      stats.value.forEach(stat => {
        stat.value = logs.value.filter(l => l.level === stat.key).length.toString()
      })
    }
  } catch (error: any) {
    console.error('Loglar yüklenemedi:', error)
    toast.error('Loglar yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

watch([filterLevel, searchQuery], () => {
  loadLogs()
})

const filteredLogs = computed(() => {
  let filtered = logs.value

  if (filterLevel.value) {
    filtered = filtered.filter(l => l.level === filterLevel.value)
  }

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(l => 
      l.action.toLowerCase().includes(query) ||
      l.details.toLowerCase().includes(query) ||
      (l.user && l.user.toLowerCase().includes(query))
    )
  }

  return filtered
})

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

const exportLogs = async () => {
  try {
    const params = new URLSearchParams()
    if (filterLevel.value) params.append('level', filterLevel.value)
    if (searchQuery.value) params.append('search', searchQuery.value)
    
    const blob = await api.get(`/admin/logs/export?${params.toString()}`, { responseType: 'blob' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `logs-${new Date().toISOString().split('T')[0]}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
    toast.success('Loglar başarıyla dışa aktarıldı!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

onMounted(() => {
  loadLogs()
})
</script>

