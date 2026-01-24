<template>
  <section class="py-12 md:py-24 bg-white dark:bg-gray-900 relative overflow-hidden">
    <!-- Background -->
    <div class="absolute inset-0 pointer-events-none">
      <div class="absolute bottom-0 left-0 w-full h-1/2 bg-gradient-to-t from-gray-50 dark:from-gray-800 to-transparent"></div>
    </div>

    <div class="container-custom relative z-10 px-4">
      <div class="grid lg:grid-cols-2 gap-8 lg:gap-16 items-start">
        <!-- Left Column - Header & CTA -->
        <div class="lg:sticky lg:top-24">
          <!-- Section Header -->
          <div class="inline-flex items-center gap-2 px-3 py-1.5 md:px-4 md:py-2 mb-3 md:mb-4 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 rounded-full text-xs md:text-sm font-semibold">
            <HelpCircle class="w-3 h-3 md:w-4 md:h-4" />
            SSS
          </div>
          <h2 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-3 md:mb-6">
            Sıkça Sorulan
            <span class="text-primary-600">Sorular</span>
          </h2>
          <p class="text-sm md:text-xl text-gray-600 dark:text-gray-300 mb-6 md:mb-8">
            Merak ettiğiniz her şeyin cevabı burada. Bulamazsanız destek ekibimize ulaşın.
          </p>

          <!-- Contact Card -->
          <div class="bg-gradient-to-br from-primary-500 to-violet-600 rounded-2xl md:rounded-3xl p-5 md:p-8 text-white">
            <div class="flex items-center gap-3 md:gap-4 mb-4 md:mb-6">
              <div class="w-10 h-10 md:w-14 md:h-14 rounded-xl md:rounded-2xl bg-white/20 backdrop-blur-sm flex items-center justify-center flex-shrink-0">
                <MessageCircle class="w-5 h-5 md:w-7 md:h-7" />
              </div>
              <div>
                <h4 class="font-bold text-base md:text-lg">Hala sorunuz mu var?</h4>
                <p class="text-primary-100 text-xs md:text-sm">7/24 destek ekibimiz size yardımcı olsun</p>
              </div>
            </div>
            <div class="space-y-2 md:space-y-3">
              <a href="mailto:destek@otobia.com" class="flex items-center gap-3 px-3 py-2.5 md:px-4 md:py-3 bg-white/10 rounded-lg md:rounded-xl hover:bg-white/20 transition-colors text-sm md:text-base">
                <Mail class="w-4 h-4 md:w-5 md:h-5" />
                <span>destek@otobia.com</span>
              </a>
              <a href="tel:+908508401234" class="flex items-center gap-3 px-3 py-2.5 md:px-4 md:py-3 bg-white/10 rounded-lg md:rounded-xl hover:bg-white/20 transition-colors text-sm md:text-base">
                <Phone class="w-4 h-4 md:w-5 md:h-5" />
                <span>0850 840 12 34</span>
              </a>
              <NuxtLink to="/contact" class="flex items-center gap-3 px-3 py-2.5 md:px-4 md:py-3 bg-white text-primary-700 font-semibold rounded-lg md:rounded-xl hover:bg-primary-50 transition-colors text-sm md:text-base">
                <Headphones class="w-4 h-4 md:w-5 md:h-5" />
                <span>Canlı Destek</span>
              </NuxtLink>
            </div>
          </div>
        </div>

        <!-- Right Column - FAQ Items -->
        <div class="space-y-3 md:space-y-4">
          <div 
            v-for="(faq, index) in faqs" 
            :key="index"
            class="bg-gray-50 dark:bg-gray-800 rounded-xl md:rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden transition-all duration-300"
            :class="{ 'ring-2 ring-primary-500 ring-offset-2 dark:ring-offset-gray-900': openIndex === index }"
          >
            <button 
              @click="toggleFAQ(index)"
              class="w-full flex items-center justify-between p-4 md:p-6 text-left hover:bg-gray-100 dark:hover:bg-gray-700/50 transition-colors"
            >
              <div class="flex items-center gap-3 md:gap-4">
                <div class="w-8 h-8 md:w-10 md:h-10 rounded-lg md:rounded-xl flex items-center justify-center flex-shrink-0 transition-colors"
                     :class="openIndex === index ? 'bg-primary-500 text-white' : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400'">
                  <component :is="faq.icon" class="w-4 h-4 md:w-5 md:h-5" />
                </div>
                <span class="font-semibold text-gray-900 dark:text-white text-sm md:text-lg">{{ faq.question }}</span>
              </div>
              <ChevronDown 
                class="w-4 h-4 md:w-5 md:h-5 text-gray-400 transition-transform duration-300 flex-shrink-0 ml-2"
                :class="{ 'rotate-180 text-primary-500': openIndex === index }"
              />
            </button>
            <Transition
              enter-active-class="transition-all duration-300 ease-out"
              leave-active-class="transition-all duration-200 ease-in"
              enter-from-class="opacity-0 max-h-0"
              enter-to-class="opacity-100 max-h-96"
              leave-from-class="opacity-100 max-h-96"
              leave-to-class="opacity-0 max-h-0"
            >
              <div v-if="openIndex === index" class="overflow-hidden">
                <div class="px-4 md:px-6 pb-4 md:pb-6 pt-2">
                  <p class="text-gray-600 dark:text-gray-400 leading-relaxed text-sm md:text-base pl-11 md:pl-14">
                    {{ faq.answer }}
                  </p>
                  <div v-if="faq.link" class="mt-3 md:mt-4 pl-11 md:pl-14">
                    <NuxtLink :to="faq.link.url" class="inline-flex items-center gap-2 text-primary-600 dark:text-primary-400 font-semibold text-sm hover:gap-3 transition-all">
                      {{ faq.link.text }}
                      <ArrowRight class="w-3 h-3 md:w-4 md:h-4" />
                    </NuxtLink>
                  </div>
                </div>
              </div>
            </Transition>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { 
  HelpCircle, MessageCircle, Mail, Phone, Headphones, 
  ChevronDown, ArrowRight, CreditCard, Clock, Shield, 
  Upload, Users, Settings, Zap, Globe 
} from 'lucide-vue-next'

