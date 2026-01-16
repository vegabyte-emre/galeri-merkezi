<template>
  <div class="space-y-6">
    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div
        v-for="(stat, index) in stats"
        :key="stat.label"
        class="group relative bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-gray-100 dark:border-gray-700"
        :style="{ animationDelay: `${index * 100}ms` }"
      >
        <!-- Gradient Background -->
        <div 
          class="absolute top-0 right-0 w-32 h-32 rounded-bl-full opacity-10"
          :class="stat.gradient"
        ></div>
        
        <div class="relative">
          <div class="flex items-center justify-between mb-4">
            <div 
              class="w-12 h-12 rounded-xl flex items-center justify-center shadow-lg"
              :class="stat.iconBg"
            >
              <component :is="stat.icon" class="w-6 h-6" :class="stat.iconColor" />
            </div>
            <span 
              class="text-xs font-semibold px-2 py-1 rounded-full"
              :class="stat.badgeClass"
            >
              {{ stat.change }}
            </span>
          </div>
          <div class="mb-1">
            <span class="text-3xl font-bold text-gray-900 dark:text-white">{{ stat.value }}</span>
            <span v-if="stat.unit" class="text-lg text-gray-500 dark:text-gray-400 ml-1">{{ stat.unit }}</span>
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400">{{ stat.label }}</div>
        </div>
      </div>
    </div>

    <!-- Charts and Tables Row -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Chart Card -->
      <div class="lg:col-span-2 bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-100 dark:border-gray-700">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Aylık İstatistikler</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">Son 6 ayın verileri</p>
          </div>
          <select class="px-3 py-1.5 text-sm border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300">
            <option>Son 6 Ay</option>
            <option>Son 1 Yıl</option>
            <option>Son 2 Yıl</option>
          </select>
        </div>
        <!-- Chart -->
        <Chart
          v-if="chartData"
          type="line"
          :height="256"
          :data="chartData"
          :options="{
            plugins: {
              legend: {
                display: true,
                position: 'top'
              }
            },
            scales: {
              x: {
                grid: {
                  color: 'rgba(0, 0, 0, 0.05)'
                }
              },
              y: {
                grid: {
                  color: 'rgba(0, 0, 0, 0.05)'
                }
              }
            }
          }"
        />
        <div v-else class="h-64 flex items-center justify-center">
          <div class="text-center">
            <div class="text-sm text-gray-500 dark:text-gray-400">Grafik yükleniyor...</div>
          </div>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-100 dark:border-gray-700">
        <div class="mb-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white">Son Aktiviteler</h3>
          <p class="text-sm text-gray-500 dark:text-gray-400">Yakın zamandaki işlemler</p>
        </div>
        <div class="space-y-4">
          <div
            v-for="(activity, index) in recentActivities"
            :key="index"
            class="flex items-start gap-3 p-3 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
          >
            <div 
              class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
              :class="activity.iconBg"
            >
              <component :is="activity.icon" class="w-5 h-5" :class="activity.iconColor" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 dark:text-white">{{ activity.title }}</p>
              <p class="text-xs text-gray-500 dark:text-gray-400">{{ activity.time }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Analytics Link -->
    <div class="bg-gradient-to-r from-primary-600 to-primary-800 rounded-2xl p-6 text-white">
      <div class="flex items-center justify-between">
        <div>
          <h3 class="text-xl font-bold mb-2">Detaylı Analitik</h3>
          <p class="text-primary-100">Platform performansını detaylı olarak inceleyin</p>
        </div>
        <NuxtLink
          to="/analytics"
          class="px-6 py-3 bg-white text-primary-700 font-semibold rounded-lg hover:bg-primary-50 transition-colors"
        >
          Analitik Sayfasına Git →
        </NuxtLink>
      </div>
    </div>

    <!-- Quick Actions and Pending Items -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Pending Applications -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-100 dark:border-gray-700">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Bekleyen Başvurular</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ pendingApplications.length }} yeni başvuru</p>
          </div>
          <NuxtLink
            to="/galleries"
            class="px-4 py-2 text-sm font-semibold text-primary-600 dark:text-primary-400 hover:bg-primary-50 dark:hover:bg-primary-900/30 rounded-lg transition-colors"
          >
            Tümünü Gör
          </NuxtLink>
        </div>
        <div class="space-y-3">
          <div
            v-for="(app, index) in pendingApplications.slice(0, 5)"
            :key="index"
            class="flex items-center justify-between p-4 rounded-xl bg-gray-50 dark:bg-gray-700/50 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          >
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold text-sm">
                {{ app.name.charAt(0) }}
              </div>
              <div>
                <p class="text-sm font-medium text-gray-900 dark:text-white">{{ app.name }}</p>
                <p class="text-xs text-gray-500 dark:text-gray-400">{{ app.location }}</p>
              </div>
            </div>
            <span class="text-xs font-semibold px-2 py-1 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400 rounded-full">
              Bekliyor
            </span>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-100 dark:border-gray-700">
        <div class="mb-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white">Hızlı İşlemler</h3>
          <p class="text-sm text-gray-500 dark:text-gray-400">Sık kullanılan işlemler</p>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <button
            v-for="action in quickActions"
            :key="action.label"
            @click="action.action"
            class="flex flex-col items-center gap-3 p-4 rounded-xl bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-700 dark:to-gray-800 hover:from-primary-50 hover:to-primary-100 dark:hover:from-primary-900/30 dark:hover:to-primary-800/30 border border-gray-200 dark:border-gray-600 hover:border-primary-300 dark:hover:border-primary-700 transition-all duration-300 hover:scale-105"
          >
            <div 
              class="w-12 h-12 rounded-xl flex items-center justify-center"
              :class="action.iconBg"
            >
              <component :is="action.icon" class="w-6 h-6" :class="action.iconColor" />
            </div>
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ action.label }}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  Building2,
  Users,
  Car,
  TrendingUp,
  BarChart3,
  UserPlus,
  FileText,
  Settings,
  Plus,
  Download,
  Upload,
  Mail
} from 'lucide-vue-next'
import Chart from '~/components/Chart.vue'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const chartData = ref<any>(null)

