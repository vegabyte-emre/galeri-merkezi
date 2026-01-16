<template>
  <div class="min-h-[80vh] flex items-center justify-center py-12 px-4">
    <div class="max-w-md w-full">
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-700 p-8">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center mx-auto mb-4 shadow-lg">
            <Lock class="w-8 h-8 text-white" />
          </div>
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            Yeni Şifre Belirle
          </h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Güvenli bir şifre oluşturun
          </p>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleSubmit" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Yeni Şifre *
            </label>
            <input
              v-model="form.password"
              type="password"
              required
              placeholder="En az 8 karakter"
              class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              :class="{ 'border-red-500': errors.password }"
            />
            <p v-if="errors.password" class="mt-1 text-sm text-red-600 dark:text-red-400">{{ errors.password }}</p>
            <div class="mt-2 space-y-1">
              <div class="flex items-center gap-2 text-xs" :class="passwordStrength.length ? 'text-green-600 dark:text-green-400' : 'text-gray-500 dark:text-gray-400'">
                <CheckCircle v-if="passwordStrength.length" class="w-3 h-3" />
                <X v-else class="w-3 h-3" />
                En az 8 karakter
              </div>
              <div class="flex items-center gap-2 text-xs" :class="passwordStrength.uppercase ? 'text-green-600 dark:text-green-400' : 'text-gray-500 dark:text-gray-400'">
                <CheckCircle v-if="passwordStrength.uppercase" class="w-3 h-3" />
                <X v-else class="w-3 h-3" />
                Büyük harf içermeli
              </div>
              <div class="flex items-center gap-2 text-xs" :class="passwordStrength.number ? 'text-green-600 dark:text-green-400' : 'text-gray-500 dark:text-gray-400'">
                <CheckCircle v-if="passwordStrength.number" class="w-3 h-3" />
                <X v-else class="w-3 h-3" />
                Rakam içermeli
              </div>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Şifre Tekrar *
            </label>
            <input
              v-model="form.confirmPassword"
              type="password"
              required
              placeholder="Şifrenizi tekrar girin"
              class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              :class="{ 'border-red-500': errors.confirmPassword }"
            />
            <p v-if="errors.confirmPassword" class="mt-1 text-sm text-red-600 dark:text-red-400">{{ errors.confirmPassword }}</p>
          </div>

          <button
            type="submit"
            :disabled="loading || !isFormValid"
            class="w-full px-4 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? 'Kaydediliyor...' : 'Şifreyi Güncelle' }}
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
                Şifre başarıyla güncellendi!
              </p>
              <NuxtLink
                to="/login"
                class="text-sm text-green-700 dark:text-green-400 hover:underline mt-1 inline-block"
              >
                Giriş sayfasına dön →
              </NuxtLink>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Lock, CheckCircle, X } from 'lucide-vue-next'
import { reactive, ref, computed } from 'vue'

useHead({
  title: 'Şifre Sıfırla - Galeri Merkezi'
})

const form = reactive({
  password: '',
  confirmPassword: ''
})

const errors = reactive({
  password: '',
  confirmPassword: ''
})

const loading = ref(false)
const success = ref(false)

const passwordStrength = computed(() => {
  const password = form.password
  return {
    length: password.length >= 8,
    uppercase: /[A-Z]/.test(password),
    number: /[0-9]/.test(password)
  }
})

const isFormValid = computed(() => {
  return form.password.length >= 8 &&
         passwordStrength.value.uppercase &&
         passwordStrength.value.number &&
         form.password === form.confirmPassword
})

const handleSubmit = async () => {
  errors.password = ''
  errors.confirmPassword = ''

  if (form.password.length < 8) {
    errors.password = 'Şifre en az 8 karakter olmalıdır'
    return
  }

  if (!passwordStrength.value.uppercase) {
    errors.password = 'Şifre en az bir büyük harf içermelidir'
    return
  }

  if (!passwordStrength.value.number) {
    errors.password = 'Şifre en az bir rakam içermelidir'
    return
  }

  if (form.password !== form.confirmPassword) {
    errors.confirmPassword = 'Şifreler eşleşmiyor'
    return
  }

  loading.value = true
  try {
    const route = useRoute()
    const token = route.query.token as string
    
    if (!token) {
      throw new Error('Geçersiz veya eksik token')
    }
    
    const api = useApi()
    await api.post('/auth/reset-password', {
      token,
      password: form.password,
      confirmPassword: form.confirmPassword
    })
    
    success.value = true
  } catch (error: any) {
    errors.password = error.message || 'Bir hata oluştu'
  } finally {
    loading.value = false
  }
}
</script>

