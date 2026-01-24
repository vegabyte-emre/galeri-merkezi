<template>
  <section class="py-12 md:py-24 bg-gradient-to-b from-gray-50 to-white dark:from-gray-900 dark:to-gray-800 relative overflow-hidden">
    <!-- Background Decoration -->
    <div class="absolute inset-0 pointer-events-none">
      <div class="absolute top-0 right-0 w-[300px] md:w-[600px] h-[300px] md:h-[600px] bg-primary-100 dark:bg-primary-900/20 rounded-full blur-3xl opacity-50 translate-x-1/2 -translate-y-1/2"></div>
      <div class="absolute bottom-0 left-0 w-[200px] md:w-[400px] h-[200px] md:h-[400px] bg-violet-100 dark:bg-violet-900/20 rounded-full blur-3xl opacity-50 -translate-x-1/2 translate-y-1/2"></div>
    </div>

    <div class="container-custom relative z-10 px-4">
      <!-- Section Header -->
      <div class="text-center mb-10 md:mb-20">
        <div class="inline-flex items-center gap-2 px-3 py-1.5 md:px-4 md:py-2 mb-3 md:mb-4 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 rounded-full text-xs md:text-sm font-semibold">
          <Route class="w-3 h-3 md:w-4 md:h-4" />
          Nasıl Çalışır
        </div>
        <h2 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-3 md:mb-4">
          <span class="bg-gradient-to-r from-primary-600 to-violet-600 bg-clip-text text-transparent">3 Kolay Adımda</span> Başlayın
        </h2>
        <p class="text-sm sm:text-base md:text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto px-2">
          Dakikalar içinde galerinizi dijitalleştirin ve iş potansiyelinizi artırın
        </p>
      </div>

      <!-- Steps -->
      <div class="relative">
        <!-- Connection Line -->
        <div class="hidden lg:block absolute top-1/2 left-0 right-0 h-1 bg-gradient-to-r from-primary-200 via-violet-200 to-fuchsia-200 dark:from-primary-800 dark:via-violet-800 dark:to-fuchsia-800 -translate-y-1/2 z-0"></div>
        
        <div class="grid md:grid-cols-3 gap-6 md:gap-8 lg:gap-8">
          <div v-for="(step, index) in steps" :key="step.title" class="relative">
            <!-- Step Card -->
            <div class="bg-white dark:bg-gray-800 rounded-2xl md:rounded-3xl p-5 md:p-8 shadow-xl border border-gray-100 dark:border-gray-700 hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 group relative">
              <!-- Step Number - Inside card on mobile -->
              <div class="flex items-start gap-4 mb-4 md:mb-0">
                <!-- Mobile: Inline number -->
                <div class="md:hidden w-10 h-10 rounded-xl bg-gradient-to-br shadow-lg flex items-center justify-center text-white font-bold text-lg flex-shrink-0"
                     :class="step.gradient">
                  {{ index + 1 }}
                </div>
                
                <!-- Mobile: Icon next to number -->
                <div class="md:hidden flex-shrink-0">
                  <div class="w-12 h-12 rounded-xl bg-gradient-to-br flex items-center justify-center"
                       :class="step.iconBg">
                    <component :is="step.icon" class="w-6 h-6" :class="step.iconColor" />
                  </div>
                </div>
              </div>
              
              <!-- Desktop: Absolute positioned number -->
              <div class="hidden md:flex absolute -top-6 left-8 w-12 h-12 rounded-2xl bg-gradient-to-br shadow-lg items-center justify-center text-white font-bold text-xl z-10"
                   :class="step.gradient">
                {{ index + 1 }}
              </div>

              <!-- Desktop: Icon -->
              <div class="hidden md:block mt-4 mb-6">
                <div class="w-16 h-16 rounded-2xl bg-gradient-to-br flex items-center justify-center group-hover:scale-110 transition-transform duration-300"
                     :class="step.iconBg">
                  <component :is="step.icon" class="w-8 h-8" :class="step.iconColor" />
                </div>
              </div>

              <!-- Content -->
              <h3 class="text-lg md:text-2xl font-bold text-gray-900 dark:text-white mb-2 md:mb-3">
                {{ step.title }}
              </h3>
              <p class="text-sm md:text-base text-gray-600 dark:text-gray-400 leading-relaxed mb-3 md:mb-4">
                {{ step.description }}
              </p>

              <!-- Features -->
              <ul class="space-y-1.5 md:space-y-2">
                <li v-for="feature in step.features" :key="feature" class="flex items-center gap-2 text-xs md:text-sm text-gray-600 dark:text-gray-400">
                  <CheckCircle2 class="w-3.5 h-3.5 md:w-4 md:h-4 text-green-500 flex-shrink-0" />
                  <span>{{ feature }}</span>
                </li>
              </ul>
            </div>

            <!-- Arrow (except last) -->
            <div v-if="index < steps.length - 1" class="hidden lg:flex absolute -right-4 top-1/2 -translate-y-1/2 z-20">
              <div class="w-8 h-8 rounded-full bg-white dark:bg-gray-800 border-2 border-primary-200 dark:border-primary-700 flex items-center justify-center shadow-lg">
                <ChevronRight class="w-4 h-4 text-primary-500" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Bottom CTA -->
      <div class="mt-10 md:mt-16 text-center">
        <p class="text-sm md:text-lg text-gray-600 dark:text-gray-400 mb-4 md:mb-6">
          Her şey bu kadar basit! Hemen başlayın ve farkını görün.
        </p>
        <div class="flex flex-row gap-3 md:gap-4 justify-center">
          <NuxtLink 
            to="/register" 
            class="inline-flex items-center justify-center gap-2 px-5 py-3 md:px-8 md:py-4 bg-gradient-to-r from-primary-500 to-violet-500 text-white text-sm md:text-base font-bold rounded-xl shadow-lg hover:shadow-xl hover:shadow-primary-500/30 transition-all duration-300 hover:scale-105"
          >
            <Rocket class="w-4 h-4 md:w-5 md:h-5" />
            Ücretsiz Başla
          </NuxtLink>
          <NuxtLink 
            to="/pricing" 
            class="inline-flex items-center justify-center gap-2 px-5 py-3 md:px-8 md:py-4 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 text-sm md:text-base font-bold rounded-xl border border-gray-200 dark:border-gray-700 hover:bg-gray-200 dark:hover:bg-gray-700 transition-all duration-300"
          >
            Fiyatları İncele
            <ArrowRight class="w-4 h-4 md:w-5 md:h-5" />
          </NuxtLink>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { 
  Route, UserPlus, Car, CheckCircle2, ChevronRight, 
  Rocket, ArrowRight 
} from 'lucide-vue-next'
import { h } from 'vue'

