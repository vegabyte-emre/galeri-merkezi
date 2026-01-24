<template>
  <section class="py-12 md:py-24 bg-white dark:bg-gray-900 relative overflow-hidden">
    <!-- Background -->
    <div class="absolute inset-0 pointer-events-none opacity-50">
      <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] md:w-[800px] h-[400px] md:h-[800px] bg-gradient-radial from-primary-100 dark:from-primary-900/20 to-transparent rounded-full"></div>
    </div>

    <div class="container-custom relative z-10 px-4">
      <!-- Section Header -->
      <div class="text-center mb-8 md:mb-16">
        <div class="inline-flex items-center gap-2 px-3 py-1.5 md:px-4 md:py-2 mb-3 md:mb-4 bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 rounded-full text-xs md:text-sm font-semibold">
          <Plug class="w-3 h-3 md:w-4 md:h-4" />
          Entegrasyonlar
        </div>
        <h2 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-3 md:mb-4">
          Tüm Pazar Yerleri ile <span class="text-primary-600">Entegre</span>
        </h2>
        <p class="text-sm md:text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto px-2">
          Araçlarınızı tek tıklama ile tüm büyük pazar yerlerinde yayınlayın
        </p>
      </div>

      <!-- Main Integration Grid -->
      <div class="grid sm:grid-cols-2 md:grid-cols-3 gap-4 md:gap-6 mb-8 md:mb-12">
        <!-- Sahibinden -->
        <div class="group relative bg-gradient-to-br from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20 rounded-2xl md:rounded-3xl p-5 md:p-8 border border-yellow-200 dark:border-yellow-800/50 hover:shadow-2xl hover:shadow-yellow-500/20 transition-all duration-300 hover:-translate-y-2">
          <div class="absolute top-3 right-3 md:top-4 md:right-4">
            <div class="w-2 h-2 md:w-3 md:h-3 rounded-full bg-green-500 animate-pulse"></div>
          </div>
          <div class="w-12 h-12 md:w-16 md:h-16 rounded-xl md:rounded-2xl bg-gradient-to-br from-yellow-400 to-orange-500 flex items-center justify-center mb-4 md:mb-6 shadow-lg group-hover:scale-110 transition-transform">
            <span class="text-white font-bold text-lg md:text-2xl">S</span>
          </div>
          <h3 class="text-lg md:text-2xl font-bold text-gray-900 dark:text-white mb-1 md:mb-2">Sahibinden.com</h3>
          <p class="text-gray-600 dark:text-gray-400 text-sm md:text-base mb-3 md:mb-4">Türkiye'nin en büyük ilan sitesine otomatik ilan aktarımı</p>
          <div class="flex items-center gap-2 text-xs md:text-sm text-green-600 dark:text-green-400 font-semibold">
            <CheckCircle class="w-3 h-3 md:w-4 md:h-4" />
            Aktif Entegrasyon
          </div>
        </div>

        <!-- Arabam -->
        <div class="group relative bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-2xl md:rounded-3xl p-5 md:p-8 border border-blue-200 dark:border-blue-800/50 hover:shadow-2xl hover:shadow-blue-500/20 transition-all duration-300 hover:-translate-y-2">
          <div class="absolute top-3 right-3 md:top-4 md:right-4">
            <div class="w-2 h-2 md:w-3 md:h-3 rounded-full bg-green-500 animate-pulse"></div>
          </div>
          <div class="w-12 h-12 md:w-16 md:h-16 rounded-xl md:rounded-2xl bg-gradient-to-br from-blue-400 to-indigo-500 flex items-center justify-center mb-4 md:mb-6 shadow-lg group-hover:scale-110 transition-transform">
            <span class="text-white font-bold text-lg md:text-2xl">A</span>
          </div>
          <h3 class="text-lg md:text-2xl font-bold text-gray-900 dark:text-white mb-1 md:mb-2">Arabam.com</h3>
          <p class="text-gray-600 dark:text-gray-400 text-sm md:text-base mb-3 md:mb-4">Premium araç satışları için güvenilir platform entegrasyonu</p>
          <div class="flex items-center gap-2 text-xs md:text-sm text-green-600 dark:text-green-400 font-semibold">
            <CheckCircle class="w-3 h-3 md:w-4 md:h-4" />
            Aktif Entegrasyon
          </div>
        </div>

        <!-- Oto Shorts -->
        <div class="group relative bg-gradient-to-br from-violet-50 to-fuchsia-50 dark:from-violet-900/20 dark:to-fuchsia-900/20 rounded-2xl md:rounded-3xl p-5 md:p-8 border border-violet-200 dark:border-violet-800/50 hover:shadow-2xl hover:shadow-violet-500/20 transition-all duration-300 hover:-translate-y-2 sm:col-span-2 md:col-span-1">
          <div class="absolute top-3 right-3 md:top-4 md:right-4">
            <div class="px-1.5 py-0.5 md:px-2 md:py-1 rounded-full bg-violet-500 text-white text-[10px] md:text-xs font-bold">YENİ</div>
          </div>
          <div class="w-12 h-12 md:w-16 md:h-16 rounded-xl md:rounded-2xl bg-gradient-to-br from-violet-400 to-fuchsia-500 flex items-center justify-center mb-4 md:mb-6 shadow-lg group-hover:scale-110 transition-transform">
            <Video class="w-6 h-6 md:w-8 md:h-8 text-white" />
          </div>
          <h3 class="text-lg md:text-2xl font-bold text-gray-900 dark:text-white mb-1 md:mb-2">Oto Shorts</h3>
          <p class="text-gray-600 dark:text-gray-400 text-sm md:text-base mb-3 md:mb-4">Video tabanlı araç tanıtım platformu ile viral olun</p>
          <div class="flex items-center gap-2 text-xs md:text-sm text-violet-600 dark:text-violet-400 font-semibold">
            <Sparkles class="w-3 h-3 md:w-4 md:h-4" />
            Yeni Özellik
          </div>
        </div>
      </div>

      <!-- Secondary Integrations -->
      <div class="bg-gray-50 dark:bg-gray-800 rounded-2xl md:rounded-3xl p-5 md:p-8 border border-gray-200 dark:border-gray-700">
        <h4 class="text-base md:text-lg font-bold text-gray-900 dark:text-white mb-4 md:mb-6 text-center">Diğer Entegrasyonlar</h4>
        
        <div class="grid grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-3 md:gap-6">
          <div v-for="integration in otherIntegrations" :key="integration.name" 
               class="group flex flex-col items-center p-3 md:p-4 bg-white dark:bg-gray-900 rounded-xl md:rounded-2xl border border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-600 transition-all hover:shadow-lg cursor-pointer">
            <div class="w-8 h-8 md:w-12 md:h-12 rounded-lg md:rounded-xl mb-2 md:mb-3 flex items-center justify-center text-lg md:text-2xl font-bold group-hover:scale-110 transition-transform"
                 :class="integration.bg">
              {{ integration.icon }}
            </div>
            <span class="text-xs md:text-sm font-medium text-gray-700 dark:text-gray-300 text-center">{{ integration.name }}</span>
            <span class="text-[10px] md:text-xs mt-1 px-1.5 md:px-2 py-0.5 rounded-full"
                  :class="integration.status === 'active' ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' : 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400'">
              {{ integration.status === 'active' ? 'Aktif' : 'Yakında' }}
            </span>
          </div>
        </div>
      </div>

      <!-- Integration Benefits -->
      <div class="mt-10 md:mt-16 grid grid-cols-1 sm:grid-cols-3 gap-6 md:gap-8">
        <div class="text-center">
          <div class="w-10 h-10 md:w-14 md:h-14 mx-auto mb-3 md:mb-4 rounded-xl md:rounded-2xl bg-gradient-to-br from-emerald-400 to-green-500 flex items-center justify-center shadow-lg">
            <Clock class="w-5 h-5 md:w-7 md:h-7 text-white" />
          </div>
          <h4 class="text-base md:text-lg font-bold text-gray-900 dark:text-white mb-1 md:mb-2">Zaman Tasarrufu</h4>
          <p class="text-gray-600 dark:text-gray-400 text-sm md:text-base">Her platforma ayrı ayrı ilan girmek yerine tek noktadan yönetin</p>
        </div>
        <div class="text-center">
          <div class="w-10 h-10 md:w-14 md:h-14 mx-auto mb-3 md:mb-4 rounded-xl md:rounded-2xl bg-gradient-to-br from-blue-400 to-indigo-500 flex items-center justify-center shadow-lg">
            <RefreshCw class="w-5 h-5 md:w-7 md:h-7 text-white" />
          </div>
          <h4 class="text-base md:text-lg font-bold text-gray-900 dark:text-white mb-1 md:mb-2">Otomatik Senkronizasyon</h4>
          <p class="text-gray-600 dark:text-gray-400 text-sm md:text-base">Fiyat ve stok değişiklikleri anında tüm platformlara yansır</p>
        </div>
        <div class="text-center">
          <div class="w-10 h-10 md:w-14 md:h-14 mx-auto mb-3 md:mb-4 rounded-xl md:rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center shadow-lg">
            <TrendingUp class="w-5 h-5 md:w-7 md:h-7 text-white" />
          </div>
          <h4 class="text-base md:text-lg font-bold text-gray-900 dark:text-white mb-1 md:mb-2">Daha Fazla Satış</h4>
          <p class="text-gray-600 dark:text-gray-400 text-sm md:text-base">Tüm platformlarda gözükün, daha fazla müşteriye ulaşın</p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { 
  Plug, CheckCircle, Video, Sparkles, Clock, RefreshCw, TrendingUp 
} from 'lucide-vue-next'

const otherIntegrations = [
  { name: 'Letgo', icon: 'L', bg: 'bg-gradient-to-br from-red-400 to-pink-500 text-white', status: 'active' },
  { name: 'Facebook', icon: 'f', bg: 'bg-gradient-to-br from-blue-500 to-blue-600 text-white', status: 'active' },
  { name: 'Instagram', icon: 'I', bg: 'bg-gradient-to-br from-pink-500 to-purple-500 text-white', status: 'coming' },
  { name: 'Google Ads', icon: 'G', bg: 'bg-gradient-to-br from-red-500 to-yellow-500 text-white', status: 'coming' },
  { name: 'WhatsApp', icon: 'W', bg: 'bg-gradient-to-br from-green-400 to-green-500 text-white', status: 'active' },
  { name: 'Excel', icon: 'X', bg: 'bg-gradient-to-br from-green-600 to-green-700 text-white', status: 'active' }
]
</script>
