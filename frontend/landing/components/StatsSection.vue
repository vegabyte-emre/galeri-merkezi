<template>
  <section class="py-12 md:py-24 bg-gradient-to-br from-primary-600 via-primary-700 to-primary-900 text-white relative overflow-hidden">
    <!-- Background Pattern -->
    <div class="absolute inset-0 opacity-10">
      <div class="absolute inset-0" style="background-image: radial-gradient(circle at 2px 2px, white 1px, transparent 0); background-size: 40px 40px;"></div>
    </div>

    <!-- Decorative Elements -->
    <div class="absolute top-0 left-0 w-48 md:w-96 h-48 md:h-96 bg-white/5 rounded-full blur-3xl -translate-x-1/2 -translate-y-1/2"></div>
    <div class="absolute bottom-0 right-0 w-48 md:w-96 h-48 md:h-96 bg-white/5 rounded-full blur-3xl translate-x-1/2 translate-y-1/2"></div>

    <div class="container-custom relative z-10">
      <!-- Mobile: 2x2 Grid, Desktop: 4 columns -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-8">
        <div
          v-for="(stat, index) in stats"
          :key="stat.label"
          class="text-center group"
          :style="{ animationDelay: `${index * 150}ms` }"
        >
          <!-- Icon - Smaller on mobile -->
          <div class="mb-2 md:mb-4 flex justify-center">
            <div class="w-10 h-10 md:w-16 md:h-16 rounded-xl md:rounded-2xl bg-white/10 backdrop-blur-md border border-white/20 flex items-center justify-center group-hover:bg-white/20 group-hover:scale-110 transition-all duration-300">
              <component :is="stat.icon" class="w-5 h-5 md:w-8 md:h-8 text-white" />
            </div>
          </div>

          <!-- Value - Smaller on mobile -->
          <div class="mb-1 md:mb-2">
            <span 
              class="text-2xl sm:text-3xl md:text-5xl lg:text-6xl font-bold bg-gradient-to-r from-white to-primary-200 bg-clip-text text-transparent"
              v-html="stat.value"
            ></span>
          </div>

          <!-- Label - Smaller on mobile -->
          <div class="text-primary-100 text-xs sm:text-sm md:text-lg font-medium">
            {{ stat.label }}
          </div>

          <!-- Description - Hidden on mobile -->
          <div class="hidden md:block mt-2 text-primary-200 text-sm opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            {{ stat.description }}
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { Users, Car, TrendingUp, Heart } from 'lucide-vue-next'
import { useIntersectionObserver } from '@vueuse/core'

const stats = [
  {
    icon: Users,
    value: '500+',
    label: 'Aktif Galeri',
    description: 'Platformumuzda aktif olarak çalışan galeri sayısı'
  },
  {
    icon: Car,
    value: '10K+',
    label: 'Araç',
    description: 'Sistemde kayıtlı toplam araç sayısı'
  },
  {
    icon: TrendingUp,
    value: '5K+',
    label: 'Aylık Teklif',
    description: 'Her ay gerçekleşen teklif sayısı'
  },
  {
    icon: Heart,
    value: '99%',
    label: 'Memnuniyet',
    description: 'Kullanıcı memnuniyet oranı'
  }
]
</script>

<style scoped>
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.group {
  animation: fade-in-up 0.8s ease-out both;
}
</style>
