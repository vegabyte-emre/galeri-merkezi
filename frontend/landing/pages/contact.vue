<template>
  <div class="py-12">
    <div class="container-custom">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
          İletişim
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
          Sorularınız, önerileriniz veya destek talepleriniz için bizimle iletişime geçin
        </p>
      </div>

      <div class="grid md:grid-cols-2 gap-12">
        <!-- Contact Form -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-8">
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">Bize Ulaşın</h2>
          <form @submit.prevent="handleSubmit" class="space-y-5">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Ad Soyad *
              </label>
              <input
                v-model="form.name"
                type="text"
                required
                class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                E-posta *
              </label>
              <input
                v-model="form.email"
                type="email"
                required
                class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Telefon
              </label>
              <input
                v-model="form.phone"
                type="tel"
                class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Konu *
              </label>
              <select
                v-model="form.subject"
                required
                class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              >
                <option value="">Seçiniz</option>
                <option value="support">Destek</option>
                <option value="sales">Satış</option>
                <option value="partnership">İş Ortaklığı</option>
                <option value="other">Diğer</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Mesaj *
              </label>
              <textarea
                v-model="form.message"
                rows="5"
                required
                class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              ></textarea>
            </div>
            <button
              type="submit"
              :disabled="loading"
              class="w-full px-6 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ loading ? 'Gönderiliyor...' : 'Gönder' }}
            </button>
          </form>
        </div>

        <!-- Contact Info -->
        <div class="space-y-6">
          <!-- Info Cards -->
          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
            <div class="flex items-start gap-4">
              <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center flex-shrink-0">
                <Mail class="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 class="font-bold text-gray-900 dark:text-white mb-1">E-posta</h3>
                <p class="text-gray-600 dark:text-gray-400">info@galerimerkezi.com</p>
                <p class="text-gray-600 dark:text-gray-400">destek@galerimerkezi.com</p>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
            <div class="flex items-start gap-4">
              <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center flex-shrink-0">
                <Phone class="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 class="font-bold text-gray-900 dark:text-white mb-1">Telefon</h3>
                <p class="text-gray-600 dark:text-gray-400">+90 212 555 0000</p>
                <p class="text-gray-600 dark:text-gray-400">+90 212 555 0001</p>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
            <div class="flex items-start gap-4">
              <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center flex-shrink-0">
                <MapPin class="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 class="font-bold text-gray-900 dark:text-white mb-1">Adres</h3>
                <p class="text-gray-600 dark:text-gray-400">
                  Maslak Mahallesi<br />
                  Büyükdere Caddesi No:123<br />
                  Sarıyer, İstanbul, Türkiye
                </p>
              </div>
            </div>
          </div>

          <!-- Office Hours -->
          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
            <h3 class="font-bold text-gray-900 dark:text-white mb-4">Çalışma Saatleri</h3>
            <div class="space-y-2 text-sm text-gray-600 dark:text-gray-400">
              <div class="flex justify-between">
                <span>Pazartesi - Cuma</span>
                <span class="font-semibold">09:00 - 18:00</span>
              </div>
              <div class="flex justify-between">
                <span>Cumartesi</span>
                <span class="font-semibold">10:00 - 16:00</span>
              </div>
              <div class="flex justify-between">
                <span>Pazar</span>
                <span class="font-semibold">Kapalı</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Mail, Phone, MapPin } from 'lucide-vue-next'
import { reactive, ref } from 'vue'

useHead({
  title: 'İletişim - Galeri Merkezi'
})

const loading = ref(false)

const form = reactive({
  name: '',
  email: '',
  phone: '',
  subject: '',
  message: ''
})

const handleSubmit = async () => {
  loading.value = true
  try {
    const api = useApi()
    await api.post('/contact', form)
    success.value = true
    form.name = ''
    form.email = ''
    form.phone = ''
    form.subject = ''
    form.message = ''
  } catch (error: any) {
    errors.message = error.message || 'Mesaj gönderilemedi'
  } finally {
    loading.value = false
  }
}
</script>

