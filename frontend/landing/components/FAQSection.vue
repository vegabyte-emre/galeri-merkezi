<template>
  <section class="py-24 bg-white dark:bg-gray-900 relative overflow-hidden">
    <!-- Background -->
    <div class="absolute inset-0 pointer-events-none">
      <div class="absolute bottom-0 left-0 w-full h-1/2 bg-gradient-to-t from-gray-50 dark:from-gray-800 to-transparent"></div>
    </div>

    <div class="container-custom relative z-10">
      <div class="grid lg:grid-cols-2 gap-16 items-start">
        <!-- Left Column - Header & CTA -->
        <div class="lg:sticky lg:top-24">
          <!-- Section Header -->
          <div class="inline-flex items-center gap-2 px-4 py-2 mb-4 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 rounded-full text-sm font-semibold">
            <HelpCircle class="w-4 h-4" />
            SSS
          </div>
          <h2 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
            Sikca Sorulan
            <span class="text-primary-600">Sorular</span>
          </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 mb-8">
            Merak ettiginiz her seyin cevabi burada. Bulamazsiniz destek ekibimize ulasin.
          </p>

          <!-- Contact Card -->
          <div class="bg-gradient-to-br from-primary-500 to-violet-600 rounded-3xl p-8 text-white">
            <div class="flex items-center gap-4 mb-6">
              <div class="w-14 h-14 rounded-2xl bg-white/20 backdrop-blur-sm flex items-center justify-center">
                <MessageCircle class="w-7 h-7" />
              </div>
              <div>
                <h4 class="font-bold text-lg">Hala sorunuz mu var?</h4>
                <p class="text-primary-100 text-sm">7/24 destek ekibimiz size yardimci olsun</p>
              </div>
            </div>
            <div class="space-y-3">
              <a href="mailto:destek@Otobia.com" class="flex items-center gap-3 px-4 py-3 bg-white/10 rounded-xl hover:bg-white/20 transition-colors">
                <Mail class="w-5 h-5" />
                <span>destek@Otobia.com</span>
              </a>
              <a href="tel:+908508401234" class="flex items-center gap-3 px-4 py-3 bg-white/10 rounded-xl hover:bg-white/20 transition-colors">
                <Phone class="w-5 h-5" />
                <span>0850 840 12 34</span>
              </a>
              <NuxtLink to="/contact" class="flex items-center gap-3 px-4 py-3 bg-white text-primary-700 font-semibold rounded-xl hover:bg-primary-50 transition-colors">
                <Headphones class="w-5 h-5" />
                <span>Canli Destek</span>
              </NuxtLink>
            </div>
          </div>
        </div>

        <!-- Right Column - FAQ Items -->
        <div class="space-y-4">
          <div 
            v-for="(faq, index) in faqs" 
            :key="index"
            class="bg-gray-50 dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden transition-all duration-300"
            :class="{ 'ring-2 ring-primary-500 ring-offset-2 dark:ring-offset-gray-900': openIndex === index }"
          >
            <button 
              @click="toggleFAQ(index)"
              class="w-full flex items-center justify-between p-6 text-left hover:bg-gray-100 dark:hover:bg-gray-700/50 transition-colors"
            >
              <div class="flex items-center gap-4">
                <div class="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 transition-colors"
                     :class="openIndex === index ? 'bg-primary-500 text-white' : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400'">
                  <component :is="faq.icon" class="w-5 h-5" />
                </div>
                <span class="font-semibold text-gray-900 dark:text-white text-lg">{{ faq.question }}</span>
              </div>
              <ChevronDown 
                class="w-5 h-5 text-gray-400 transition-transform duration-300 flex-shrink-0"
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
                <div class="px-6 pb-6 pt-2">
                  <p class="text-gray-600 dark:text-gray-400 leading-relaxed pl-14">
                    {{ faq.answer }}
                  </p>
                  <div v-if="faq.link" class="mt-4 pl-14">
                    <NuxtLink :to="faq.link.url" class="inline-flex items-center gap-2 text-primary-600 dark:text-primary-400 font-semibold hover:gap-3 transition-all">
                      {{ faq.link.text }}
                      <ArrowRight class="w-4 h-4" />
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
    question: 'Ucretsiz deneme suresi var mi?',
    answer: 'Evet! 14 gun boyunca tum ozellikleri ucretsiz deneyebilirsiniz. Kredi karti bilgisi gerekmez ve deneme suresi sonunda otomatik ucretlendirme yapilmaz.',
    link: { text: 'Hemen Ucretsiz Basla', url: '/register' }
  },
  {
    icon: Clock,
    question: 'Kayit islemi ne kadar suruyor?',
    answer: 'Kayit islemi yalnizca 2-3 dakika surmektedir. E-posta adresinizi ve galeri bilgilerinizi girdikten sonra hemen kullanmaya baslayabilirsiniz.'
  },
  {
    icon: Upload,
    question: 'Mevcut arac stokumu nasil aktarabilirim?',
    answer: 'Excel dosyanizi yukleyerek tum araclarinizi toplu olarak aktarabilirsiniz. Sistem, marka, model, yil, fiyat gibi bilgileri otomatik olarak tanir ve eslestirmektedir.'
  },
  {
    icon: Globe,
    question: 'Hangi pazar yerleri ile entegrasyon var?',
    answer: 'Sahibinden.com, Arabam.com, Letgo, Facebook Marketplace ve daha bircok platform ile entegrasyonumuz bulunmaktadir. Oto Shorts ile video tabanli ilan da olusturabilirsiniz.'
  },
  {
    icon: Users,
    question: 'Galeriler arasi teklif sistemi nasil calisiyor?',
    answer: 'Platformdaki diger galerilerden begendiginiz araca aninda teklif gonderebilirsiniz. Gercek zamanli mesajlasma ile pazarlik yapabilir ve anlastiginiz araclar icin guvenli islem gerceklestirebilirsiniz.'
  },
  {
    icon: Shield,
    question: 'Verilerim guvenli mi?',
    answer: 'Tum verileriniz SSL sertifikasi ile sifrelenmekte ve gunluk yedeklenmektedir. KVKK uyumlu altyapimiz ile kisisel verileriniz her zaman koruma altindadir.'
  },
  {
    icon: Zap,
    question: 'Oto Shorts nedir?',
    answer: 'Oto Shorts, araclarin kisa video formatinda tanitilmasini saglayan yeni ozelligimizdir. TikTok ve Instagram Reels tarzinda 30 saniyelik videolar ile araclarinizi sergileyin ve 3 kat daha fazla goruntulenme alin.',
    link: { text: 'Oto Shorts Hakkinda', url: '/about' }
  },
  {
    icon: Settings,
    question: 'Aboneligimi istedigim zaman iptal edebilir miyim?',
    answer: 'Evet, aboneliginizi istediginiz zaman iptal edebilirsiniz. Iptal isleminden sonra mevcut doneminin sonuna kadar platformu kullanmaya devam edebilirsiniz. Herhangi bir cayma ucreti yoktur.'
  }
]
</script>
