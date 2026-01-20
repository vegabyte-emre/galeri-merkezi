<template>
  <div class="min-h-[80vh] flex items-center justify-center py-12 px-4">
    <div class="max-w-md w-full">
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-700 p-8">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center mx-auto mb-4 shadow-lg">
            <Key class="w-8 h-8 text-white" />
          </div>
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            Şifremi Unuttum
          </h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            E-posta adresinize şifre sıfırlama linki göndereceğiz
          </p>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleSubmit" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              E-posta veya Telefon
            </label>
            <input
              v-model="form.identifier"
              type="text"
              placeholder="E-posta veya telefon numaranız"
              required
              class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              :class="{ 'border-red-500': errors.identifier }"
            />
            <p v-if="errors.identifier" class="mt-1 text-sm text-red-600 dark:text-red-400">{{ errors.identifier }}</p>
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full px-4 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? 'Gönderiliyor...' : 'Şifre Sıfırlama Linki Gönder' }}
          </button>
        </form>

        <!-- Success Message -->
        <div
          v-if="success"
          class="mt-6 p-4 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-800 rounded-lg"
        >
          <div class="flex items-start gap-3">
            <CheckCircle class="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0 mt-0.5" />
            <div>
              <p class="text-sm font-medium text-green-800 dark:text-green-300">
                Şifre sıfırlama linki gönderildi!
              </p>
              <p class="text-sm text-green-700 dark:text-green-400 mt-1">
                E-posta kutunuzu kontrol edin. Link 24 saat geçerlidir.
              </p>
            </div>
          </div>
        </div>

        <!-- Back to Login -->
        <div class="mt-6 text-center">
          <NuxtLink
            to="/login"
            class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300"
          >
            ← Giriş sayfasına dön
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Key, CheckCircle } from 'lucide-vue-next'
import { reactive, ref } from 'vue'

useHead({
  title: 'Şifremi Unuttum - Otobia'
})

const form = reactive({
  identifier: ''
})

const errors = reactive({
  identifier: ''
})

const loading = ref(false)
const success = ref(false)

const handleSubmit = async () => {
  errors.identifier = ''

  if (!form.identifier) {
    errors.identifier = 'E-posta veya telefon gereklidir'
    return
  }

  loading.value = true
  try {
    const api = useApi()
    await api.post('/auth/forgot-password', {
      identifier: form.identifier
    })
    success.value = true
  } catch (error: any) {
    errors.identifier = error.message || 'Bir hata oluştu'
  } finally {
    loading.value = false
  }
}
</script>