const openIndex = ref<number | null>(0)

const toggleFAQ = (index: number) => {
  openIndex.value = openIndex.value === index ? null : index
}

const faqs = [
  {
    icon: CreditCard,
    question: 'Ücretsiz deneme süresi var mı?',
    answer: 'Evet! 14 gün boyunca tüm özellikleri ücretsiz deneyebilirsiniz. Kredi kartı bilgisi gerekmez ve deneme süresi sonunda otomatik ücretlendirme yapılmaz.',
    link: { text: 'Hemen Ücretsiz Başla', url: '/register' }
  },
  {
    icon: Clock,
    question: 'Kayıt işlemi ne kadar sürüyor?',
    answer: 'Kayıt işlemi yalnızca 2-3 dakika sürmektedir. E-posta adresinizi ve galeri bilgilerinizi girdikten sonra hemen kullanmaya başlayabilirsiniz.'
  },
  {
    icon: Upload,
    question: 'Mevcut araç stokumu nasıl aktarabilirim?',
    answer: 'Excel dosyanızı yükleyerek tüm araçlarınızı toplu olarak aktarabilirsiniz. Sistem, marka, model, yıl, fiyat gibi bilgileri otomatik olarak tanır ve eşleştirmektedir.'
  },
  {
    icon: Globe,
    question: 'Hangi pazar yerleri ile entegrasyon var?',
    answer: 'Sahibinden.com, Arabam.com, Letgo, Facebook Marketplace ve daha birçok platform ile entegrasyonumuz bulunmaktadır. Oto Shorts ile video tabanlı ilan da oluşturabilirsiniz.'
  },
  {
    icon: Users,
    question: 'Galeriler arası teklif sistemi nasıl çalışıyor?',
    answer: 'Platformdaki diğer galerilerden beğendiğiniz araca anında teklif gönderebilirsiniz. Gerçek zamanlı mesajlaşma ile pazarlık yapabilir ve anlaştığınız araçlar için güvenli işlem gerçekleştirebilirsiniz.'
  },
  {
    icon: Shield,
    question: 'Verilerim güvenli mi?',
    answer: 'Tüm verileriniz SSL sertifikası ile şifrelenmekte ve günlük yedeklenmektedir. KVKK uyumlu altyapımız ile kişisel verileriniz her zaman koruma altındadır.'
  },
  {
    icon: Zap,
    question: 'Oto Shorts nedir?',
    answer: 'Oto Shorts, araçların kısa video formatında tanıtılmasını sağlayan yeni özelliğimizdir. TikTok ve Instagram Reels tarzında 30 saniyelik videolar ile araçlarınızı sergileyin ve 3 kat daha fazla görüntülenme alın.',
    link: { text: 'Oto Shorts Hakkında', url: '/about' }
  },
  {
    icon: Settings,
    question: 'Aboneliğimi istediğim zaman iptal edebilir miyim?',
    answer: 'Evet, aboneliğinizi istediğiniz zaman iptal edebilirsiniz. İptal işleminden sonra mevcut döneminin sonuna kadar platformu kullanmaya devam edebilirsiniz. Herhangi bir cayma ücreti yoktur.'
  }
]
</script>
