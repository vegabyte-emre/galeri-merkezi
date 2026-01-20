<template>
  <div class="py-12">
    <div class="container-custom">
      <!-- Hero Section -->
      <div class="text-center mb-16">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
          Kurumsal
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
          Oto galerilerini birleştiren, işinizi büyüten B2B platform
        </p>
      </div>

      <!-- Mission Section -->
      <div class="grid md:grid-cols-2 gap-12 mb-16">
        <div>
          <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">Misyonumuz</h2>
          <p class="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
            Otobia olarak, Türkiye'deki oto galerilerini dijital bir platformda birleştirerek, 
            sektördeki verimliliği artırmayı ve iş süreçlerini kolaylaştırmayı hedefliyoruz.
          </p>
          <p class="text-gray-600 dark:text-gray-400 leading-relaxed">
            Modern teknoloji ile geleneksel otomotiv sektörünü buluşturarak, galeriler arası 
            iletişimi güçlendiriyor ve pazar yerlerine otomatik ilan aktarımı ile zaman tasarrufu sağlıyoruz.
          </p>
        </div>
        <div>
          <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">Vizyonumuz</h2>
          <p class="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
            Türkiye'nin en büyük B2B oto galeri platformu olmak ve sektörde dijital dönüşümün 
            öncüsü olmak vizyonumuzdur.
          </p>
          <p class="text-gray-600 dark:text-gray-400 leading-relaxed">
            AI destekli eşleştirme sistemleri, gelişmiş analitik araçlar ve güvenli işlem 
            altyapısı ile sektörün geleceğini şekillendiriyoruz.
          </p>
        </div>
      </div>

      <!-- Values Section -->
      <div class="mb-16">
        <h2 class="text-3xl font-bold text-gray-900 dark:text-white text-center mb-12">Değerlerimiz</h2>
        <div class="grid md:grid-cols-3 gap-8">
          <div
            v-for="value in values"
            :key="value.title"
            class="bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-lg border border-gray-200 dark:border-gray-700 text-center"
          >
            <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center mx-auto mb-4">
              <component :is="value.icon" class="w-8 h-8 text-white" />
            </div>
            <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">{{ value.title }}</h3>
            <p class="text-gray-600 dark:text-gray-400">{{ value.description }}</p>
          </div>
        </div>
      </div>

      <!-- Team Section -->
      <div class="mb-16">
        <h2 class="text-3xl font-bold text-gray-900 dark:text-white text-center mb-12">Ekibimiz</h2>
        <div class="grid md:grid-cols-4 gap-8">
          <div
            v-for="member in team"
            :key="member.name"
            class="text-center"
          >
            <div class="w-24 h-24 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white text-2xl font-bold mx-auto mb-4">
              {{ member.name.charAt(0) }}
            </div>
            <h3 class="font-bold text-gray-900 dark:text-white mb-1">{{ member.name }}</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ member.role }}</p>
          </div>
        </div>
      </div>

      <!-- Stats Section -->
      <div class="bg-gradient-to-br from-primary-600 to-primary-800 rounded-2xl p-12 text-white text-center">
        <div class="grid md:grid-cols-4 gap-8">
          <div
            v-for="stat in stats"
            :key="stat.label"
          >
            <div class="text-4xl font-bold mb-2">{{ stat.value }}</div>
            <div class="text-primary-100">{{ stat.label }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Shield, Zap, Heart } from 'lucide-vue-next'

useHead({
  title: 'Hakkımızda - Otobia'
})

const values = [
  {
    icon: Shield,
    title: 'Güvenlik',
    description: 'Verilerinizin güvenliği bizim önceliğimizdir. Endüstri standardı güvenlik önlemleri ile korunursunuz.'
  },
  {
    icon: Zap,
    title: 'Hız',
    description: 'Hızlı işlem süreçleri ve anında bildirimler ile zaman kaybetmeden işinizi yürütün.'
  },
  {
    icon: Heart,
    title: 'Müşteri Odaklılık',
    description: 'Kullanıcı deneyimini sürekli iyileştirerek, ihtiyaçlarınıza en iyi şekilde hizmet ediyoruz.'
  }
]

const team = [
  { name: 'Ahmet Yılmaz', role: 'CEO & Kurucu' },
  { name: 'Mehmet Demir', role: 'CTO' },
  { name: 'Ayşe Kaya', role: 'Product Manager' },
  { name: 'Fatma Şahin', role: 'Lead Developer' }
]

const stats = [
  { value: '500+', label: 'Aktif Galeri' },
  { value: '10K+', label: 'Araç' },
  { value: '5K+', label: 'Aylık Teklif' },
  { value: '99%', label: 'Memnuniyet' }
]
</script>


