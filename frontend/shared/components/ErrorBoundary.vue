<template>
  <div v-if="hasError" class="min-h-screen flex items-center justify-center p-4">
    <div class="max-w-md w-full text-center">
      <div class="w-16 h-16 rounded-full bg-red-100 dark:bg-red-900/30 flex items-center justify-center mx-auto mb-4">
        <AlertCircle class="w-8 h-8 text-red-600 dark:text-red-400" />
      </div>
      <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
        Bir Hata Oluştu
      </h2>
      <p class="text-gray-600 dark:text-gray-400 mb-6">
        {{ errorMessage }}
      </p>
      <div class="flex items-center justify-center gap-3">
        <button
          @click="resetError"
          class="px-6 py-3 bg-primary-500 text-white font-semibold rounded-lg hover:bg-primary-600 transition-colors"
        >
          Tekrar Dene
        </button>
        <button
          @click="goHome"
          class="px-6 py-3 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 font-semibold rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
        >
          Ana Sayfaya Dön
        </button>
      </div>
    </div>
  </div>
  <slot v-else />
</template>

<script setup lang="ts">
import { AlertCircle } from 'lucide-vue-next'
import { ref, onErrorCaptured } from 'vue'

const hasError = ref(false)
const errorMessage = ref('Beklenmeyen bir hata oluştu.')

onErrorCaptured((err: Error) => {
  hasError.value = true
  errorMessage.value = err.message || 'Beklenmeyen bir hata oluştu.'
  console.error('Error caught by boundary:', err)
  return false
})

const resetError = () => {
  hasError.value = false
  errorMessage.value = 'Beklenmeyen bir hata oluştu.'
  window.location.reload()
}

const goHome = () => {
  window.location.href = '/'
}
</script>














