<template>
  <div class="space-y-6">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Yardım Merkezi</h1>
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Sık sorulan sorular ve destek kaynakları</p>
    </div>

    <!-- Search -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <div class="flex items-center gap-3">
        <div class="flex-1 relative">
          <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Yardım konusu ara..."
            class="w-full pl-12 pr-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>
      </div>
    </div>

    <!-- Categories -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="category in categories"
        :key="category.id"
        @click="selectedCategory = category.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border-2 p-6 cursor-pointer hover:shadow-xl transition-all"
        :class="selectedCategory === category.id 
          ? 'border-primary-500' 
          : 'border-gray-200 dark:border-gray-700'"
      >
        <div
          class="w-12 h-12 rounded-xl flex items-center justify-center mb-4"
          :class="category.iconBg"
        >
          <component :is="category.icon" class="w-6 h-6" :class="category.iconColor" />
        </div>
        <h3 class="font-bold text-gray-900 dark:text-white mb-2">{{ category.name }}</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400">{{ category.description }}</p>
        <div class="mt-4 text-sm text-primary-600 dark:text-primary-400 font-semibold">
          {{ category.articleCount }} makale →
        </div>
      </div>
    </div>

    <!-- FAQs -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Sık Sorulan Sorular</h2>
      <div class="space-y-3">
        <div
          v-for="faq in filteredFAQs"
          :key="faq.id"
          class="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden"
        >
          <button
            @click="toggleFAQ(faq.id)"
            class="w-full flex items-center justify-between p-4 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
          >
            <span class="font-semibold text-gray-900 dark:text-white text-left">{{ faq.question }}</span>
            <ChevronDown
              class="w-5 h-5 text-gray-400 transition-transform flex-shrink-0"
              :class="{ 'rotate-180': openFAQs.includes(faq.id) }"
            />
          </button>
          <div
            v-if="openFAQs.includes(faq.id)"
            class="px-4 pb-4 text-sm text-gray-600 dark:text-gray-400"
          >
            {{ faq.answer }}
          </div>
        </div>
      </div>
    </div>

    <!-- Contact Support -->
    <div class="bg-gradient-to-r from-primary-600 to-primary-800 rounded-2xl p-8 text-white">
      <div class="flex items-center justify-between">
        <div>
          <h3 class="text-xl font-bold mb-2">Hala yardıma mı ihtiyacınız var?</h3>
          <p class="text-primary-100">Destek ekibimizle iletişime geçin</p>
        </div>
        <div class="flex items-center gap-3">
          <button class="px-6 py-3 bg-white text-primary-700 font-semibold rounded-lg hover:bg-primary-50 transition-colors">
            Canlı Destek
          </button>
          <button class="px-6 py-3 bg-primary-500 text-white font-semibold rounded-lg hover:bg-primary-400 transition-colors">
            E-posta Gönder
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  Search,
  ChevronDown,
  Book,
  Car,
  Users,
  Settings,
  DollarSign,
  Shield,
  MessageSquare
} from 'lucide-vue-next'
import { ref, computed } from 'vue'

const searchQuery = ref('')
const selectedCategory = ref<number | null>(null)
const openFAQs = ref<number[]>([])

const categories = [
  {
    id: 1,
    name: 'Başlangıç Rehberi',
    description: 'Platforma başlarken bilmeniz gerekenler',
    articleCount: 12,
    icon: Book,
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600 dark:text-blue-400'
  },
  {
    id: 2,
    name: 'Araç Yönetimi',
    description: 'Araç ekleme, düzenleme ve yönetimi',
    articleCount: 18,
    icon: Car,
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600 dark:text-green-400'
  },
  {
    id: 3,
    name: 'Teklifler',
    description: 'Teklif gönderme ve yönetimi',
    articleCount: 8,
    icon: Users,
    iconBg: 'bg-purple-100 dark:bg-purple-900/30',
    iconColor: 'text-purple-600 dark:text-purple-400'
  },
  {
    id: 4,
    name: 'Ayarlar',
    description: 'Hesap ve galeri ayarları',
    articleCount: 10,
    icon: Settings,
    iconBg: 'bg-orange-100 dark:bg-orange-900/30',
    iconColor: 'text-orange-600 dark:text-orange-400'
  },
  {
    id: 5,
    name: 'Faturalandırma',
    description: 'Ödeme ve abonelik yönetimi',
    articleCount: 6,
    icon: DollarSign,
    iconBg: 'bg-yellow-100 dark:bg-yellow-900/30',
    iconColor: 'text-yellow-600 dark:text-yellow-400'
  },
  {
    id: 6,
    name: 'Güvenlik',
    description: 'Hesap güvenliği ve gizlilik',
    articleCount: 7,
    icon: Shield,
    iconBg: 'bg-red-100 dark:bg-red-900/30',
    iconColor: 'text-red-600 dark:text-red-400'
  }
]

const faqs = [
  {
    id: 1,
    question: 'Nasıl araç ekleyebilirim?',
    answer: 'Araçlarım sayfasından "Yeni Araç Ekle" butonuna tıklayarak veya toplu yükleme özelliğini kullanarak Excel dosyası ile araç ekleyebilirsiniz.',
    category: 2
  },
  {
    id: 2,
    question: 'Teklif nasıl gönderirim?',
    answer: 'Teklifler sayfasından yeni teklif oluşturabilir veya bir araç detay sayfasından direkt teklif gönderebilirsiniz.',
    category: 3
  },
  {
    id: 3,
    question: 'Abonelik planımı nasıl değiştirebilirim?',
    answer: 'Ayarlar > Abonelik bölümünden mevcut planınızı yükseltebilir veya düşürebilirsiniz. Değişiklikler anında geçerli olur.',
    category: 5
  },
  {
    id: 4,
    question: 'Şifremi nasıl sıfırlarım?',
    answer: 'Giriş sayfasından "Şifremi Unuttum" linkine tıklayarak e-posta adresinize şifre sıfırlama linki gönderebilirsiniz.',
    category: 6
  },
  {
    id: 5,
    question: 'Kanal entegrasyonu nasıl yapılır?',
    answer: 'Kanallar sayfasından istediğiniz pazar yerini seçerek bağlantı kurun. API anahtarlarınızı girerek entegrasyonu tamamlayın.',
    category: 2
  }
]

const filteredFAQs = computed(() => {
  let filtered = faqs

  if (selectedCategory.value) {
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














