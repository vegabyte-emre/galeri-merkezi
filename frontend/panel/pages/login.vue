<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 py-12 px-4">
    <div class="max-w-md w-full">
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-700 p-8">
        <!-- Header -->
        <div class="text-center mb-8">
          <img 
            src="/otobia-logo.svg" 
            alt="Otobia" 
            class="h-10 w-auto mx-auto mb-4 dark:invert"
          />
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            Galeri Paneline Giriş
          </h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Hesabınıza giriş yapın
          </p>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleLogin" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Email veya Telefon
            </label>
            <input
              v-model="form.identifier"
              type="text"
              placeholder="ornek@galeri.com veya +905551234567"
              class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              :class="{ 'border-red-500': errors.identifier }"
            />
            <p v-if="errors.identifier" class="mt-1 text-sm text-red-600 dark:text-red-400">{{ errors.identifier }}</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Şifre
            </label>
            <input
              v-model="form.password"
              type="password"
              placeholder="Şifrenizi girin"
              class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              :class="{ 'border-red-500': errors.password }"
            />
            <p v-if="errors.password" class="mt-1 text-sm text-red-600 dark:text-red-400">{{ errors.password }}</p>
          </div>

          <div class="flex items-center justify-between">
            <label class="flex items-center gap-2">
              <input
                v-model="rememberMe"
                type="checkbox"
                class="w-4 h-4 text-primary-600 rounded"
              />
              <span class="text-sm text-gray-600 dark:text-gray-400">Beni hatırla</span>
            </label>
            <NuxtLink
              to="/forgot-password"
              class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300"
            >
              Şifremi Unuttum
            </NuxtLink>
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full px-4 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? 'Giriş yapılıyor...' : 'Giriş Yap' }}
          </button>
        </form>

        <!-- Divider -->
        <div class="my-6 flex items-center">
          <div class="flex-1 border-t border-gray-300 dark:border-gray-600"></div>
          <span class="px-4 text-sm text-gray-500 dark:text-gray-400">veya</span>
          <div class="flex-1 border-t border-gray-300 dark:border-gray-600"></div>
        </div>

        <!-- Register Link -->
        <div class="text-center">
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Hesabınız yok mu?
            <a
              href="/register"
              class="font-semibold text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300"
            >
              Kayıt Olun
            </a>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Car } from 'lucide-vue-next'
import { reactive, ref } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

definePageMeta({
  middleware: [],
  layout: false
})

useHead({
  title: 'Giriş Yap - Galeri Paneli'
})

const api = useApi()
const form = reactive({
  identifier: '',
  password: ''
})

const errors = reactive({
  identifier: '',
  password: ''
})

const loading = ref(false)
const rememberMe = ref(false)
const toast = useToast()

const handleLogin = async () => {
  errors.identifier = ''
  errors.password = ''

  if (!form.identifier) {
    errors.identifier = 'Email veya telefon numarası gereklidir'
    return
  }

  if (!form.password) {
    errors.password = 'Şifre gereklidir'
    return
  }

  loading.value = true
  try {
    const isEmail = form.identifier.includes('@')
    
    const response = await api.post<{ success: boolean; accessToken: string; refreshToken: string; user: any }>('/auth/login', {
      phone: !isEmail ? form.identifier : undefined,
      email: isEmail ? form.identifier : undefined,
      password: form.password
    })
    
    if (response.success && response.accessToken) {
      const token = useCookie('auth_token')
      token.value = response.accessToken
      
      // Store user as JSON string to avoid "[object Object]" cookie issues
      const user = useCookie<string>('user')
      user.value = JSON.stringify(response.user)
      
      toast.success('Giriş başarılı!')
      // Full reload prevents a blank screen on first navigation after login
      window.location.href = '/'
    } else {
      throw new Error('Giriş başarısız')
    }
  } catch (error: any) {
    console.error('Login error:', error)
    const errorMessage = error.message || 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.'
    errors.password = errorMessage
    toast.error(errorMessage)
  } finally {
    loading.value = false
  }
}
</script>
