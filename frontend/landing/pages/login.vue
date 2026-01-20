<template>
  <div class="min-h-[80vh] flex items-center justify-center py-12 px-4">
    <div class="max-w-md w-full">
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-700 p-8">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center mx-auto mb-4 shadow-lg">
            <Car class="w-8 h-8 text-white" />
          </div>
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            Hesabiniza Giris Yapin
          </h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Otobia platformuna hos geldiniz
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
              Sifre
            </label>
            <input
              v-model="form.password"
              type="password"
              placeholder="Sifrenizi girin"
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
              <span class="text-sm text-gray-600 dark:text-gray-400">Beni hatirla</span>
            </label>
            <NuxtLink
              to="/forgot-password"
              class="text-sm font-medium text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300"
            >
              Sifremi Unuttum
            </NuxtLink>
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full px-4 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? 'Giris yapiliyor...' : 'Giris Yap' }}
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
            Hesabiniz yok mu?
            <NuxtLink
              to="/register"
              class="font-semibold text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300"
            >
              Kayit Olun
            </NuxtLink>
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

useHead({
  title: 'Giris Yap - Otobia'
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

const handleLogin = async () => {
  errors.identifier = ''
  errors.password = ''

  if (!form.identifier) {
    errors.identifier = 'Email veya telefon numarasi gereklidir'
    return
  }

  if (!form.password) {
    errors.password = 'Sifre gereklidir'
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
      
      const user = useCookie('user')
      user.value = response.user
      
      // Redirect to panel
      window.location.href = 'http://localhost:3002'
    } else {
      throw new Error('Giris basarisiz')
    }
  } catch (error: any) {
    console.error('Login error:', error)
    errors.password = error.message || 'Giris basarisiz. Lutfen bilgilerinizi kontrol edin.'
  } finally {
    loading.value = false
  }
}
</script>