const stats = ref([
  {
    icon: Building2,
    label: 'Toplam Galeri',
    value: '0',
    change: '+0%',
    unit: '',
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400',
    gradient: 'bg-gradient-to-br from-blue-400 to-blue-600',
    badgeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'totalGalleries'
  },
  {
    icon: UserPlus,
    label: 'Bekleyen Başvuru',
    value: '0',
    change: '+0',
    unit: '',
    iconBg: 'bg-yellow-100 dark:bg-yellow-900/30',
    iconColor: 'text-yellow-600 dark:text-yellow-400',
    gradient: 'bg-gradient-to-br from-yellow-400 to-yellow-600',
    badgeClass: 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400',
    key: 'pendingApplications'
  },
  {
    icon: Car,
    label: 'Toplam Araç',
    value: '0',
    change: '+0%',
    unit: '',
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400',
    gradient: 'bg-gradient-to-br from-green-400 to-green-600',
    badgeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'totalVehicles'
  },
  {
    icon: TrendingUp,
    label: 'Aylık Teklif',
    value: '0',
    change: '+0%',
    unit: '',
    iconBg: 'bg-purple-100 dark:bg-purple-900/30',
    iconColor: 'text-purple-600 dark:text-purple-400',
    gradient: 'bg-gradient-to-br from-purple-400 to-purple-600',
    badgeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'monthlyOffers'
  }
])

const recentActivities = ref([
  {
    icon: UserPlus,
    title: 'Yeni galeri başvurusu',
    time: '2 dakika önce',
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400'
  },
  {
    icon: Car,
    title: 'Yeni araç eklendi',
    time: '15 dakika önce',
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400'
  },
  {
    icon: FileText,
    title: 'Rapor oluşturuldu',
    time: '1 saat önce',
    iconBg: 'bg-purple-100 dark:bg-purple-900/30',
    iconColor: 'text-purple-600 dark:text-purple-400'
  },
  {
    icon: Settings,
    title: 'Sistem ayarları güncellendi',
    time: '2 saat önce',
    iconBg: 'bg-gray-100 dark:bg-gray-700',
    iconColor: 'text-gray-600 dark:text-gray-400'
  }
])

const pendingApplications = ref([
  { name: 'İstanbul Oto Galeri', location: 'İstanbul' },
  { name: 'Ankara Premium Motors', location: 'Ankara' },
  { name: 'İzmir Auto Center', location: 'İzmir' },
  { name: 'Bursa Otomotiv', location: 'Bursa' },
  { name: 'Antalya Luxury Cars', location: 'Antalya' },
  { name: 'Adana Motor Show', location: 'Adana' }
])

