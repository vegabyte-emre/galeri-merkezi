<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Raporlar</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Detaylı raporlar ve analitik</p>
      </div>
      <div class="flex items-center gap-3">
        <select
          v-model="selectedPeriod"
          class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-700 dark:text-gray-300"
        >
          <option value="week">Son Hafta</option>
          <option value="month">Son Ay</option>
          <option value="quarter">Son Çeyrek</option>
          <option value="year">Son Yıl</option>
        </select>
        <button 
          @click="exportReport"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          <Download class="w-4 h-4 inline mr-2" />
          Rapor İndir
        </button>
      </div>
    </div>

    <!-- Stats Grid -->
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
          <span
            class="text-xs font-semibold px-2 py-1 rounded-full"
            :class="stat.changeClass"
          >
            {{ stat.change }}
          </span>
        </div>
        <div class="text-2xl font-bold text-gray-900 dark:text-white mb-1">{{ stat.value }}</div>
        <div class="text-sm text-gray-600 dark:text-gray-400">{{ stat.label }}</div>
      </div>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Chart 1 -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Yeni Galeri Başvuruları</h3>
        <Chart
          v-if="chartData && chartData.galleryApplications"
          type="line"
          :height="256"
          :data="chartData.galleryApplications"
          :options="{
            plugins: {
              legend: { display: true, position: 'top' }
            }
          }"
        />
        <div v-else class="h-64 flex items-center justify-center bg-gradient-to-br from-primary-50 to-primary-100 dark:from-primary-900/20 dark:to-primary-800/20 rounded-xl">
          <div class="text-center">
            <BarChart3 class="w-16 h-16 text-primary-400 mx-auto mb-2" />
            <p class="text-sm text-gray-500 dark:text-gray-400">Grafik yükleniyor...</p>
          </div>
        </div>
      </div>

      <!-- Chart 2 -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Araç İstatistikleri</h3>
        <Chart
          v-if="chartData && chartData.vehicleStatistics"
          type="bar"
          :height="256"
          :data="chartData.vehicleStatistics"
          :options="{
            plugins: {
              legend: { display: true, position: 'top' }
            }
          }"
        />
        <div v-else class="h-64 flex items-center justify-center bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20 rounded-xl">
          <div class="text-center">
            <TrendingUp class="w-16 h-16 text-green-400 mx-auto mb-2" />
            <p class="text-sm text-gray-500 dark:text-gray-400">Grafik yükleniyor...</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Activity Table -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700">
      <div class="p-6 border-b border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white">Son Aktiviteler</h3>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Tarih</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Aktivite</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Kullanıcı</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Detay</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="activity in activities"
              :key="activity.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatDate(activity.date) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                {{ activity.action }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                {{ activity.user }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ activity.details }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Download, BarChart3, TrendingUp, Users, Building2 } from 'lucide-vue-next'
import { ref, computed, onMounted, watch } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'
import Chart from '~/components/Chart.vue'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const selectedPeriod = ref('month')

const stats = ref([
  {
    icon: Building2,
    label: 'Yeni Galeri',
    value: '0',
    change: '+0%',
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'newGalleries'
  },
  {
    icon: Users,
    label: 'Yeni Kullanıcı',
    value: '0',
    change: '+0%',
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'newUsers'
  },
  {
    icon: TrendingUp,
    label: 'Toplam Araç',
    value: '0',
    change: '+0%',
    iconBg: 'bg-purple-100 dark:bg-purple-900/30',
    iconColor: 'text-purple-600 dark:text-purple-400',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'totalVehicles'
  },
  {
    icon: BarChart3,
    label: 'Aktif Teklif',
    value: '0',
    change: '+0%',
    iconBg: 'bg-orange-100 dark:bg-orange-900/30',
    iconColor: 'text-orange-600 dark:text-orange-400',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'activeOffers'
  }
])

const activities = ref<any[]>([])
const chartData = ref<any>(null)

const loadReports = async () => {
  loading.value = true
  try {
    const data = await api.get<any>(`/admin/reports?period=${selectedPeriod.value}`)
    
    // Update stats
    stats.value.forEach(stat => {
      if (data.stats && data.stats[stat.key]) {
        stat.value = data.stats[stat.key].value?.toString() || '0'
        stat.change = data.stats[stat.key].change || '+0%'
      }
    })
    
    // Update activities
    if (data.activities) {
      activities.value = data.activities
    }
    
    // Update chart data
    if (data.charts) {
      chartData.value = data.charts
    }
  } catch (error: any) {
    console.error('Raporlar yüklenemedi:', error)
    toast.error('Raporlar yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const exportReport = async () => {
  try {
    const blob = await api.get(`/admin/reports/export?period=${selectedPeriod.value}`, { responseType: 'blob' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `rapor-${selectedPeriod.value}-${new Date().toISOString().split('T')[0]}.xlsx`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
    toast.success('Rapor indirildi!')
  } catch (error: any) {
    toast.error('Rapor indirilemedi: ' + error.message)
  }
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR')
}

watch(selectedPeriod, () => {
  loadReports()
})

onMounted(() => {
  loadReports()
})
</script>

