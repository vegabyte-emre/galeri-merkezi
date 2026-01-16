<template>
  <ClientOnly>
    <div class="relative" :style="{ height: height + 'px' }">
      <canvas ref="chartCanvas"></canvas>
    </div>
    <template #fallback>
      <div class="relative flex items-center justify-center" :style="{ height: height + 'px' }">
        <div class="text-sm text-gray-500 dark:text-gray-400">Grafik yükleniyor...</div>
      </div>
    </template>
  </ClientOnly>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted } from 'vue'

// Chart.js will be imported dynamically to avoid SSR issues
let ChartJS: any = null

interface Props {
  type: 'line' | 'bar' | 'pie' | 'doughnut'
  data: any
  options?: any
  height?: number
}

const props = withDefaults(defineProps<Props>(), {
  height: 300,
  options: () => ({})
})

const chartCanvas = ref<HTMLCanvasElement | null>(null)
let chartInstance: any = null

const defaultOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'top' as const,
    },
    tooltip: {
      enabled: true
    }
  },
  scales: props.type !== 'pie' && props.type !== 'doughnut' ? {
    x: {
      grid: {
        display: false
      }
    },
    y: {
      grid: {
        color: 'rgba(0, 0, 0, 0.05)'
      }
    }
  } : undefined
}

onMounted(async () => {
  if (process.client && chartCanvas.value) {
    // Dynamic import for client-side only
    const chartModule = await import('chart.js')
    ChartJS = chartModule.Chart || chartModule.default
    
    const {
      CategoryScale,
      LinearScale,
      PointElement,
      LineElement,
      BarElement,
      ArcElement,
      Title,
      Tooltip,
      Legend,
      Filler
    } = chartModule
    
    ChartJS.register(
      CategoryScale,
      LinearScale,
      PointElement,
      LineElement,
      BarElement,
      ArcElement,
      Title,
      Tooltip,
      Legend,
      Filler
    )
    
    chartInstance = new ChartJS(chartCanvas.value, {
      type: props.type,
      data: props.data,
      options: { ...defaultOptions, ...props.options }
    })
  }
})

watch(() => props.data, () => {
  if (chartInstance) {
    chartInstance.data = props.data
    chartInstance.update()
  }
}, { deep: true })

onUnmounted(() => {
  if (chartInstance) {
    chartInstance.destroy()
  }
})
</script>














