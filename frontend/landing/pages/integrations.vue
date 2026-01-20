<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-indigo-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 py-20">
    <div class="container-custom">
      <!-- Hero Section -->
      <div class="text-center mb-16">
        <h1 class="text-5xl md:text-6xl font-bold text-gray-900 dark:text-white mb-6">
          Entegrasyonlar
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
          Otobia'ni mevcut sistemlerinizle entegre edin ve iş akışınızı optimize edin
        </p>
      </div>

      <!-- Integration Cards -->
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mb-16">
        <!-- Pazar Yerleri -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-8 hover:shadow-xl transition-all border border-gray-200 dark:border-gray-700">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center mb-6">
            <ShoppingBag class="w-8 h-8 text-white" />
          </div>
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-3">Pazar Yerleri</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-4">
            Otomatik ilan aktarımı ile araçlarınızı tüm pazar yerlerine tek tıkla yayınlayın.
          </p>
          <ul class="space-y-2 text-sm text-gray-600 dark:text-gray-400">
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Sahibinden.com
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Otomobil.com
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Arabam.com
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Ve daha fazlası...
            </li>
          </ul>
        </div>

        <!-- ERP Sistemleri -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-8 hover:shadow-xl transition-all border border-gray-200 dark:border-gray-700">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center mb-6">
            <Database class="w-8 h-8 text-white" />
          </div>
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-3">ERP Sistemleri</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-4">
            Mevcut ERP sisteminizle entegre olun, stok yönetimini otomatikleştirin.
          </p>
          <ul class="space-y-2 text-sm text-gray-600 dark:text-gray-400">
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              REST API
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Webhook Desteği
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Gerçek Zamanlı Senkronizasyon
            </li>
          </ul>
        </div>

        <!-- CRM Entegrasyonları -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-8 hover:shadow-xl transition-all border border-gray-200 dark:border-gray-700">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center mb-6">
            <Users class="w-8 h-8 text-white" />
          </div>
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-3">CRM Sistemleri</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-4">
            Müşteri ilişkileri yönetim sistemlerinizle entegre olun.
          </p>
          <ul class="space-y-2 text-sm text-gray-600 dark:text-gray-400">
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Müşteri Verileri
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Teklif Yönetimi
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Otomatik Raporlama
            </li>
          </ul>
        </div>

        <!-- Ödeme Sistemleri -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-8 hover:shadow-xl transition-all border border-gray-200 dark:border-gray-700">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-yellow-500 to-yellow-600 flex items-center justify-center mb-6">
            <CreditCard class="w-8 h-8 text-white" />
          </div>
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-3">Ödeme Sistemleri</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-4">
            Güvenli ödeme entegrasyonları ile abonelik yönetimi.
          </p>
          <ul class="space-y-2 text-sm text-gray-600 dark:text-gray-400">
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              İyzico
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              PayTR
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Stripe
            </li>
          </ul>
        </div>

        <!-- E-posta Servisleri -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-8 hover:shadow-xl transition-all border border-gray-200 dark:border-gray-700">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center mb-6">
            <Mail class="w-8 h-8 text-white" />
          </div>
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-3">E-posta Servisleri</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-4">
            Otomatik e-posta bildirimleri ve pazarlama kampanyaları.
          </p>
          <ul class="space-y-2 text-sm text-gray-600 dark:text-gray-400">
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              SMTP Entegrasyonu
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              SendGrid
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Mailchimp
            </li>
          </ul>
        </div>

        <!-- API & Webhooks -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-8 hover:shadow-xl transition-all border border-gray-200 dark:border-gray-700">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-indigo-500 to-indigo-600 flex items-center justify-center mb-6">
            <Code class="w-8 h-8 text-white" />
          </div>
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-3">API & Webhooks</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-4">
            Kapsamlı API dokümantasyonu ve webhook desteği ile özel entegrasyonlar.
          </p>
          <ul class="space-y-2 text-sm text-gray-600 dark:text-gray-400">
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              RESTful API
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Webhook Desteği
            </li>
            <li class="flex items-center gap-2">
              <Check class="w-4 h-4 text-green-500" />
              Detaylı Dokümantasyon
            </li>
          </ul>
        </div>
      </div>

      <!-- CTA Section -->
      <div class="bg-gradient-to-r from-primary-500 to-primary-600 rounded-3xl p-12 text-center text-white">
        <h2 class="text-3xl md:text-4xl font-bold mb-4">Özel Entegrasyon İhtiyacınız mı Var?</h2>
        <p class="text-xl mb-8 text-primary-100">
          Özel entegrasyon ihtiyaçlarınız için bizimle iletişime geçin
        </p>
        <NuxtLink
          to="/contact"
          class="inline-flex px-8 py-4 bg-white text-primary-600 font-semibold rounded-xl hover:shadow-xl hover:scale-105 transition-all"
        >
          İletişime Geçin
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ShoppingBag, Database, Users, CreditCard, Mail, Code, Check } from 'lucide-vue-next'

useHead({
  title: 'Entegrasyonlar - Otobia',
  meta: [
    { name: 'description', content: 'Otobia entegrasyonları - Pazar yerleri, ERP, CRM ve daha fazlası' }
  ]
})
</script>













