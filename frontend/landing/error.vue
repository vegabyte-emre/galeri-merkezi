<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-primary-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 py-12 px-4">
    <div class="max-w-2xl w-full text-center">
      <!-- Error Code -->
      <div class="mb-8">
        <h1 class="text-9xl font-bold text-primary-600 dark:text-primary-400 mb-4">
          {{ error.statusCode || '404' }}
        </h1>
        <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">
          {{ error.statusCode === 404 ? 'Sayfa Bulunamadı' : 'Bir Hata Oluştu' }}
        </h2>
        <p class="text-lg text-gray-600 dark:text-gray-400 mb-8">
          {{ error.statusCode === 404 
            ? 'Aradığınız sayfa mevcut değil veya taşınmış olabilir.' 
            : 'Bir şeyler ters gitti. Lütfen daha sonra tekrar deneyin.' }}
        </p>
      </div>

      <!-- Illustration -->
      <div class="mb-8 flex justify-center">
        <div class="w-64 h-64 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center opacity-20">
          <AlertCircle class="w-32 h-32 text-white" />
        </div>
      </div>

      <!-- Actions -->
      <div class="flex items-center justify-center gap-4">
        <button
          @click="goHome"
          class="px-6 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          Ana Sayfaya Dön
        </button>
        <button
          @click="goBack"
          class="px-6 py-3 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 font-semibold rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
        >
          Geri Git
        </button>
      </div>

      <!-- Helpful Links -->
      <div class="mt-12 pt-8 border-t border-gray-200 dark:border-gray-700">
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">Faydalı Linkler:</p>
        <div class="flex items-center justify-center gap-6 flex-wrap">
          <NuxtLink to="/" class="text-primary-600 dark:text-primary-400 hover:underline">Ana Sayfa</NuxtLink>
          <NuxtLink to="/search" class="text-primary-600 dark:text-primary-400 hover:underline">Araç Ara</NuxtLink>
          <NuxtLink to="/about" class="text-primary-600 dark:text-primary-400 hover:underline">Hakkımızda</NuxtLink>
          <NuxtLink to="/contact" class="text-primary-600 dark:text-primary-400 hover:underline">İletişim</NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { AlertCircle } from 'lucide-vue-next'

const props = defineProps({
  error: {
    type: Object,
    required: true
  }
})

const goHome = () => {
  navigateTo('/')
}

const goBack = () => {
  window.history.back()
}
</script>














