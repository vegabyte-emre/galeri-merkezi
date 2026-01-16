<template>
  <div class="py-12">
    <div class="container-custom">
      <!-- Header -->
      <div class="text-center mb-16">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
          Fiyatlandırma
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
          İhtiyacınıza uygun planı seçin. Tüm planlarda 14 gün ücretsiz deneme
        </p>
      </div>

      <!-- Pricing Cards -->
      <div class="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto mb-16">
        <div
          v-for="(plan, index) in plans"
          :key="plan.name"
          class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border-2 p-8 relative"
          :class="plan.featured 
            ? 'border-primary-500 scale-105' 
            : 'border-gray-200 dark:border-gray-700'"
        >
          <div v-if="plan.featured" class="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
            <span class="px-4 py-1 bg-gradient-to-r from-primary-500 to-primary-600 text-white text-sm font-semibold rounded-full">
              Popüler
            </span>
          </div>

          <div class="text-center mb-8">
            <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">{{ plan.name }}</h3>
            <p class="text-gray-600 dark:text-gray-400 mb-6">{{ plan.description }}</p>
            <div class="mb-4">
              <span class="text-5xl font-bold text-gray-900 dark:text-white">{{ plan.price }}</span>
              <span class="text-gray-600 dark:text-gray-400">₺/ay</span>
            </div>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ plan.billing }}</p>
          </div>

          <ul class="space-y-4 mb-8">
            <li
              v-for="feature in plan.features"
              :key="feature"
              class="flex items-start gap-3"
            >
              <Check class="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
              <span class="text-gray-700 dark:text-gray-300">{{ feature }}</span>
            </li>
          </ul>

          <button
            class="w-full px-6 py-3 rounded-lg font-semibold transition-all"
            :class="plan.featured
              ? 'bg-gradient-to-r from-primary-500 to-primary-600 text-white hover:shadow-lg'
              : 'bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white hover:bg-gray-200 dark:hover:bg-gray-600'"
          >
            {{ plan.featured ? 'Hemen Başla' : 'Planı Seç' }}
          </button>
        </div>
      </div>

      <!-- FAQ Section -->
      <div class="max-w-3xl mx-auto">
        <h2 class="text-3xl font-bold text-gray-900 dark:text-white text-center mb-12">
          Sık Sorulan Sorular
        </h2>
        <div class="space-y-4">
          <div
            v-for="(faq, index) in faqs"
            :key="index"
            class="bg-white dark:bg-gray-800 rounded-xl shadow-lg border border-gray-200 dark:border-gray-700 p-6"
          >
            <h3 class="font-bold text-gray-900 dark:text-white mb-2">{{ faq.question }}</h3>
            <p class="text-gray-600 dark:text-gray-400">{{ faq.answer }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Check } from 'lucide-vue-next'

useHead({
  title: 'Fiyatlandırma - Galeri Merkezi'
})

const plans = [
  {
    name: 'Başlangıç',
    description: 'Küçük galeriler için',
    price: '499',
    billing: 'Aylık ödeme',
    featured: false,
    features: [
      '50 araç yükleme',
      'Temel stok yönetimi',
      'E-posta desteği',
      'Temel raporlar',
      '1 kanal bağlantısı'
    ]
  },
  {
    name: 'Profesyonel',
    description: 'Büyüyen galeriler için',
    price: '999',
    billing: 'Aylık ödeme',
    featured: true,
    features: [
      'Sınırsız araç yükleme',
      'Gelişmiş stok yönetimi',
      'Öncelikli destek',
      'Detaylı analitik',
      'Tüm kanal bağlantıları',
      'API erişimi',
      'Özel entegrasyonlar'
    ]
  },
  {
    name: 'Kurumsal',
    description: 'Büyük galeriler için',
    price: 'Özel',
    billing: 'Özel fiyatlandırma',
    featured: false,
    features: [
      'Sınırsız araç yükleme',
      'Gelişmiş stok yönetimi',
      '7/24 öncelikli destek',
      'Özel analitik dashboard',
      'Tüm kanal bağlantıları',
      'API erişimi',
      'Özel entegrasyonlar',
      'Dedike hesap yöneticisi',
      'Özel eğitim ve danışmanlık'
    ]
  }
]

const faqs = [
  {
    question: '14 günlük deneme süresi ücretsiz mi?',
    answer: 'Evet, tüm planlarda 14 gün ücretsiz deneme süresi vardır. Kredi kartı bilgisi gerektirmez.'
  },
  {
    question: 'Plan değiştirebilir miyim?',
    answer: 'Evet, istediğiniz zaman planınızı yükseltebilir veya düşürebilirsiniz. Değişiklikler anında geçerli olur.'
  },
  {
    question: 'İptal edebilir miyim?',
    answer: 'Evet, istediğiniz zaman iptal edebilirsiniz. İptal işlemi sonrası hesabınız dönem sonuna kadar aktif kalır.'
  },
  {
    question: 'Hangi ödeme yöntemlerini kabul ediyorsunuz?',
    answer: 'Kredi kartı, banka kartı ve havale/EFT ile ödeme yapabilirsiniz.'
  }
]
</script>

