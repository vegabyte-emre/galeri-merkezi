<template>
  <section class="py-24 bg-gradient-to-b from-white to-gray-50 relative overflow-hidden">
    <!-- Background Decoration -->
    <div class="absolute top-0 left-0 w-full h-full opacity-5">
      <div class="absolute top-20 left-10 w-72 h-72 bg-primary-300 rounded-full blur-3xl"></div>
      <div class="absolute bottom-20 right-10 w-96 h-96 bg-purple-300 rounded-full blur-3xl"></div>
    </div>

    <div class="container-custom relative z-10">
      <!-- Section Header -->
      <div class="text-center mb-16">
        <div class="inline-flex items-center gap-2 px-4 py-2 mb-4 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold">
          <Sparkles class="w-4 h-4" />
          Özellikler
        </div>
        <h2 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
          İşinizi <span class="text-primary-600">Kolaylaştıran</span> Özellikler
        </h2>
        <p class="text-xl text-gray-600 max-w-2xl mx-auto">
          Modern araçlarla galeri işletmenizi bir üst seviyeye taşıyın
        </p>
      </div>

      <!-- Features Grid -->
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div
          v-for="(feature, index) in features"
          :key="feature.title"
          class="group relative bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 border border-gray-100"
          :style="{ animationDelay: `${index * 100}ms` }"
        >
          <!-- Icon Background -->
          <div class="absolute top-0 right-0 w-32 h-32 bg-gradient-to-br from-primary-100 to-primary-50 rounded-bl-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          
          <!-- Icon -->
          <div class="relative mb-6">
            <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center text-white shadow-lg group-hover:scale-110 transition-transform duration-300">
              <component :is="feature.icon" class="w-7 h-7" />
            </div>
          </div>

          <!-- Content -->
          <h3 class="text-xl font-bold text-gray-900 mb-3 group-hover:text-primary-600 transition-colors">
            {{ feature.title }}
          </h3>
          <p class="text-gray-600 leading-relaxed mb-4">
            {{ feature.description }}
          </p>

          <!-- Learn More Link -->
          <NuxtLink to="/about" class="inline-flex items-center gap-2 text-primary-600 dark:text-primary-400 font-semibold text-sm group-hover:gap-3 transition-all">
            Daha Fazla
            <ArrowRight class="w-4 h-4" />
          </NuxtLink>

          <!-- Hover Effect Border -->
          <div class="absolute inset-0 rounded-2xl border-2 border-primary-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none"></div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { 
  Database, 
  MessageSquare, 
  Zap, 
  BarChart3, 
  Shield, 
  Sparkles,
  ArrowRight
} from 'lucide-vue-next'

const features = [
  {
    icon: Database,
    title: 'Gelişmiş Stok Yönetimi',
    description: 'Araç envanterinizi kolayca yönetin, fotoğraflar ekleyin, durumları takip edin ve detaylı raporlar alın.'
  },
  {
    icon: MessageSquare,
    title: 'Galeriler Arası Teklif',
    description: 'Diğer galerilerden araç almak için anında teklif gönderin, pazarlık yapın ve işlemleri hızlandırın.'
  },
  {
    icon: Zap,
    title: 'Otomatik İlan Aktarımı',
    description: 'Araçlarınızı otomatik olarak tüm pazar yerlerine aktarın, zaman kazanın ve daha fazla müşteriye ulaşın.'
  },
  {
    icon: BarChart3,
    title: 'Detaylı Analitik',
    description: 'Satış performansınızı, stok durumunuzu ve teklif istatistiklerinizi gerçek zamanlı olarak takip edin.'
  },
  {
    icon: Shield,
    title: 'Güvenli Platform',
    description: 'Endüstri standardı güvenlik önlemleri ile verileriniz her zaman korunur ve güvende kalır.'
  },
  {
    icon: Sparkles,
    title: 'Akıllı Eşleştirme',
    description: 'AI destekli sistem ile müşteri taleplerinize en uygun araçları otomatik olarak önerin.'
  }
]
</script>

<style scoped>
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.group {
  animation: fade-in-up 0.6s ease-out both;
}
</style>
