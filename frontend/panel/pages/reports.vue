<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Raporlar & Analitik</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Detaylı raporlar ve performans analizi</p>
      </div>
      <div class="flex items-center gap-3">
        <select
          v-model="selectedPeriod"
          @change="loadReports"
          class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-700 dark:text-gray-300"
        >
          <option value="week">Son Hafta</option>
          <option value="month">Son Ay</option>
          <option value="quarter">Son Çeyrek</option>
          <option value="year">Son Yıl</option>
        </select>
        <button class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all">
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
      </div>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Sales Performance -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Satış Performansı</h3>
        <div class="h-64 flex items-center justify-center bg-gradient-to-br from-primary-50 to-primary-100 dark:from-primary-900/20 dark:to-primary-800/20 rounded-xl">
          <div class="text-center">
            <TrendingUp class="w-16 h-16 text-primary-400 mx-auto mb-2" />
            <p class="text-sm text-gray-500 dark:text-gray-400">Grafik buraya gelecek</p>
          </div>
        </div>
      </div>

      <!-- Vehicle Status -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Araç Durumu Dağılımı</h3>
        <div class="h-64 flex items-center justify-center bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20 rounded-xl">
          <div class="text-center">
            <PieChart class="w-16 h-16 text-green-400 mx-auto mb-2" />
            <p class="text-sm text-gray-500 dark:text-gray-400">Grafik buraya gelecek</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Detailed Reports -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Offer Analysis -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Teklif Analizi</h3>
        <div class="space-y-4">
          <div class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400">Toplam Teklif</div>
              <div class="text-2xl font-bold text-gray-900 dark:text-white">{{ (offerData?.data?.incoming || 0) + (offerData?.data?.outgoing || 0) }}</div>
            </div>
            <div class="text-right">
              <div class="text-sm text-gray-600 dark:text-gray-400">Kabul Oranı</div>
              <div class="text-2xl font-bold text-green-600 dark:text-green-400">
                {{ offerData?.data?.byStatus?.find((s: any) => s.status === 'accepted')?.count || 0 }}
              </div>
            </div>
          </div>
          <div class="space-y-2">
            <div class="flex items-center justify-between text-sm">
              <span class="text-gray-600 dark:text-gray-400">Kabul Edilen</span>
              <span class="font-semibold text-gray-900 dark:text-white">
                {{ offerData?.data?.byStatus?.find((s: any) => s.status === 'accepted')?.count || 0 }}
              </span>
            </div>
            <div class="flex items-center justify-between text-sm">
              <span class="text-gray-600 dark:text-gray-400">Reddedilen</span>
              <span class="font-semibold text-gray-900 dark:text-white">
                {{ offerData?.data?.byStatus?.find((s: any) => s.status === 'rejected')?.count || 0 }}
              </span>
            </div>
            <div class="flex items-center justify-between text-sm">
              <span class="text-gray-600 dark:text-gray-400">Bekleyen</span>
              <span class="font-semibold text-gray-900 dark:text-white">
                {{ offerData?.data?.byStatus?.find((s: any) => s.status === 'pending')?.count || 0 }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Channel Performance -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Kanal Performansı</h3>
        <div class="space-y-4">
          <div
            v-for="channel in channelPerformance"
            :key="channel.name"
            class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl"
          >
            <div class="flex items-center justify-between mb-2">
              <span class="font-semibold text-gray-900 dark:text-white">{{ channel.name }}</span>
              <span class="text-sm text-gray-600 dark:text-gray-400">{{ channel.views }} görüntülenme</span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2">
              <div
                class="bg-primary-500 h-2 rounded-full transition-all"
                :style="{ width: channel.percentage + '%' }"
              ></div>
            </div>
            <div class="mt-2 flex items-center justify-between text-sm text-gray-600 dark:text-gray-400">
              <span>{{ channel.leads }} lead</span>
              <span>{{ channel.sales }} satış</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Top Vehicles Table -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700">
      <div class="p-6 border-b border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white">En Çok Görüntülenen Araçlar</h3>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Araç</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Fiyat</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Görüntülenme</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Teklif</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Durum</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="vehicle in (salesData?.data?.monthly || []).slice(0, 5)"
              :key="vehicle.month"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <td class="px-6 py-4">
                <div class="font-semibold text-gray-900 dark:text-white">{{ new Date(vehicle.month).toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' }) }}</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">{{ vehicle.count }} araç satıldı</div>
              </td>
              <td class="px-6 py-4 font-semibold text-gray-900 dark:text-white">{{ vehicle.revenue?.toLocaleString('tr-TR') }} ₺</td>
              <td class="px-6 py-4 text-gray-600 dark:text-gray-400">-</td>
              <td class="px-6 py-4 text-gray-600 dark:text-gray-400">-</td>
              <td class="px-6 py-4">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400"
                >
                  Satıldı
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
import { Download, TrendingUp, Eye, Users, DollarSign, PieChart } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const selectedPeriod = ref('month')
const loading = ref(false)

const salesData = ref<any>(null)
const inventoryData = ref<any>(null)
const offerData = ref<any>(null)

const keyMetrics = computed(() => {
  if (!salesData.value) return []
  
  return [
    {
      icon: Eye,
      label: 'Toplam Görüntülenme',
      value: 'N/A',
      change: '+0%',
      iconBg: 'bg-blue-100 dark:bg-blue-900/30',
      iconColor: 'text-blue-600 dark:text-blue-400',
      changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400'
    },
    {
      icon: Users,
      label: 'Toplam Teklif',
      value: offerData.value?.data?.incoming + offerData.value?.data?.outgoing || '0',
      change: '+0%',
      iconBg: 'bg-green-100 dark:bg-green-900/30',
      iconColor: 'text-green-600 dark:text-green-400',
      changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400'
    },
    {
      icon: DollarSign,
      label: 'Toplam Gelir',
      value: salesData.value?.data?.summary?.totalRevenue?.toLocaleString('tr-TR') || '0',
      change: '+0%',
      iconBg: 'bg-purple-100 dark:bg-purple-900/30',
      iconColor: 'text-purple-600 dark:text-purple-400',
      changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400'
    },
    {
      icon: TrendingUp,
      label: 'Satılan Araç',
      value: salesData.value?.data?.summary?.totalSold || '0',
      change: '+0%',
      iconBg: 'bg-orange-100 dark:bg-orange-900/30',
      iconColor: 'text-orange-600 dark:text-orange-400',
      changeClass: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400'
    }
  ]
})

const channelPerformance = ref<any[]>([])
const topVehicles = ref<any[]>([])

const loadReports = async () => {
  try {
    loading.value = true
    
    // Calculate date range based on selected period
    const endDate = new Date()
    const startDate = new Date()
    switch (selectedPeriod.value) {
      case 'week':
        startDate.setDate(startDate.getDate() - 7)
        break
      case 'month':
        startDate.setMonth(startDate.getMonth() - 1)
        break
      case 'quarter':
        startDate.setMonth(startDate.getMonth() - 3)
        break
      case 'year':
        startDate.setFullYear(startDate.getFullYear() - 1)
        break
    }
    
    const [salesRes, inventoryRes, offerRes] = await Promise.all([
      api.get<{ success: boolean; data: any }>(`/reports/sales?start_date=${startDate.toISOString()}&end_date=${endDate.toISOString()}`),
      api.get<{ success: boolean; data: any }>('/reports/inventory'),
      api.get<{ success: boolean; data: any }>(`/reports/offers?start_date=${startDate.toISOString()}&end_date=${endDate.toISOString()}`)
    ])
    
    if (salesRes.success) salesData.value = salesRes
    if (inventoryRes.success) inventoryData.value = inventoryRes
    if (offerRes.success) offerData.value = offerRes
    
  } catch (error: any) {
    toast.error('Raporlar yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadReports()
})
</script>

