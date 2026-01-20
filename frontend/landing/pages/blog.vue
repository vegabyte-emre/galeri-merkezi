<template>
  <div class="py-12">
    <div class="container-custom">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
          Blog & Haberler
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
          Sektör haberleri, ipuçları ve güncellemeler
        </p>
      </div>

      <!-- Featured Post -->
      <div
        v-if="featuredPost"
        class="mb-12 bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden"
      >
        <div class="md:flex">
          <div class="md:w-1/2 h-64 md:h-auto bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center">
            <FileText class="w-32 h-32 text-white opacity-50" />
          </div>
          <div class="md:w-1/2 p-8 md:p-12">
            <div class="inline-block px-3 py-1 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-full text-sm font-semibold mb-4">
              Öne Çıkan
            </div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">
              {{ featuredPost.title }}
            </h2>
            <p class="text-gray-600 dark:text-gray-400 mb-6 leading-relaxed">
              {{ featuredPost.excerpt }}
            </p>
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-3 text-sm text-gray-500 dark:text-gray-400">
                <span>{{ formatDate(featuredPost.date) }}</span>
                <span>•</span>
                <span>{{ featuredPost.author }}</span>
              </div>
              <button class="px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold">
                Devamını Oku
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Posts Grid -->
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
        <article
          v-for="post in posts"
          :key="post.id"
          class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-xl transition-all cursor-pointer group"
        >
          <div class="h-48 bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center">
            <FileText class="w-16 h-16 text-white opacity-50" />
          </div>
          <div class="p-6">
            <div class="flex items-center gap-2 mb-3">
              <span class="px-2 py-1 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded text-xs font-semibold">
                {{ post.category }}
              </span>
              <span class="text-xs text-gray-500 dark:text-gray-400">{{ formatDate(post.date) }}</span>
            </div>
            <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-3 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
              {{ post.title }}
            </h3>
            <p class="text-gray-600 dark:text-gray-400 mb-4 line-clamp-3">
              {{ post.excerpt }}
            </p>
            <div class="flex items-center justify-between">
              <div class="text-sm text-gray-500 dark:text-gray-400">
                {{ post.author }}
              </div>
              <button class="text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 font-semibold text-sm">
                Oku →
              </button>
            </div>
          </div>
        </article>
      </div>

      <!-- Pagination -->
      <div class="mt-12 flex items-center justify-center gap-2">
        <button class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
          Önceki
        </button>
        <button class="px-4 py-2 bg-primary-500 text-white rounded-lg font-semibold">1</button>
        <button class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">2</button>
        <button class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">3</button>
        <button class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
          Sonraki
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { FileText } from 'lucide-vue-next'
import { ref } from 'vue'

useHead({
  title: 'Blog - Otobia'
})

const featuredPost = ref({
  title: 'Oto Galeri Sektöründe Dijital Dönüşüm',
  excerpt: 'Dijitalleşme, oto galeri sektörünü nasıl dönüştürüyor? Yeni teknolojiler ve trendler hakkında detaylı bir inceleme.',
  date: '2024-01-15',
  author: 'Ahmet Yılmaz'
})

const posts = ref([
  {
    id: 1,
    title: 'B2B Platformlarının Avantajları',
    excerpt: 'Galeriler arası işbirliğinin önemi ve B2B platformlarının sağladığı faydalar.',
    category: 'İş Dünyası',
    date: '2024-01-20',
    author: 'Mehmet Demir'
  },
  {
    id: 2,
    title: 'Stok Yönetimi İpuçları',
    excerpt: 'Etkili stok yönetimi için pratik ipuçları ve en iyi uygulamalar.',
    category: 'Rehber',
    date: '2024-01-18',
    author: 'Ayşe Kaya'
  },
  {
    id: 3,
    title: 'Yeni Özellikler: AI Destekli Eşleştirme',
    excerpt: 'Platformumuza eklenen yapay zeka destekli araç eşleştirme özelliği hakkında bilgiler.',
    category: 'Güncelleme',
    date: '2024-01-16',
    author: 'Fatma Şahin'
  },
  {
    id: 4,
    title: 'Güvenli İşlem İçin Öneriler',
    excerpt: 'Online araç alım-satım işlemlerinde güvenlik için dikkat edilmesi gerekenler.',
    category: 'Güvenlik',
    date: '2024-01-14',
    author: 'Ahmet Yılmaz'
  },
  {
    id: 5,
    title: 'Pazar Analizi: 2024 Trendleri',
    excerpt: 'Oto galeri sektöründe 2024 yılı için öngörülen trendler ve fırsatlar.',
    category: 'Analiz',
    date: '2024-01-12',
    author: 'Mehmet Demir'
  },
  {
    id: 6,
    title: 'Müşteri Memnuniyeti Artırma Yolları',
    excerpt: 'Müşteri deneyimini iyileştirmek ve memnuniyeti artırmak için stratejiler.',
    category: 'İş Dünyası',
    date: '2024-01-10',
    author: 'Ayşe Kaya'
  }
])

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>














