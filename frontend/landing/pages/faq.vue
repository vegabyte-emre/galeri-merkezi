<template>
  <div class="py-12">
    <div class="container-custom max-w-4xl">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
          Sık Sorulan Sorular
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-400">
          Merak ettiğiniz soruların cevapları
        </p>
      </div>

      <!-- Search -->
      <div class="mb-8">
        <div class="relative">
          <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Sorunuzu arayın..."
            class="w-full pl-12 pr-4 py-4 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>
      </div>

      <!-- FAQ Categories -->
      <div class="mb-8 flex items-center gap-2 flex-wrap">
        <button
          v-for="category in categories"
          :key="category"
          @click="selectedCategory = category"
          class="px-4 py-2 rounded-lg font-semibold text-sm transition-colors"
          :class="selectedCategory === category
            ? 'bg-primary-500 text-white'
            : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'"
        >
          {{ category }}
        </button>
      </div>

      <!-- FAQ Items -->
      <div class="space-y-4">
        <div
          v-for="faq in filteredFAQs"
          :key="faq.id"
          class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden"
        >
          <button
            @click="toggleFAQ(faq.id)"
            class="w-full flex items-center justify-between p-6 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
          >
            <h3 class="text-lg font-bold text-gray-900 dark:text-white text-left pr-4">
              {{ faq.question }}
            </h3>
            <ChevronDown
              class="w-5 h-5 text-gray-400 flex-shrink-0 transition-transform"
              :class="{ 'rotate-180': openFAQs.includes(faq.id) }"
            />
          </button>
          <div
            v-if="openFAQs.includes(faq.id)"
            class="px-6 pb-6 text-gray-600 dark:text-gray-400 leading-relaxed"
          >
            {{ faq.answer }}
          </div>
        </div>
      </div>

      <!-- Contact CTA -->
      <div class="mt-12 bg-gradient-to-r from-primary-600 to-primary-800 rounded-2xl p-8 text-white text-center">
        <h3 class="text-2xl font-bold mb-2">Sorunuz mu var?</h3>
        <p class="text-primary-100 mb-6">
          Aradığınız cevabı bulamadıysanız bizimle iletişime geçin
        </p>
        <NuxtLink
          to="/contact"
          class="inline-block px-6 py-3 bg-white text-primary-700 font-semibold rounded-lg hover:bg-primary-50 transition-colors"
        >
          İletişime Geç
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Search, ChevronDown } from 'lucide-vue-next'
import { ref, computed } from 'vue'

useHead({
  title: 'SSS - Otobia'
})

const searchQuery = ref('')
const selectedCategory = ref('Tümü')
const openFAQs = ref<number[]>([])

const categories = ['Tümü', 'Genel', 'Kayıt & Giriş', 'Fiyatlandırma', 'Teknik', 'Güvenlik']

const faqs = ref([
  {
    id: 1,
    category: 'Genel',
    question: 'Otobia nedir?',
    answer: 'Otobia, oto galerileri arasında stok yönetimi, teklif/pazarlık, mesajlaşma ve pazar yerlerine ilan aktarımı yapabilen B2B bir platformdur. Galeriler, platform üzerinden birbirleriyle iş yapabilir ve stoklarını yönetebilirler.'
  },
  {
    id: 2,
    category: 'Kayıt & Giriş',
    question: 'Nasıl kayıt olabilirim?',
    answer: 'Ana sayfadaki "Kayıt Ol" butonuna tıklayarak kayıt formunu doldurabilirsiniz. Galeri bilgilerinizi ve iletişim bilgilerinizi girdikten sonra, hesabınız admin onayından geçecektir.'
  },
  {
    id: 3,
    category: 'Kayıt & Giriş',
    question: 'Hesap onayı ne kadar sürer?',
    answer: 'Hesap onayları genellikle 24 saat içinde tamamlanır. Acil durumlarda destek ekibimizle iletişime geçebilirsiniz.'
  },
  {
    id: 4,
    category: 'Fiyatlandırma',
    question: 'Ücretsiz deneme var mı?',
    answer: 'Evet, tüm planlarda 14 gün ücretsiz deneme süresi vardır. Kredi kartı bilgisi gerektirmez.'
  },
  {
    id: 5,
    category: 'Fiyatlandırma',
    question: 'Plan değiştirebilir miyim?',
    answer: 'Evet, istediğiniz zaman planınızı yükseltebilir veya düşürebilirsiniz. Değişiklikler anında geçerli olur.'
  },
  {
    id: 6,
    category: 'Teknik',
    question: 'Hangi pazar yerleriyle entegrasyon var?',
    answer: 'Şu anda Sahibinden, Arabam ve Otomobil.com ile entegrasyonlarımız mevcuttur. Daha fazla pazar yeri entegrasyonu için çalışmalarımız devam etmektedir.'
  },
  {
    id: 7,
    category: 'Teknik',
    question: 'API dokümantasyonu var mı?',
    answer: 'Evet, platformumuzun kapsamlı bir API dokümantasyonu mevcuttur. Admin panelinden API dokümantasyonuna erişebilirsiniz.'
  },
  {
    id: 8,
    category: 'Güvenlik',
    question: 'Verilerim güvende mi?',
    answer: 'Evet, verilerinizin güvenliği bizim önceliğimizdir. Endüstri standardı şifreleme teknolojileri, güvenli sunucular ve düzenli güvenlik denetimleri ile verileriniz korunmaktadır.'
  },
  {
    id: 9,
    category: 'Güvenlik',
    question: 'İptal edebilir miyim?',
    answer: 'Evet, istediğiniz zaman iptal edebilirsiniz. İptal işlemi sonrası hesabınız dönem sonuna kadar aktif kalır.'
  }
])

const filteredFAQs = computed(() => {
  let filtered = faqs.value

  if (selectedCategory.value !== 'Tümü') {
    filtered = filtered.filter(f => f.category === selectedCategory.value)
  }

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(f =>
      f.question.toLowerCase().includes(query) ||
      f.answer.toLowerCase().includes(query)
    )
  }

  return filtered
})

const toggleFAQ = (id: number) => {
  const index = openFAQs.value.indexOf(id)
  if (index > -1) {
    openFAQs.value.splice(index, 1)
  } else {
    openFAQs.value.push(id)
  }
}
</script>














