<template>
  <section class="py-12 md:py-24 bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 text-white relative overflow-hidden">
    <!-- Animated Background -->
    <div class="absolute inset-0">
      <div class="absolute top-0 left-1/4 w-48 md:w-96 h-48 md:h-96 bg-primary-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse"></div>
      <div class="absolute bottom-0 right-1/4 w-48 md:w-96 h-48 md:h-96 bg-purple-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse animation-delay-2000"></div>
    </div>

    <!-- Grid Pattern -->
    <div class="absolute inset-0 opacity-10" style="background-image: linear-gradient(to right, rgba(255,255,255,0.1) 1px, transparent 1px), linear-gradient(to bottom, rgba(255,255,255,0.1) 1px, transparent 1px); background-size: 50px 50px;"></div>

    <div class="container-custom relative z-10 px-4">
      <div class="max-w-4xl mx-auto text-center">
        <!-- Badge -->
        <div class="inline-flex items-center gap-2 px-3 py-1.5 md:px-4 md:py-2 mb-4 md:mb-6 bg-white/10 backdrop-blur-md rounded-full border border-white/20">
          <Rocket class="w-3 h-3 md:w-4 md:h-4" />
          <span class="text-xs md:text-sm font-medium">Hemen Başlayın</span>
        </div>

        <!-- Heading -->
        <h2 class="text-2xl sm:text-3xl md:text-5xl lg:text-6xl font-bold mb-4 md:mb-6 leading-tight px-2">
          İşinizi <span class="bg-gradient-to-r from-primary-400 to-purple-400 bg-clip-text text-transparent">Büyütmeye</span> Hazır mısınız?
        </h2>

        <!-- Description -->
        <p class="text-sm sm:text-base md:text-xl lg:text-2xl text-gray-300 mb-6 md:mb-10 max-w-2xl mx-auto leading-relaxed px-2">
          Galerinizi kaydedin ve platformun tüm özelliklerinden yararlanın. Ücretsiz başlangıç paketi ile hemen başlayın.
        </p>

        <!-- CTA Buttons -->
        <div class="flex flex-row gap-3 md:gap-4 justify-center items-center mb-8 md:mb-12">
          <NuxtLink 
            to="/register" 
            class="group relative px-5 py-3 md:px-10 md:py-5 bg-gradient-to-r from-primary-500 to-primary-600 text-white text-sm md:text-base font-bold rounded-xl shadow-2xl hover:shadow-primary-500/50 transition-all duration-300 hover:scale-105 hover:-translate-y-1 overflow-hidden"
          >
            <span class="relative z-10 flex items-center gap-2">
              <span>Ücretsiz Kayıt Ol</span>
              <ArrowRight class="w-4 h-4 md:w-5 md:h-5 group-hover:translate-x-1 transition-transform" />
            </span>
            <div class="absolute inset-0 bg-gradient-to-r from-primary-600 to-primary-700 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          </NuxtLink>
          <NuxtLink 
            to="/login" 
            class="px-5 py-3 md:px-10 md:py-5 bg-white/10 backdrop-blur-md text-white text-sm md:text-base font-bold rounded-xl border-2 border-white/30 hover:bg-white/20 transition-all duration-300 hover:scale-105 hover:-translate-y-1"
          >
            Demo İzle
          </NuxtLink>
        </div>

        <!-- Trust Indicators -->
        <div class="flex flex-wrap justify-center items-center gap-4 md:gap-8 text-gray-400 text-xs md:text-sm">
          <div class="flex items-center gap-1.5 md:gap-2">
            <CheckCircle2 class="w-4 h-4 md:w-5 md:h-5 text-green-400" />
            <span>Kredi kartı gerekmez</span>
          </div>
          <div class="flex items-center gap-1.5 md:gap-2">
            <CheckCircle2 class="w-4 h-4 md:w-5 md:h-5 text-green-400" />
            <span>14 gün ücretsiz deneme</span>
          </div>
          <div class="flex items-center gap-1.5 md:gap-2">
            <CheckCircle2 class="w-4 h-4 md:w-5 md:h-5 text-green-400" />
            <span>İstediğiniz zaman iptal</span>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { Rocket, ArrowRight, CheckCircle2 } from 'lucide-vue-next'
</script>

<style scoped>
.animation-delay-2000 {
  animation-delay: 2s;
}
</style>
