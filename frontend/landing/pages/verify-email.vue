<template>
  <div class="min-h-[80vh] flex items-center justify-center py-12 px-4">
    <div class="max-w-md w-full">
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-700 p-8 text-center">
        <!-- Success State -->
        <div v-if="verified">
          <div class="w-16 h-16 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center mx-auto mb-4">
            <CheckCircle class="w-8 h-8 text-green-600 dark:text-green-400" />
          </div>
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            E-posta Doğrulandı!
          </h2>
          <p class="text-gray-600 dark:text-gray-400 mb-6">
            Hesabınız başarıyla doğrulandı. Artık platformu kullanmaya başlayabilirsiniz.
          </p>
          <NuxtLink
            to="/login"
            class="inline-block px-6 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Giriş Yap
          </NuxtLink>
        </div>

        <!-- Verification State -->
        <div v-else>
          <div class="w-16 h-16 rounded-full bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center mx-auto mb-4">
            <Mail class="w-8 h-8 text-primary-600 dark:text-primary-400" />
          </div>
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            E-posta Doğrulama
          </h2>
          <p class="text-gray-600 dark:text-gray-400 mb-6">
            E-posta adresinize doğrulama linki gönderdik. Lütfen e-posta kutunuzu kontrol edin.
          </p>
          <div class="space-y-4">
            <button
              @click="resendEmail"
              :disabled="resending"
              class="w-full px-4 py-3 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 font-semibold rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ resending ? 'Gönderiliyor...' : 'Linki Tekrar Gönder' }}
            </button>
            <NuxtLink
              to="/login"
              class="block text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300"
            >
              Giriş sayfasına dön
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Mail, CheckCircle } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

useHead({
  title: 'E-posta Doğrulama - Otobia'
})

const route = useRoute()
const verified = ref(false)
const resending = ref(false)

onMounted(() => {
  // Check if token exists in URL
  const token = route.query.token as string
  if (token) {
    verifyEmail(token)
  }
})

const verifyEmail = async (token: string) => {
  try {
    const api = useApi()
    await api.post('/auth/verify-email', { token })
    verified.value = true
  } catch (error: any) {
    alert('Doğrulama başarısız: ' + error.message)
  }
}

const resendEmail = async () => {
  resending.value = true
  try {
    const route = useRoute()
    const email = route.query.email as string
    
    const api = useApi()
    await api.post('/auth/resend-verification', { email })
    alert('Doğrulama linki tekrar gönderildi!')
  } catch (error: any) {
    alert('Hata: ' + error.message)
  } finally {
    resending.value = false
  }
}
</script>