// Custom TL (Turkish Lira) Icon
const TurkishLiraIcon = {
  name: 'TurkishLiraIcon',
  render() {
    return h('svg', {
      xmlns: 'http://www.w3.org/2000/svg',
      width: '24',
      height: '24',
      viewBox: '0 0 24 24',
      fill: 'none',
      stroke: 'currentColor',
      'stroke-width': '2',
      'stroke-linecap': 'round',
      'stroke-linejoin': 'round',
      class: 'lucide'
    }, [
      h('path', { d: 'M7 20V4' }),
      h('path', { d: 'M7 12h10c2.5 0 4 1.5 4 4s-1.5 4-4 4H7' }),
      h('path', { d: 'M4 9h10' }),
      h('path', { d: 'M4 14h10' })
    ])
  }
}

const steps = [
  {
    icon: UserPlus,
    title: 'Kayıt Olun',
    description: 'Galerinizi dakikalar içinde kaydedin. Hiçbir teknik bilgi gerektirmez.',
    gradient: 'from-primary-500 to-primary-600',
    iconBg: 'from-primary-100 to-primary-200 dark:from-primary-900/50 dark:to-primary-800/50',
    iconColor: 'text-primary-600 dark:text-primary-400',
    features: [
      'E-posta ile hızlı kayıt',
      'Galeri bilgilerini girin',
      '2 dakikada tamamlayın'
    ]
  },
  {
    icon: Car,
    title: 'Araçlarınızı Ekleyin',
    description: 'Stok listenizi yükleyin veya tek tek ekleyin. Fotoğraf ve video desteği.',
    gradient: 'from-violet-500 to-violet-600',
    iconBg: 'from-violet-100 to-violet-200 dark:from-violet-900/50 dark:to-violet-800/50',
    iconColor: 'text-violet-600 dark:text-violet-400',
    features: [
      'Excel ile toplu yükleme',
      'Oto Shorts video desteği',
      'Otomatik ilan aktarımı'
    ]
  },
  {
    icon: TurkishLiraIcon,
    title: 'Satış Yapın',
    description: 'Diğer galerilerle teklif alın/verin, pazarlık yapın ve satış gerçekleştirin.',
    gradient: 'from-fuchsia-500 to-fuchsia-600',
    iconBg: 'from-fuchsia-100 to-fuchsia-200 dark:from-fuchsia-900/50 dark:to-fuchsia-800/50',
    iconColor: 'text-fuchsia-600 dark:text-fuchsia-400',
    features: [
      'Gerçek zamanlı mesajlaşma',
      'Güvenli ödeme sistemi',
      'Komisyonsuz işlemler'
    ]
  }
]
</script>
