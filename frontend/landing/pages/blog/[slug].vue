<template>
  <div class="py-12" v-if="post">
    <div class="container-custom max-w-4xl">
      <!-- Back Button -->
      <NuxtLink
        to="/blog"
        class="inline-flex items-center gap-2 text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 mb-6"
      >
        <ArrowLeft class="w-4 h-4" />
        Blog'a Dön
      </NuxtLink>

      <!-- Article Header -->
      <article class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
        <!-- Featured Image -->
        <div class="h-64 md:h-96 bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center">
          <FileText class="w-32 h-32 text-white opacity-50" />
        </div>

        <!-- Article Content -->
        <div class="p-8 md:p-12">
          <!-- Meta -->
          <div class="flex items-center gap-4 mb-6">
            <span class="px-3 py-1 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-full text-sm font-semibold">
              {{ post.category }}
            </span>
            <span class="text-sm text-gray-500 dark:text-gray-400">{{ formatDate(post.date) }}</span>
            <span class="text-sm text-gray-500 dark:text-gray-400">•</span>
            <span class="text-sm text-gray-500 dark:text-gray-400">{{ post.author }}</span>
          </div>

          <!-- Title -->
          <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
            {{ post.title }}
          </h1>

          <!-- Excerpt -->
          <p class="text-xl text-gray-600 dark:text-gray-400 mb-8 leading-relaxed">
            {{ post.excerpt }}
          </p>

          <!-- Article Body -->
          <div class="prose prose-lg dark:prose-invert max-w-none">
            <div class="space-y-6 text-gray-700 dark:text-gray-300 leading-relaxed">
              <p>
                {{ post.content }}
              </p>
              <h2 class="text-2xl font-bold text-gray-900 dark:text-white mt-8 mb-4">
                Başlık 1
              </h2>
              <p>
                Bu bölümde detaylı içerik yer alacak. Platformumuzun özellikleri, kullanım senaryoları 
                ve sektördeki gelişmeler hakkında bilgiler paylaşılacak.
              </p>
              <h3 class="text-xl font-bold text-gray-900 dark:text-white mt-6 mb-3">
                Alt Başlık
              </h3>
              <p>
                Daha fazla detay ve örnekler burada yer alacak. Kullanıcılar için faydalı bilgiler 
                ve ipuçları paylaşılacak.
              </p>
              <ul class="list-disc list-inside space-y-2 ml-4">
                <li>Önemli nokta 1</li>
                <li>Önemli nokta 2</li>
                <li>Önemli nokta 3</li>
              </ul>
            </div>
          </div>

          <!-- Share Buttons -->
          <div class="mt-12 pt-8 border-t border-gray-200 dark:border-gray-700">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Paylaş</h3>
            <div class="flex items-center gap-3">
              <button class="px-4 py-2 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400 rounded-lg hover:bg-blue-200 dark:hover:bg-blue-900/50 transition-colors font-semibold">
                Twitter
              </button>
              <button class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-semibold">
                LinkedIn
              </button>
              <button class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold">
                Kopyala
              </button>
            </div>
          </div>
        </div>
      </article>

      <!-- Related Posts -->
      <div class="mt-12">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">İlgili Yazılar</h2>
        <div class="grid md:grid-cols-3 gap-6">
          <article
            v-for="relatedPost in relatedPosts"
            :key="relatedPost.id"
            class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-xl transition-all cursor-pointer group"
          >
            <div class="h-40 bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center">
              <FileText class="w-12 h-12 text-white opacity-50" />
            </div>
            <div class="p-6">
              <h3 class="font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
                {{ relatedPost.title }}
              </h3>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ formatDate(relatedPost.date) }}</p>
            </div>
          </article>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft, FileText } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const post = ref<any>(null)

const relatedPosts = ref([
  {
    id: 1,
    title: 'B2B Platformlarının Avantajları',
    date: '2024-01-20'
  },
  {
    id: 2,
    title: 'Stok Yönetimi İpuçları',
    date: '2024-01-18'
  },
  {
    id: 3,
    title: 'Güvenli İşlem İçin Öneriler',
    date: '2024-01-14'
  }
])

onMounted(async () => {
  try {
    const api = useApi()
    post.value = await api.get(`/blog/${route.params.slug}`)
  } catch (error: any) {
    console.error('Blog yazısı yüklenemedi:', error)
    // Fallback to default
    post.value = {
      title: 'Oto Galeri Sektöründe Dijital Dönüşüm',
      excerpt: 'Dijitalleşme, oto galeri sektörünü nasıl dönüştürüyor? Yeni teknolojiler ve trendler hakkında detaylı bir inceleme.',
      category: 'İş Dünyası',
      date: '2024-01-15',
      author: 'Ahmet Yılmaz',
      content: 'Dijital dönüşüm, oto galeri sektöründe devrim yaratıyor. Geleneksel yöntemlerden modern teknolojilere geçiş, işletmelerin verimliliğini artırıyor ve müşteri deneyimini iyileştiriyor.'
    }
  }
})

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

useHead({
  title: post.value ? `${post.value.title} - Blog - Galeri Merkezi` : 'Blog - Galeri Merkezi'
})
</script>