const quickActions = [
  {
    icon: Plus,
    label: 'Yeni Galeri',
    iconBg: 'bg-primary-100 dark:bg-primary-900/30',
    iconColor: 'text-primary-600 dark:text-primary-400',
    action: () => navigateTo('/galleries')
  },
  {
    icon: UserPlus,
    label: 'Kullanıcı Ekle',
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400',
    action: () => navigateTo('/users')
  },
  {
    icon: Download,
    label: 'Rapor İndir',
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400',
    action: async () => {
      try {
        const response = await api.get('/reports/export', { responseType: 'blob' })
        const url = window.URL.createObjectURL(response)
        const a = document.createElement('a')
        a.href = url
        a.download = `rapor-${new Date().toISOString().split('T')[0]}.xlsx`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        window.URL.revokeObjectURL(url)
        toast.success('Rapor indirildi!')
      } catch (error: any) {
        toast.error('Rapor indirilemedi: ' + error.message)
      }
    }
  },
  {
    icon: Mail,
    label: 'Toplu E-posta',
    iconBg: 'bg-purple-100 dark:bg-purple-900/30',
    iconColor: 'text-purple-600 dark:text-purple-400',
    action: () => navigateTo('/email-templates')
  }
]

const loadDashboardData = async () => {
  loading.value = true
  try {
    const data = await api.get('/admin/dashboard')
    
    // Update stats
    stats.value.forEach(stat => {
      if (data.stats && data.stats[stat.key]) {
        stat.value = data.stats[stat.key].value?.toString() || '0'
        stat.change = data.stats[stat.key].change || '+0%'
      }
    })
    
    // Update chart data
    if (data.chartData) {
      chartData.value = data.chartData
    } else {
      // Default chart data if API doesn't provide
      chartData.value = {
        labels: ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran'],
        datasets: [{
          label: 'Galeri Sayısı',
          data: [120, 130, 135, 140, 145, 150],
          borderColor: 'rgb(59, 130, 246)',
          backgroundColor: 'rgba(59, 130, 246, 0.1)',
          fill: true,
          tension: 0.4
        }, {
          label: 'Yeni Araç',
          data: [800, 950, 1100, 1200, 1300, 1400],
          borderColor: 'rgb(34, 197, 94)',
          backgroundColor: 'rgba(34, 197, 94, 0.1)',
          fill: true,
          tension: 0.4
        }]
      }
    }
    
    // Update activities
    if (data.activities) {
      recentActivities.value = data.activities.map((act: any) => ({
        icon: UserPlus,
        title: act.title || act.message,
        time: formatTimeAgo(act.createdAt),
        iconBg: getActivityIconBg(act.type),
        iconColor: getActivityIconColor(act.type)
      }))
    }
    
    // Update pending applications
    if (data.pendingApplications) {
      pendingApplications.value = data.pendingApplications.map((app: any) => ({
        name: app.name || app.galleryName,
        location: app.location || app.city
      }))
    }
  } catch (error: any) {
    console.error('Dashboard verileri yüklenemedi:', error)
    // Default chart data on error
    chartData.value = {
      labels: ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran'],
      datasets: [{
        label: 'Galeri Sayısı',
        data: [120, 130, 135, 140, 145, 150],
        borderColor: 'rgb(59, 130, 246)',
        backgroundColor: 'rgba(59, 130, 246, 0.1)',
        fill: true,
        tension: 0.4
      }, {
        label: 'Yeni Araç',
        data: [800, 950, 1100, 1200, 1300, 1400],
        borderColor: 'rgb(34, 197, 94)',
        backgroundColor: 'rgba(34, 197, 94, 0.1)',
        fill: true,
        tension: 0.4
      }]
    }
  } finally {
    loading.value = false
  }
}

const formatTimeAgo = (date: string) => {
  const now = new Date()
  const past = new Date(date)
  const diffMs = now.getTime() - past.getTime()
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)
  
  if (diffMins < 60) return `${diffMins} dakika önce`
  if (diffHours < 24) return `${diffHours} saat önce`
  return `${diffDays} gün önce`
}

const getActivityIconBg = (type: string) => {
  const map: Record<string, string> = {
    gallery: 'bg-blue-100 dark:bg-blue-900/30',
    vehicle: 'bg-green-100 dark:bg-green-900/30',
    report: 'bg-purple-100 dark:bg-purple-900/30',
    system: 'bg-gray-100 dark:bg-gray-700'
  }
  return map[type] || 'bg-gray-100 dark:bg-gray-700'
}

const getActivityIconColor = (type: string) => {
  const map: Record<string, string> = {
    gallery: 'text-blue-600 dark:text-blue-400',
    vehicle: 'text-green-600 dark:text-green-400',
    report: 'text-purple-600 dark:text-purple-400',
    system: 'text-gray-600 dark:text-gray-400'
  }
  return map[type] || 'text-gray-600 dark:text-gray-400'
}

onMounted(() => {
  loadDashboardData()
})
</script>

<style scoped>
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.group {
  animation: fade-in-up 0.6s ease-out both;
}
</style>
