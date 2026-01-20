<template>
  <section class="py-24 bg-gradient-to-b from-gray-50 to-white dark:from-gray-900 dark:to-gray-800 relative overflow-hidden">
    <!-- Background -->
    <div class="absolute inset-0 pointer-events-none">
      <div class="absolute top-20 left-10 w-72 h-72 bg-primary-200 dark:bg-primary-900/30 rounded-full blur-3xl opacity-40"></div>
      <div class="absolute bottom-20 right-10 w-96 h-96 bg-violet-200 dark:bg-violet-900/30 rounded-full blur-3xl opacity-40"></div>
    </div>

    <div class="container-custom relative z-10">
      <!-- Section Header -->
      <div class="text-center mb-16">
        <div class="inline-flex items-center gap-2 px-4 py-2 mb-4 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300 rounded-full text-sm font-semibold">
          <Star class="w-4 h-4 fill-current" />
          Müşterilerimiz
        </div>
        <h2 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
          <span class="text-primary-600">500+</span> Galeri Bize Güveniyor
        </h2>
        <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
          Gerçek kullanıcı deneyimlerini okuyun ve neden bizi tercih ettiklerini öğrenin
        </p>
      </div>

      <!-- Testimonials Grid -->
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div 
          v-for="(testimonial, index) in testimonials" 
          :key="testimonial.name"
          class="group bg-white dark:bg-gray-800 rounded-3xl p-8 shadow-lg border border-gray-100 dark:border-gray-700 hover:shadow-2xl transition-all duration-300 hover:-translate-y-2"
          :class="{ 'lg:col-span-2': index === 0 }"
        >
          <!-- Quote Icon -->
          <div class="mb-6">
            <Quote class="w-10 h-10 text-primary-200 dark:text-primary-800" />
          </div>

          <!-- Rating -->
          <div class="flex items-center gap-1 mb-4">
            <Star v-for="i in 5" :key="i" class="w-5 h-5 text-amber-400 fill-current" />
          </div>

          <!-- Content -->
          <p class="text-gray-700 dark:text-gray-300 text-lg leading-relaxed mb-6" :class="{ 'text-xl': index === 0 }">
            "{{ testimonial.content }}"
          </p>

          <!-- Stats (for featured) -->
          <div v-if="testimonial.stats" class="grid grid-cols-3 gap-4 mb-6 p-4 bg-primary-50 dark:bg-primary-900/20 rounded-2xl">
            <div v-for="stat in testimonial.stats" :key="stat.label" class="text-center">
              <div class="text-2xl font-bold text-primary-600 dark:text-primary-400">{{ stat.value }}</div>
              <div class="text-xs text-gray-600 dark:text-gray-400">{{ stat.label }}</div>
            </div>
          </div>

          <!-- Author -->
          <div class="flex items-center gap-4">
            <div class="w-14 h-14 rounded-2xl overflow-hidden flex-shrink-0"
                 :class="testimonial.avatarBg">
              <div class="w-full h-full flex items-center justify-center text-white font-bold text-xl">
                {{ testimonial.name.split(' ').map(n => n[0]).join('') }}
              </div>
            </div>
            <div>
              <div class="font-bold text-gray-900 dark:text-white">{{ testimonial.name }}</div>
              <div class="text-sm text-gray-600 dark:text-gray-400">{{ testimonial.role }}</div>
              <div class="text-xs text-primary-600 dark:text-primary-400 font-medium">{{ testimonial.company }}</div>
            </div>
            <div class="ml-auto">
              <div class="flex items-center gap-1 text-sm text-gray-500 dark:text-gray-400">
                <MapPin class="w-4 h-4" />
                {{ testimonial.location }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Bottom Stats -->
      <div class="mt-16 bg-gradient-to-r from-primary-600 to-violet-600 rounded-3xl p-8 md:p-12">
        <div class="grid md:grid-cols-4 gap-8 text-center text-white">
          <div>
            <div class="text-4xl md:text-5xl font-bold mb-2">4.9</div>
            <div class="flex items-center justify-center gap-1 mb-1">
              <Star v-for="i in 5" :key="i" class="w-4 h-4 text-amber-400 fill-current" />
            </div>
            <div class="text-primary-200 text-sm">Ortalama Puan</div>
          </div>
          <div>
            <div class="text-4xl md:text-5xl font-bold mb-2">500+</div>
            <div class="text-primary-200 text-sm">Aktif Galeri</div>
          </div>
          <div>
            <div class="text-4xl md:text-5xl font-bold mb-2">%99</div>
            <div class="text-primary-200 text-sm">Memnuniyet Oranı</div>
          </div>
          <div>
            <div class="text-4xl md:text-5xl font-bold mb-2">7/24</div>
            <div class="text-primary-200 text-sm">Destek</div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { Star, Quote, MapPin } from 'lucide-vue-next'

const testimonials = [
  {
    name: 'Ahmet Yılmaz',
    role: 'Galeri Sahibi',
    company: 'Yılmaz Otomotiv',
    location: 'İstanbul',
    avatarBg: 'bg-gradient-to-br from-primary-500 to-violet-500',
    content: 'Otobia ile işlerimiz inanılmaz hızlandı. Eskiden her platforma ayrı ayrı ilan giriyorduk, şimdi tek tıklama ile hepsine ulaşıyoruz. Oto Shorts özelliği de müşterilerimizin dikkatini çekiyor, video görüntülenmeleri 3 kat arttı!',
    stats: [
      { value: '%150', label: 'Satış Artışı' },
      { value: '45', label: 'Araç/Ay' },
      { value: '2 Yıl', label: 'Üyelik' }
    ]
  },
  {
    name: 'Mehmet Kaya',
    role: 'İş Geliştirme Müdürü',
    company: 'Kaya Motors',
    location: 'Ankara',
    avatarBg: 'bg-gradient-to-br from-emerald-500 to-teal-500',
    content: 'Galeriler arası teklif sistemi muhteşem. Başka galerilerden araç almak çok kolaylaştı. Gerçek zamanlı mesajlaşma ile hızlı karar alabiliyoruz.'
  },
  {
    name: 'Fatma Demir',
    role: 'Operasyon Müdürü',
    company: 'Demir Galeri',
    location: 'İzmir',
    avatarBg: 'bg-gradient-to-br from-amber-500 to-orange-500',
    content: 'Stok yönetimi artık çok basit. Tüm araçlarımızı tek panelden takip ediyoruz. Raporlama özellikleri de çok faydalı.'
  },
  {
    name: 'Ali Öztürk',
    role: 'Galeri Sahibi',
    company: 'Öztürk Auto',
    location: 'Bursa',
    avatarBg: 'bg-gradient-to-br from-rose-500 to-pink-500',
    content: 'Müşteri desteği mükemmel! Her sorunumuza anında çözüm buluyorlar. Platform sürekli güncelleniyor ve yeni özellikler ekleniyor.'
  },
  {
    name: 'Zeynep Arslan',
    role: 'Dijital Pazarlama',
    company: 'Arslan Otomotiv',
    location: 'Antalya',
    avatarBg: 'bg-gradient-to-br from-blue-500 to-indigo-500',
    content: 'Sosyal medya entegrasyonları sayesinde müşterilere daha hızlı ulaşıyoruz. WhatsApp entegrasyonu özellikle çok işimize yarıyor.'
  }
]
</script>
