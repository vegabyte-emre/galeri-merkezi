<template>
  <div class="min-h-screen bg-gray-900 text-white p-8">
    <div class="max-w-4xl mx-auto">
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-bold">Splash Screen Ayarları</h1>
          <p class="text-gray-400 mt-2">Mobil uygulama açılış ekranını özelleştirin</p>
        </div>
        <button @click="saveConfig" :disabled="saving" class="px-6 py-3 bg-orange-500 hover:bg-orange-600 rounded-xl font-semibold transition-colors disabled:opacity-50">
          {{ saving ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet' }}
        </button>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div class="bg-gray-800 rounded-2xl p-6">
          <h2 class="text-xl font-semibold mb-4">Önizleme</h2>
          <div class="aspect-[9/16] rounded-xl overflow-hidden flex flex-col items-center justify-center p-8 relative" :style="{ background: `linear-gradient(135deg, ${config.gradientColors?.[0] || '#0D1117'}, ${config.gradientColors?.[1] || '#161B22'})` }">
            <div class="w-24 h-24 rounded-full flex items-center justify-center mb-6" :style="{ background: `linear-gradient(135deg, ${config.gradientColors?.[0] || '#FF6B35'}, ${config.gradientColors?.[1] || '#FF8F5F'})` }">
              <span class="text-5xl">{{ config.logoEmoji || '🚗' }}</span>
            </div>
            <h3 class="text-2xl font-black text-white text-center mb-2">{{ config.title || 'Otobia' }}</h3>
            <p class="text-lg font-medium text-orange-400 text-center mb-2">{{ config.subtitle || 'Araç Yönetim Platformu' }}</p>
            <p class="text-sm text-gray-400 text-center mb-8">{{ config.tagline || 'Galerinizi Dijitalleştirin' }}</p>
            <div class="w-3/4 h-1 bg-gray-700 rounded-full overflow-hidden mb-4">
              <div class="h-full bg-orange-500 w-1/2 rounded-full"></div>
            </div>
            <p class="text-xs text-gray-500 absolute bottom-4">{{ config.version || 'v1.0.0' }}</p>
          </div>
        </div>

        <div class="space-y-6">
          <div class="bg-gray-800 rounded-2xl p-6">
            <h2 class="text-xl font-semibold mb-4">Temel Bilgiler</h2>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-400 mb-2">Başlık</label>
                <input v-model="config.title" type="text" class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white focus:ring-2 focus:ring-orange-500 focus:border-transparent" placeholder="Otobia" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-400 mb-2">Alt Başlık</label>
                <input v-model="config.subtitle" type="text" class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white focus:ring-2 focus:ring-orange-500 focus:border-transparent" placeholder="Araç Yönetim Platformu" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-400 mb-2">Slogan</label>
                <input v-model="config.tagline" type="text" class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white focus:ring-2 focus:ring-orange-500 focus:border-transparent" placeholder="Galerinizi Dijitalleştirin" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-400 mb-2">Versiyon</label>
                <input v-model="config.version" type="text" class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white focus:ring-2 focus:ring-orange-500 focus:border-transparent" placeholder="v1.0.0" />
              </div>
            </div>
          </div>

          <div class="bg-gray-800 rounded-2xl p-6">
            <h2 class="text-xl font-semibold mb-4">Görünüm</h2>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-400 mb-2">Logo Emoji</label>
                <input v-model="config.logoEmoji" type="text" class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white text-2xl focus:ring-2 focus:ring-orange-500 focus:border-transparent" placeholder="🚗" />
              </div>
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-400 mb-2">Gradient Başlangıç</label>
                  <div class="flex items-center gap-3">
                    <input v-model="gradientStart" type="color" class="w-12 h-12 rounded-lg cursor-pointer border-0" />
                    <input v-model="gradientStart" type="text" class="flex-1 px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white focus:ring-2 focus:ring-orange-500 focus:border-transparent" />
                  </div>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-400 mb-2">Gradient Bitiş</label>
                  <div class="flex items-center gap-3">
                    <input v-model="gradientEnd" type="color" class="w-12 h-12 rounded-lg cursor-pointer border-0" />
                    <input v-model="gradientEnd" type="text" class="flex-1 px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white focus:ring-2 focus:ring-orange-500 focus:border-transparent" />
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-gray-800 rounded-2xl p-6">
            <h2 class="text-xl font-semibold mb-4">Animasyon</h2>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-400 mb-2">Animasyon Süresi: {{ config.animationDuration || 3000 }}ms</label>
                <input v-model.number="config.animationDuration" type="range" min="1000" max="5000" step="500" class="w-full h-2 bg-gray-700 rounded-lg appearance-none cursor-pointer accent-orange-500" />
              </div>
              <div class="flex items-center justify-between">
                <span class="text-sm text-gray-400">Parçacık Efekti</span>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input v-model="config.showParticles" type="checkbox" class="sr-only peer" />
                  <div class="w-11 h-6 bg-gray-700 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-orange-500"></div>
                </label>
              </div>
            </div>
          </div>

          <div v-if="lastUpdated" class="text-center text-gray-500 text-sm">Son güncelleme: {{ formatDate(lastUpdated) }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'

interface SplashConfig {
  title: string
  subtitle: string
  tagline: string
  version: string
  logoEmoji?: string
  gradientColors?: string[]
  animationDuration?: number
  showParticles?: boolean
}

const api = useApi()
const saving = ref(false)
const lastUpdated = ref<string | null>(null)

const config = ref<SplashConfig>({
  title: 'Otobia',
  subtitle: 'Araç Yönetim Platformu',
  tagline: 'Galerinizi Dijitalleştirin',
  version: 'v1.0.0',
  logoEmoji: '🚗',
  gradientColors: ['#FF6B35', '#FF8F5F'],
  animationDuration: 3000,
  showParticles: true,
})

const gradientStart = computed({
  get: () => config.value.gradientColors?.[0] || '#FF6B35',
  set: (val) => {
    if (!config.value.gradientColors) config.value.gradientColors = ['#FF6B35', '#FF8F5F']
    config.value.gradientColors[0] = val
  }
})

const gradientEnd = computed({
  get: () => config.value.gradientColors?.[1] || '#FF8F5F',
  set: (val) => {
    if (!config.value.gradientColors) config.value.gradientColors = ['#FF6B35', '#FF8F5F']
    config.value.gradientColors[1] = val
  }
})

const loadConfig = async () => {
  try {
    const response = await api.get<any>('/admin/splash-config')
    if (response.success && response.config) {
      config.value = { ...config.value, ...response.config }
      lastUpdated.value = response.lastUpdated
    }
  } catch (error) {
    console.error('Failed to load splash config:', error)
  }
}

const saveConfig = async () => {
  saving.value = true
  try {
    const response = await api.put<any>('/admin/splash-config', { config: config.value })
    if (response.success) {
      alert('Splash screen ayarları başarıyla kaydedildi!')
      lastUpdated.value = new Date().toISOString()
    }
  } catch (error: any) {
    alert('Hata: ' + (error.message || 'Ayarlar kaydedilemedi'))
  } finally {
    saving.value = false
  }
}

const formatDate = (dateStr: string) => new Date(dateStr).toLocaleString('tr-TR')

onMounted(() => { loadConfig() })
</script>
