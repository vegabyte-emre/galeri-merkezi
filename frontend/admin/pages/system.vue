<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Sistem Durumu</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Platform sağlığı ve performans metrikleri</p>
      </div>
      <button
        @click="refreshStatus"
        class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
      >
        <RefreshCw class="w-4 h-4 inline mr-2" />
        Yenile
      </button>
    </div>

    <!-- System Health -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
      <div
        v-for="service in services"
        :key="service.name"
        class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border-2"
        :class="service.status === 'healthy' 
          ? 'border-green-500' 
          : service.status === 'warning' 
          ? 'border-yellow-500' 
          : 'border-red-500'"
      >
        <div class="flex items-center justify-between mb-4">
          <div
            class="w-12 h-12 rounded-xl flex items-center justify-center"
            :class="service.iconBg"
          >
            <component :is="service.icon" class="w-6 h-6" :class="service.iconColor" />
          </div>
          <div
            class="w-3 h-3 rounded-full"
            :class="{
              'bg-green-500': service.status === 'healthy',
              'bg-yellow-500': service.status === 'warning',
              'bg-red-500': service.status === 'error'
            }"
          ></div>
        </div>
        <div class="font-bold text-gray-900 dark:text-white mb-1">{{ service.name }}</div>
        <div class="text-sm text-gray-600 dark:text-gray-400 mb-2">{{ service.description }}</div>
        <div class="text-xs text-gray-500 dark:text-gray-400">
          {{ service.responseTime }}ms
        </div>
      </div>
    </div>

    <!-- Performance Metrics -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- CPU & Memory -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Sistem Kaynakları</h3>
        <div class="space-y-4">
          <div>
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">CPU Kullanımı</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">45%</span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
              <div class="bg-primary-500 h-2 rounded-full" style="width: 45%"></div>
            </div>
          </div>
          <div>
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Bellek Kullanımı</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">62%</span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
              <div class="bg-green-500 h-2 rounded-full" style="width: 62%"></div>
            </div>
          </div>
          <div>
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Disk Kullanımı</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">38%</span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
              <div class="bg-blue-500 h-2 rounded-full" style="width: 38%"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Database Stats -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Veritabanı İstatistikleri</h3>
        <div class="space-y-4">
          <div class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
            <span class="text-sm text-gray-600 dark:text-gray-400">Toplam Tablo</span>
            <span class="font-semibold text-gray-900 dark:text-white">24</span>
          </div>
          <div class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
            <span class="text-sm text-gray-600 dark:text-gray-400">Toplam Kayıt</span>
            <span class="font-semibold text-gray-900 dark:text-white">125.4K</span>
          </div>
          <div class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
            <span class="text-sm text-gray-600 dark:text-gray-400">Aktif Bağlantı</span>
            <span class="font-semibold text-gray-900 dark:text-white">45</span>
          </div>
          <div class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
            <span class="text-sm text-gray-600 dark:text-gray-400">Ortalama Sorgu Süresi</span>
            <span class="font-semibold text-gray-900 dark:text-white">12ms</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Errors -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700">
      <div class="p-6 border-b border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white">Son Hatalar</h3>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Zaman</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Servis</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Hata</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Durum</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="error in recentErrors"
              :key="error.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatDateTime(error.timestamp) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                {{ error.service }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-900 dark:text-white">
                {{ error.message }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="error.resolved 
                    ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' 
                    : 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400'"
                >
                  {{ error.resolved ? 'Çözüldü' : 'Açık' }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { RefreshCw, Database, Server, MessageSquare, Zap } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()

const services = ref([
  {
    name: 'API Gateway',
    description: 'Ana API servisi',
    status: 'healthy',
    responseTime: 45,
    icon: Zap,
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400'
  },
  {
    name: 'Database',
    description: 'PostgreSQL',
    status: 'healthy',
    responseTime: 12,
    icon: Database,
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400'
  },
  {
    name: 'Redis',
    description: 'Cache servisi',
    status: 'warning',
    responseTime: 8,
    icon: Server,
    iconBg: 'bg-yellow-100 dark:bg-yellow-900/30',
    iconColor: 'text-yellow-600 dark:text-yellow-400'
  },
  {
    name: 'RabbitMQ',
    description: 'Mesaj kuyruğu',
    status: 'healthy',
    responseTime: 15,
    icon: MessageSquare,
    iconBg: 'bg-purple-100 dark:bg-purple-900/30',
    iconColor: 'text-purple-600 dark:text-purple-400'
  }
])

const recentErrors = ref([
  {
    id: 1,
    timestamp: '2024-01-20T14:30:00',
    service: 'API Gateway',
    message: 'Connection timeout',
    resolved: true
  },
  {
    id: 2,
    timestamp: '2024-01-20T13:15:00',
    service: 'Database',
    message: 'Slow query detected',
    resolved: true
  },
  {
    id: 3,
    timestamp: '2024-01-20T12:00:00',
    service: 'Redis',
    message: 'Memory usage high',
    resolved: false
  }
])

const formatDateTime = (timestamp: string) => {
  return new Date(timestamp).toLocaleString('tr-TR')
}

const loadSystemStatus = async () => {
  try {
    const status = await api.get('/system/status')
    
    // Update service statuses
    if (status.services) {
      services.value.forEach(service => {
        const updated = status.services.find((s: any) => s.name === service.name)
        if (updated) {
          service.status = updated.status
          service.responseTime = updated.responseTime
        }
      })
    }
    
    // Update recent errors
    if (status.recentErrors) {
      recentErrors.value = status.recentErrors
    }
  } catch (error: any) {
    console.error('Sistem durumu yüklenemedi:', error)
    toast.error('Sistem durumu yüklenemedi: ' + error.message)
  }
}

const refreshStatus = async () => {
  await loadSystemStatus()
  toast.success('Sistem durumu yenilendi!')
}

onMounted(() => {
  loadSystemStatus()
})
</script>

