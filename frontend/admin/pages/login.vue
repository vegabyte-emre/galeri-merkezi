<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <!-- Logo -->
      <div class="text-center mb-8">
        <img 
          src="/otobia-logo.svg" 
          alt="Otobia" 
          class="h-10 w-auto mx-auto mb-4 invert"
        />
        <p class="text-gray-400 text-sm mt-1">Süperadmin Paneli</p>
      </div>

      <!-- Login Card -->
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8">
        <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-6">Giriş Yap</h2>
        
        <form @submit.prevent="handleLogin" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Email
            </label>
            <input
              v-model="form.email"
              type="email"
              placeholder="admin@otobia.com"
              class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              :class="{ 'border-red-500': errors.email }"
            />
            <p v-if="errors.email" class="mt-1 text-sm text-red-600">{{ errors.email }}</p>
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
            <p v-if="errors.password" class="mt-1 text-sm text-red-600">{{ errors.password }}</p>
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg shadow-lg hover:shadow-xl transition-all disabled:opacity-50"
          >
            {{ loading ? 'Giriş yapılıyor...' : 'Giriş Yap' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Shield } from 'lucide-vue-next'
import { ref, reactive } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

definePageMeta({
  layout: false
})

useHead({
  title: 'Giriş Yap - Süperadmin Paneli'
})

const api = useApi()
const toast = useToast()

const form = reactive({
  email: '',
  password: ''
})

const errors = reactive({
  email: '',
  password: ''
})

const loading = ref(false)

const handleLogin = async () => {
  errors.email = ''
  errors.password = ''

  if (!form.email) {
    errors.email = 'Email gereklidir'
    return
  }

  if (!form.password) {
    errors.password = 'Şifre gereklidir'
    return
  }

  loading.value = true
  try {
    const response = await api.post<{ success: boolean; accessToken: string; user: any }>('/api/v1/auth/login', {
      email: form.email,
      password: form.password
    })
    
    if (response.success && response.accessToken) {
      // Check if user is superadmin
      if (response.user?.role !== 'superadmin') {
        throw new Error('Bu panele sadece süperadmin erişebilir')
      }
      
      const token = useCookie('auth_token')
      token.value = response.accessToken
      
      const user = useCookie('user')
      user.value = response.user
      
      toast.success('Giriş başarılı!')
      await navigateTo('/')
    } else {
      throw new Error('Giriş başarısız')
    }
  } catch (error: any) {
    console.error('Login error:', error)
    errors.password = error.message || 'Giriş başarısız. Bilgilerinizi kontrol edin.'
    toast.error(errors.password)
  } finally {
    loading.value = false
  }
}
</script>
