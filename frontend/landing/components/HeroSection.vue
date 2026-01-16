<template>
  <section class="relative min-h-[90vh] flex items-center justify-center overflow-hidden bg-gradient-to-br from-primary-600 via-primary-700 to-primary-900">
    <!-- Animated Background Elements -->
    <div class="absolute inset-0 overflow-hidden">
      <div class="absolute -top-40 -right-40 w-80 h-80 bg-primary-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob"></div>
      <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-purple-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-2000"></div>
      <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-80 h-80 bg-pink-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-4000"></div>
    </div>

    <!-- Grid Pattern Overlay -->
    <div class="absolute inset-0 bg-grid-pattern opacity-10"></div>

    <div class="container-custom relative z-10">
      <div class="max-w-4xl mx-auto text-center">
        <!-- Badge -->
        <div class="inline-flex items-center gap-2 px-4 py-2 mb-8 bg-white/10 backdrop-blur-md rounded-full border border-white/20 animate-fade-in">
          <span class="w-2 h-2 bg-green-400 rounded-full animate-pulse"></span>
          <span class="text-sm font-medium text-white/90">500+ Aktif Galeri</span>
        </div>

        <!-- Main Heading -->
        <h1 class="text-5xl md:text-7xl font-bold mb-6 text-white leading-tight animate-slide-up">
          <span class="block">Oto Galerilerini</span>
          <span class="block bg-gradient-to-r from-yellow-300 to-orange-300 bg-clip-text text-transparent">
            Birleştiren Platform
          </span>
        </h1>

        <!-- Subtitle -->
        <p class="text-xl md:text-2xl mb-10 text-primary-100 max-w-2xl mx-auto leading-relaxed animate-slide-up animation-delay-200">
          Stok yönetimi, galeriler arası teklif/pazarlık ve pazar yerlerine otomatik ilan aktarımı ile işinizi büyütün
        </p>

        <!-- CTA Buttons -->
        <div class="flex flex-col sm:flex-row gap-4 justify-center items-center animate-slide-up animation-delay-400">
          <NuxtLink 
            to="/register" 
            class="group relative px-8 py-4 bg-white text-primary-700 font-semibold rounded-xl shadow-2xl hover:shadow-white/20 transition-all duration-300 hover:scale-105 hover:-translate-y-1"
          >
            <span class="relative z-10">Hemen Başla</span>
            <div class="absolute inset-0 bg-gradient-to-r from-white to-primary-50 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          </NuxtLink>
          <NuxtLink 
            to="/login" 
            class="px-8 py-4 bg-white/10 backdrop-blur-md text-white font-semibold rounded-xl border-2 border-white/30 hover:bg-white/20 transition-all duration-300 hover:scale-105 hover:-translate-y-1"
          >
            Giriş Yap
          </NuxtLink>
        </div>

        <!-- Trust Indicators -->
        <div class="mt-16 flex flex-wrap justify-center items-center gap-8 text-white/80 animate-fade-in animation-delay-600">
          <div class="flex items-center gap-2">
            <CheckCircle class="w-5 h-5 text-green-300" />
            <span class="text-sm">Ücretsiz Başlangıç</span>
          </div>
          <div class="flex items-center gap-2">
            <Shield class="w-5 h-5 text-blue-300" />
            <span class="text-sm">Güvenli Platform</span>
          </div>
          <div class="flex items-center gap-2">
            <Zap class="w-5 h-5 text-yellow-300" />
            <span class="text-sm">Hızlı Kurulum</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Scroll Indicator -->
    <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
      <ChevronDown class="w-6 h-6 text-white/60" />
    </div>
  </section>
</template>

<script setup lang="ts">
import { CheckCircle, Shield, Zap, ChevronDown } from 'lucide-vue-next'
</script>

<style scoped>
@keyframes blob {
  0%, 100% {
    transform: translate(0, 0) scale(1);
  }
  33% {
    transform: translate(30px, -50px) scale(1.1);
  }
  66% {
    transform: translate(-20px, 20px) scale(0.9);
  }
}

.animate-blob {
  animation: blob 7s infinite;
}

.animation-delay-2000 {
  animation-delay: 2s;
}

.animation-delay-4000 {
  animation-delay: 4s;
}

.animation-delay-200 {
  animation-delay: 200ms;
}

.animation-delay-400 {
  animation-delay: 400ms;
}

.animation-delay-600 {
  animation-delay: 600ms;
}

@keyframes fade-in {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.animate-fade-in {
  animation: fade-in 0.8s ease-out;
}

@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-slide-up {
  animation: slide-up 0.8s ease-out;
}

.bg-grid-pattern {
  background-image: 
    linear-gradient(to right, rgba(255,255,255,0.1) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(255,255,255,0.1) 1px, transparent 1px);
  background-size: 50px 50px;
}
</style>
