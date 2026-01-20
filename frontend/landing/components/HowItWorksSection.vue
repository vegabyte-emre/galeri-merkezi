<template>
  <section class="py-24 bg-gradient-to-b from-gray-50 to-white dark:from-gray-900 dark:to-gray-800 relative overflow-hidden">
    <!-- Background Decoration -->
    <div class="absolute inset-0 pointer-events-none">
      <div class="absolute top-0 right-0 w-[600px] h-[600px] bg-primary-100 dark:bg-primary-900/20 rounded-full blur-3xl opacity-50 translate-x-1/2 -translate-y-1/2"></div>
      <div class="absolute bottom-0 left-0 w-[400px] h-[400px] bg-violet-100 dark:bg-violet-900/20 rounded-full blur-3xl opacity-50 -translate-x-1/2 translate-y-1/2"></div>
    </div>

    <div class="container-custom relative z-10">
      <!-- Section Header -->
      <div class="text-center mb-20">
        <div class="inline-flex items-center gap-2 px-4 py-2 mb-4 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 rounded-full text-sm font-semibold">
          <Route class="w-4 h-4" />
          Nasil Calisir
        </div>
        <h2 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
          <span class="bg-gradient-to-r from-primary-600 to-violet-600 bg-clip-text text-transparent">3 Kolay Adimda</span> Baslayin
        </h2>
        <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
          Dakikalar icinde galerinizi dijitallestirin ve is potansiyelinizi arttirin
        </p>
      </div>

      <!-- Steps -->
      <div class="relative">
        <!-- Connection Line -->
        <div class="hidden lg:block absolute top-1/2 left-0 right-0 h-1 bg-gradient-to-r from-primary-200 via-violet-200 to-fuchsia-200 dark:from-primary-800 dark:via-violet-800 dark:to-fuchsia-800 -translate-y-1/2 z-0"></div>
        
        <div class="grid md:grid-cols-3 gap-12 lg:gap-8">
          <div v-for="(step, index) in steps" :key="step.title" class="relative">
            <!-- Step Card -->
            <div class="bg-white dark:bg-gray-800 rounded-3xl p-8 shadow-xl border border-gray-100 dark:border-gray-700 hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 group">
              <!-- Step Number -->
              <div class="absolute -top-6 left-8 w-12 h-12 rounded-2xl bg-gradient-to-br shadow-lg flex items-center justify-center text-white font-bold text-xl z-10"
                   :class="step.gradient">
                {{ index + 1 }}
              </div>

              <!-- Icon -->
              <div class="mt-4 mb-6">
                <div class="w-16 h-16 rounded-2xl bg-gradient-to-br flex items-center justify-center group-hover:scale-110 transition-transform duration-300"
                     :class="step.iconBg">
                  <component :is="step.icon" class="w-8 h-8" :class="step.iconColor" />
                </div>
              </div>

              <!-- Content -->
              <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-3">
                {{ step.title }}
              </h3>
              <p class="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                {{ step.description }}
              </p>

              <!-- Features -->
              <ul class="space-y-2">
                <li v-for="feature in step.features" :key="feature" class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                  <CheckCircle2 class="w-4 h-4 text-green-500 flex-shrink-0" />
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
      <div class="mt-16 text-center">
        <p class="text-lg text-gray-600 dark:text-gray-400 mb-6">
          Hersey bu kadar basit! Hemen baslayin ve farkini gorun.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <NuxtLink 
            to="/register" 
            class="inline-flex items-center justify-center gap-2 px-8 py-4 bg-gradient-to-r from-primary-500 to-violet-500 text-white font-bold rounded-xl shadow-lg hover:shadow-xl hover:shadow-primary-500/30 transition-all duration-300 hover:scale-105"
          >
            <Rocket class="w-5 h-5" />
            Ucretsiz Basla
          </NuxtLink>
          <NuxtLink 
            to="/pricing" 
            class="inline-flex items-center justify-center gap-2 px-8 py-4 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 font-bold rounded-xl border border-gray-200 dark:border-gray-700 hover:bg-gray-200 dark:hover:bg-gray-700 transition-all duration-300"
          >
            Fiyatlari Incele
            <ArrowRight class="w-5 h-5" />
          </NuxtLink>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { 
  Route, UserPlus, Car, BadgeDollarSign, CheckCircle2, ChevronRight, 
  Rocket, ArrowRight 
} from 'lucide-vue-next'

const steps = [
  {
    icon: UserPlus,
    title: 'Kayit Olun',
    description: 'Galerinizi dakikalar icinde kaydedin. Hicbir teknik bilgi gerektirmez.',
    gradient: 'from-primary-500 to-primary-600',
    iconBg: 'from-primary-100 to-primary-200 dark:from-primary-900/50 dark:to-primary-800/50',
    iconColor: 'text-primary-600 dark:text-primary-400',
    features: [
      'E-posta ile hizli kayit',
      'Galeri bilgilerini girin',
      '2 dakikada tamamlayin'
    ]
  },
  {
    icon: Car,
    title: 'Araclarinizi Ekleyin',
    description: 'Stok listenizi yukleyin veya tek tek ekleyin. Fotograf ve video destegi.',
    gradient: 'from-violet-500 to-violet-600',
    iconBg: 'from-violet-100 to-violet-200 dark:from-violet-900/50 dark:to-violet-800/50',
    iconColor: 'text-violet-600 dark:text-violet-400',
    features: [
      'Excel ile toplu yukleme',
      'Oto Shorts video destegi',
      'Otomatik ilan aktarimi'
    ]
  },
  {
    icon: BadgeDollarSign,
    title: 'Satis Yapin',
    description: 'Diger galerilerle teklif alin/verin, pazarlık yapin ve satis gerceklestirin.',
    gradient: 'from-fuchsia-500 to-fuchsia-600',
    iconBg: 'from-fuchsia-100 to-fuchsia-200 dark:from-fuchsia-900/50 dark:to-fuchsia-800/50',
    iconColor: 'text-fuchsia-600 dark:text-fuchsia-400',
    features: [
      'Gercek zamanli mesajlasma',
      'Guvenli odeme sistemi',
      'Komisyonsuz islemler'
    ]
  }
]
</script>
