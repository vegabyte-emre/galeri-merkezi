<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Detaylı Analitik</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Platform performansı ve kullanıcı davranışları</p>
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
          @click="exportAnalytics"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          <Download class="w-4 h-4 inline mr-2" />
          Rapor İndir
        </button>
      </div>
    </div>

    <!-- Key Metrics -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div
        v-for="metric in keyMetrics"
        :key="metric.label"
        class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700"
      >
        <div class="flex items-center justify-between mb-4">
          <div
            class="w-12 h-12 rounded-xl flex items-center justify-center"
            :class="metric.iconBg"
          >
            <component :is="metric.icon" class="w-6 h-6" :class="metric.iconColor" />
          </div>
          <span
            class="text-xs font-semibold px-2 py-1 rounded-full"
            :class="metric.changeClass"
          >
            {{ metric.change }}
          </span>
        </div>
        <div class="text-3xl font-bold text-gray-900 dark:text-white mb-1">{{ metric.value }}</div>
        <div class="text-sm text-gray-600 dark:text-gray-400">{{ metric.label }}</div>
        <div class="mt-2 text-xs text-gray-500 dark:text-gray-400">{{ metric.period }}</div>
      </div>
    </div>

    <!-- Main Charts -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- User Growth -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Kullanıcı Büyümesi</h3>
        <Chart
          v-if="chartData && chartData.userGrowth"
          type="line"
          :height="256"
          :data="chartData.userGrowth"
          :options="{
            plugins: {
              legend: { display: true, position: 'top' }
            }
          }"
        />
        <div v-else class="h-64 flex items-center justify-center bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20 rounded-xl">
          <div class="text-center">
            <TrendingUp class="w-16 h-16 text-blue-400 mx-auto mb-2" />
            <p class="text-sm text-gray-500 dark:text-gray-400">Grafik yükleniyor...</p>
          </div>
        </div>
      </div>

      <!-- Revenue Chart -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Gelir Trendi</h3>
        <Chart
          v-if="chartData && chartData.revenue"
          type="bar"
          :height="256"
          :data="chartData.revenue"
          :options="{
            plugins: {
              legend: { display: true, position: 'top' }
            }
          }"
        />
        <div v-else class="h-64 flex items-center justify-center bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20 rounded-xl">
          <div class="text-center">
            <DollarSign class="w-16 h-16 text-green-400 mx-auto mb-2" />
            <p class="text-sm text-gray-500 dark:text-gray-400">Grafik yükleniyor...</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Detailed Analytics -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Activity Breakdown -->
      <div class="lg:col-span-2 bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Aktivite Dağılımı</h3>
        <div class="space-y-4">
          <div
            v-for="activity in activities"
            :key="activity.type"
            class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl"
          >
            <div class="flex items-center gap-3">
              <div
                class="w-10 h-10 rounded-lg flex items-center justify-center"
                :class="activity.iconBg"
              >
                <component :is="activity.icon" class="w-5 h-5" :class="activity.iconColor" />
              </div>
              <div>
                <div class="font-semibold text-gray-900 dark:text-white">{{ activity.type }}</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">{{ activity.description }}</div>
              </div>
            </div>
            <div class="text-right">
              <div class="text-xl font-bold text-gray-900 dark:text-white">{{ activity.count }}</div>
              <div class="text-xs text-gray-500 dark:text-gray-400">{{ activity.percentage }}%</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Top Performers -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">En İyi Performans</h3>
        <div class="space-y-4">
          <div
            v-for="(performer, index) in topPerformers"
            :key="index"
            class="flex items-center gap-3 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-xl"
          >
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold text-sm">
              {{ index + 1 }}
            </div>
            <div class="flex-1">
              <div class="font-semibold text-gray-900 dark:text-white">{{ performer.name }}</div>
              <div class="text-xs text-gray-500 dark:text-gray-400">{{ performer.metric }}</div>
            </div>
            <div class="text-sm font-semibold text-primary-600 dark:text-primary-400">
              {{ performer.value }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Geographic Distribution -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
      <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Coğrafi Dağılım</h3>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div
          v-for="region in regions"
          :key="region.name"
          class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl text-center"
        >
          <div class="text-2xl font-bold text-gray-900 dark:text-white mb-1">{{ region.count }}</div>
          <div class="text-sm text-gray-600 dark:text-gray-400">{{ region.name }}</div>
          <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">{{ region.percentage }}%</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Download, TrendingUp, Users, Building2, Car, DollarSign, Activity } from 'lucide-vue-next'
import { ref, computed, onMounted, watch } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'
import Chart from '~/components/Chart.vue'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const selectedPeriod = ref('month')

const keyMetrics = ref([
  {
    icon: Users,
    label: 'Aktif Kullanıcı',
    value: '0',
    change: '+0%',
    period: 'Bu ay',
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'activeUsers'
  },
  {
    icon: Building2,
    label: 'Aktif Galeri',
    value: '0',
    change: '+0%',
    period: 'Bu ay',
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'activeGalleries'
  },
  {
    icon: Car,
    label: 'Toplam Araç',
    value: '0',
    change: '+0%',
    period: 'Bu ay',
    iconBg: 'bg-purple-100 dark:bg-purple-900/30',
    iconColor: 'text-purple-600 dark:text-purple-400',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'totalVehicles'
  },
  {
    icon: DollarSign,
    label: 'Toplam Gelir',
    value: '₺0',
    change: '+0%',
    period: 'Bu ay',
    iconBg: 'bg-orange-100 dark:bg-orange-900/30',
    iconColor: 'text-orange-600 dark:text-orange-400',
    changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    key: 'totalRevenue'
  }
])

const activities = ref<any[]>([])
const topPerformers = ref<any[]>([])
const regions = ref<any[]>([])
const chartData = ref<any>(null)

const loadAnalytics = async () => {
  loading.value = true
  try {
    const data = await api.get<any>(`/admin/analytics?period=${selectedPeriod.value}`)
    
    // Update metrics
    keyMetrics.value.forEach(metric => {
      if (data.metrics && data.metrics[metric.key]) {
        metric.value = data.metrics[metric.key].value?.toString() || '0'
        metric.change = data.metrics[metric.key].change || '+0%'
      }
    })
    
    // Update activities
    if (data.activities) {
      activities.value = data.activities
    }
    
    // Update top performers
    if (data.topPerformers) {
      topPerformers.value = data.topPerformers
    }
    
    // Update regions
    if (data.regions) {
      regions.value = data.regions
    }
    
    // Update chart data
    if (data.charts) {
      chartData.value = data.charts
    }
  } catch (error: any) {
    console.error('Analitik verileri yüklenemedi:', error)
    toast.error('Analitik verileri yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const exportAnalytics = async () => {
  try {
    const blob = await api.get(`/admin/analytics/export?period=${selectedPeriod.value}`, { responseType: 'blob' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `analitik-${selectedPeriod.value}-${new Date().toISOString().split('T')[0]}.xlsx`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
    toast.success('Analitik raporu indirildi!')
  } catch (error: any) {
    toast.error('Rapor indirilemedi: ' + error.message)
  }
}

watch(selectedPeriod, () => {
  loadAnalytics()
})

onMounted(() => {
  loadAnalytics()
})
</script>

