<template>
  <div class="fixed inset-0 bg-black">
    <!-- Header -->
    <div class="absolute top-0 left-0 right-0 z-20 p-4 bg-gradient-to-b from-black/80 to-transparent">
      <div class="flex items-center justify-between">
        <NuxtLink to="/" class="flex items-center gap-2 text-white">
          <ArrowLeft class="w-6 h-6" />
          <span class="font-bold text-lg">Oto Shorts</span>
        </NuxtLink>
        <div class="flex items-center gap-3">
          <button @click="toggleMute" class="p-2 rounded-full bg-white/20 backdrop-blur-sm text-white hover:bg-white/30 transition-colors">
            <VolumeX v-if="isMuted" class="w-5 h-5" />
            <Volume2 v-else class="w-5 h-5" />
          </button>
          <button @click="showSearch = true" class="p-2 rounded-full bg-white/20 backdrop-blur-sm text-white hover:bg-white/30 transition-colors">
            <Search class="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>

    <!-- Shorts Container -->
    <div 
      ref="shortsContainer"
      class="h-full overflow-y-scroll snap-y snap-mandatory scrollbar-hide"
      @scroll="handleScroll"
    >
      <div
        v-for="(short, index) in shorts"
        :key="short.id"
        class="h-full w-full snap-start snap-always relative flex items-center justify-center"
        :data-index="index"
      >
        <!-- Video Background -->
        <div class="absolute inset-0 bg-gradient-to-b from-gray-900 via-gray-800 to-gray-900">
          <!-- Placeholder for video - In production, use actual video element -->
          <div class="absolute inset-0 flex items-center justify-center">
            <div class="text-center">
              <Car class="w-24 h-24 text-white/30 mx-auto mb-4" />
              <div class="text-white/50 text-sm">Video Yukleniyor...</div>
            </div>
          </div>
        </div>

        <!-- Content Overlay -->
        <div class="absolute inset-0 flex">
          <!-- Left Side - Video Info -->
          <div class="flex-1 flex flex-col justify-end p-4 pb-24">
            <!-- Gallery Info -->
            <div class="flex items-center gap-3 mb-4">
              <div class="w-12 h-12 rounded-full bg-gradient-to-br from-primary-500 to-violet-500 flex items-center justify-center text-white font-bold border-2 border-white">
                {{ short.gallery_name?.charAt(0) || 'G' }}
              </div>
              <div>
                <h3 class="font-bold text-white">{{ short.gallery_name }}</h3>
                <p class="text-sm text-white/70">{{ short.gallery_location }}</p>
              </div>
              <button 
                v-if="!short.isFollowing"
                @click="followGallery(short.gallery_id)"
                class="ml-auto px-4 py-1.5 bg-white text-black text-sm font-bold rounded-full hover:bg-gray-200 transition-colors"
              >
                Takip Et
              </button>
              <span v-else class="ml-auto px-4 py-1.5 bg-white/20 text-white text-sm font-semibold rounded-full">
                Takip Ediliyor
              </span>
            </div>

            <!-- Vehicle Info -->
            <div class="mb-4">
              <h2 class="text-xl font-bold text-white mb-1">{{ short.vehicle_title }}</h2>
              <p class="text-2xl font-bold text-primary-400">{{ formatPrice(short.price) }} TL</p>
            </div>

            <!-- Description -->
            <p class="text-white/90 text-sm mb-4 line-clamp-2">
              {{ short.description }}
            </p>

            <!-- Hashtags -->
            <div class="flex flex-wrap gap-2 mb-4">
              <span 
                v-for="tag in short.hashtags" 
                :key="tag"
                class="text-sm text-primary-300 hover:text-primary-200 cursor-pointer"
              >
                {{ tag }}
              </span>
            </div>

            <!-- Music/Sound -->
            <div class="flex items-center gap-2 text-white/70">
              <Music class="w-4 h-4" />
              <div class="flex-1 overflow-hidden">
                <div class="whitespace-nowrap animate-marquee">
                  {{ short.sound_name || 'Orijinal Ses - ' + short.gallery_name }}
                </div>
              </div>
            </div>
          </div>

          <!-- Right Side - Action Buttons -->
          <div class="w-20 flex flex-col items-center justify-end gap-6 pb-24 pr-2">
            <!-- Like -->
            <button 
              @click="toggleLike(short)"
              class="flex flex-col items-center gap-1"
            >
              <div 
                class="w-12 h-12 rounded-full flex items-center justify-center transition-all"
                :class="short.isLiked ? 'bg-red-500 text-white scale-110' : 'bg-white/20 text-white hover:bg-white/30'"
              >
                <Heart class="w-6 h-6" :class="{ 'fill-current': short.isLiked }" />
              </div>
              <span class="text-white text-xs font-semibold">{{ formatNumber(short.like_count) }}</span>
            </button>

            <!-- Comment -->
            <button 
              @click="openComments(short)"
              class="flex flex-col items-center gap-1"
            >
              <div class="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center text-white hover:bg-white/30 transition-colors">
                <MessageCircle class="w-6 h-6" />
              </div>
              <span class="text-white text-xs font-semibold">{{ formatNumber(short.comment_count) }}</span>
            </button>

            <!-- Offer -->
            <button 
              @click="makeOffer(short)"
              class="flex flex-col items-center gap-1"
            >
              <div class="w-12 h-12 rounded-full bg-gradient-to-br from-primary-500 to-violet-500 flex items-center justify-center text-white hover:scale-110 transition-transform">
                <BadgeDollarSign class="w-6 h-6" />
              </div>
              <span class="text-white text-xs font-semibold">Teklif</span>
            </button>

            <!-- Share -->
            <button 
              @click="shareShort(short)"
              class="flex flex-col items-center gap-1"
            >
              <div class="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center text-white hover:bg-white/30 transition-colors">
                <Share2 class="w-6 h-6" />
              </div>
              <span class="text-white text-xs font-semibold">Paylas</span>
            </button>

            <!-- Save/Favorite -->
            <button 
              @click="toggleSave(short)"
              class="flex flex-col items-center gap-1"
            >
              <div 
                class="w-12 h-12 rounded-full flex items-center justify-center transition-all"
                :class="short.isSaved ? 'bg-amber-500 text-white' : 'bg-white/20 text-white hover:bg-white/30'"
              >
                <Bookmark class="w-6 h-6" :class="{ 'fill-current': short.isSaved }" />
              </div>
              <span class="text-white text-xs font-semibold">Kaydet</span>
            </button>

            <!-- More Options -->
            <button 
              @click="showMoreOptions(short)"
              class="flex flex-col items-center gap-1"
            >
              <div class="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center text-white hover:bg-white/30 transition-colors">
                <MoreVertical class="w-6 h-6" />
              </div>
            </button>
          </div>
        </div>

        <!-- Progress Indicator -->
        <div class="absolute bottom-0 left-0 right-0 h-1 bg-white/20">
          <div 
            class="h-full bg-white transition-all duration-100"
            :style="{ width: currentIndex === index ? progress + '%' : '0%' }"
          ></div>
        </div>
      </div>
    </div>

    <!-- Scroll Hint (shows only at start) -->
    <div v-if="showScrollHint" class="absolute bottom-32 left-1/2 -translate-x-1/2 text-white/70 text-sm flex flex-col items-center gap-2 animate-bounce">
      <ChevronUp class="w-6 h-6" />
      <span>Kaydirarak izle</span>
    </div>

    <!-- Comments Modal -->
    <Transition name="slide-up">
      <div v-if="showComments" class="fixed inset-x-0 bottom-0 z-50 bg-white dark:bg-gray-900 rounded-t-3xl max-h-[70vh] flex flex-col">
        <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
          <h3 class="font-bold text-lg text-gray-900 dark:text-white">{{ selectedShort?.comment_count || 0 }} Yorum</h3>
          <button @click="showComments = false" class="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="flex-1 overflow-y-auto p-4 space-y-4">
          <div v-for="comment in comments" :key="comment.id" class="flex gap-3">
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary-400 to-violet-400 flex items-center justify-center text-white font-bold text-sm flex-shrink-0">
              {{ comment.user_name?.charAt(0) || 'U' }}
            </div>
            <div class="flex-1">
              <div class="flex items-center gap-2">
                <span class="font-semibold text-gray-900 dark:text-white text-sm">{{ comment.user_name }}</span>
                <span class="text-xs text-gray-500">{{ comment.time_ago }}</span>
              </div>
              <p class="text-gray-700 dark:text-gray-300 text-sm mt-1">{{ comment.text }}</p>
              <div class="flex items-center gap-4 mt-2">
                <button class="flex items-center gap-1 text-xs text-gray-500 hover:text-gray-700">
                  <Heart class="w-4 h-4" />
                  {{ comment.likes }}
                </button>
                <button class="text-xs text-gray-500 hover:text-gray-700">Yanitle</button>
              </div>
            </div>
          </div>
        </div>
        <div class="p-4 border-t border-gray-200 dark:border-gray-700">
          <div class="flex items-center gap-3">
            <input
              v-model="newComment"
              type="text"
              placeholder="Yorum ekle..."
              class="flex-1 px-4 py-2 bg-gray-100 dark:bg-gray-800 rounded-full text-gray-900 dark:text-white"
              @keyup.enter="postComment"
            />
            <button 
              @click="postComment"
              :disabled="!newComment.trim()"
              class="p-2 bg-primary-500 text-white rounded-full disabled:opacity-50"
            >
              <Send class="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Offer Modal -->
    <Transition name="slide-up">
      <div v-if="showOfferModal" class="fixed inset-x-0 bottom-0 z-50 bg-white dark:bg-gray-900 rounded-t-3xl p-6">
        <div class="flex items-center justify-between mb-6">
          <h3 class="font-bold text-xl text-gray-900 dark:text-white">Teklif Ver</h3>
          <button @click="showOfferModal = false" class="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="mb-6">
          <div class="flex items-center gap-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-xl mb-4">
            <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-600 flex items-center justify-center">
              <Car class="w-8 h-8 text-gray-500" />
            </div>
            <div>
              <h4 class="font-bold text-gray-900 dark:text-white">{{ selectedShort?.vehicle_title }}</h4>
              <p class="text-primary-600 font-semibold">Ilan Fiyati: {{ formatPrice(selectedShort?.price) }} TL</p>
            </div>
          </div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Teklif Tutari (TL)</label>
          <input
            v-model="offerAmount"
            type="number"
            class="w-full px-4 py-3 text-2xl font-bold border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-center"
            placeholder="0"
          />
        </div>
        <button 
          @click="submitOffer"
          :disabled="!offerAmount"
          class="w-full py-4 bg-gradient-to-r from-primary-500 to-violet-500 text-white font-bold rounded-xl disabled:opacity-50 hover:shadow-lg transition-all"
        >
          Teklif Gonder
        </button>
      </div>
    </Transition>

    <!-- Backdrop for modals -->
    <div 
      v-if="showComments || showOfferModal"
      @click="showComments = false; showOfferModal = false"
      class="fixed inset-0 bg-black/50 z-40"
    ></div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import {
  ArrowLeft, Search, Volume2, VolumeX, Heart, MessageCircle, 
  BadgeDollarSign, Share2, Bookmark, MoreVertical, ChevronUp,
  X, Send, Car, Music
} from 'lucide-vue-next'

definePageMeta({
  layout: false
})

const shortsContainer = ref<HTMLElement | null>(null)
const currentIndex = ref(0)
const progress = ref(0)
const isMuted = ref(false)
const showScrollHint = ref(true)
const showSearch = ref(false)
const showComments = ref(false)
const showOfferModal = ref(false)
const selectedShort = ref<any>(null)
const newComment = ref('')
const offerAmount = ref<number | null>(null)

const shorts = ref([
  {
    id: 1,
    vehicle_title: '2024 BMW 320i M Sport',
    price: 2850000,
    gallery_id: 1,
    gallery_name: 'Yilmaz Otomotiv',
    gallery_location: 'Istanbul, Kadikoy',
    description: 'Sifir arac, full donanimli BMW 320i M Sport. Hemen teslim!',
    hashtags: ['#bmw', '#320i', '#msport', '#otoshorts', '#istanbul'],
    like_count: 12500,
    comment_count: 245,
    view_count: 85000,
    isLiked: false,
    isSaved: false,
    isFollowing: false,
    sound_name: 'Motor Sesi - BMW'
  },
  {
    id: 2,
    vehicle_title: 'Mercedes-Benz C200 AMG',
    price: 3200000,
    gallery_id: 2,
    gallery_name: 'Kaya Motors',
    gallery_location: 'Ankara, Cankaya',
    description: '2023 model, 15.000 km, beyaz renk, AMG paket.',
    hashtags: ['#mercedes', '#c200', '#amg', '#ankara'],
    like_count: 8900,
    comment_count: 156,
    view_count: 62000,
    isLiked: true,
    isSaved: false,
    isFollowing: true,
    sound_name: null
  },
  {
    id: 3,
    vehicle_title: 'Audi A4 45 TFSI Quattro',
    price: 2650000,
    gallery_id: 3,
    gallery_name: 'Premium Auto',
    gallery_location: 'Izmir, Karsiyaka',
    description: 'Quattro, matrix LED, virtual cockpit, panoramik cam tavan.',
    hashtags: ['#audi', '#a4', '#quattro', '#izmir', '#premium'],
    like_count: 6200,
    comment_count: 98,
    view_count: 41000,
    isLiked: false,
    isSaved: true,
    isFollowing: false,
    sound_name: 'Trending Sound #1'
  },
  {
    id: 4,
    vehicle_title: 'Volkswagen Golf 8 GTI',
    price: 1850000,
    gallery_id: 4,
    gallery_name: 'Demir Galeri',
    gallery_location: 'Bursa, Nilufer',
    description: 'GTI paket, DSG sanziman, 245 HP, dijital gosterge.',
    hashtags: ['#volkswagen', '#golf', '#gti', '#bursa'],
    like_count: 15800,
    comment_count: 312,
    view_count: 98000,
    isLiked: false,
    isSaved: false,
    isFollowing: false,
    sound_name: 'Exhaust Sound - VW'
  },
  {
    id: 5,
    vehicle_title: 'Toyota Corolla Hybrid',
    price: 1450000,
    gallery_id: 5,
    gallery_name: 'Arslan Otomotiv',
    gallery_location: 'Antalya, Muratpasa',
    description: 'Hybrid teknoloji, 4.5L/100km yakit tuketimi, 2024 model.',
    hashtags: ['#toyota', '#corolla', '#hybrid', '#antalya', '#ekonomik'],
    like_count: 4500,
    comment_count: 67,
    view_count: 28000,
    isLiked: false,
    isSaved: false,
    isFollowing: false,
    sound_name: null
  }
])

const comments = ref([
  { id: 1, user_name: 'Ahmet Y.', text: 'Harika bir arac, fiyati cok uygun!', time_ago: '2 saat once', likes: 45 },
  { id: 2, user_name: 'Mehmet K.', text: 'Bu modelin yakit tuketimi nasil?', time_ago: '3 saat once', likes: 12 },
  { id: 3, user_name: 'Fatma D.', text: 'Takas yapiyor musunuz?', time_ago: '5 saat once', likes: 8 },
  { id: 4, user_name: 'Ali O.', text: 'Cok sik gorunuyor!', time_ago: '1 gun once', likes: 89 }
])

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('tr-TR').format(price)
}

const formatNumber = (num: number) => {
  if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M'
  if (num >= 1000) return (num / 1000).toFixed(1) + 'K'
  return num.toString()
}

const handleScroll = () => {
  if (!shortsContainer.value) return
  const scrollTop = shortsContainer.value.scrollTop
  const height = shortsContainer.value.clientHeight
  currentIndex.value = Math.round(scrollTop / height)
  showScrollHint.value = false
}

const toggleMute = () => {
  isMuted.value = !isMuted.value
}

const toggleLike = (short: any) => {
  short.isLiked = !short.isLiked
  short.like_count += short.isLiked ? 1 : -1
}

const toggleSave = (short: any) => {
  short.isSaved = !short.isSaved
}

const followGallery = (galleryId: number) => {
  const short = shorts.value.find(s => s.gallery_id === galleryId)
  if (short) short.isFollowing = true
}

const openComments = (short: any) => {
  selectedShort.value = short
  showComments.value = true
}

const postComment = () => {
  if (!newComment.value.trim()) return
  comments.value.unshift({
    id: Date.now(),
    user_name: 'Sen',
    text: newComment.value,
    time_ago: 'Simdi',
    likes: 0
  })
  if (selectedShort.value) {
    selectedShort.value.comment_count++
  }
  newComment.value = ''
}

const makeOffer = (short: any) => {
  selectedShort.value = short
  offerAmount.value = null
  showOfferModal.value = true
}

const submitOffer = () => {
  if (!offerAmount.value) return
  alert(`Teklif gonderildi: ${formatPrice(offerAmount.value)} TL`)
  showOfferModal.value = false
  offerAmount.value = null
}

const shareShort = (short: any) => {
  if (navigator.share) {
    navigator.share({
      title: short.vehicle_title,
      text: short.description,
      url: window.location.href
    })
  } else {
    navigator.clipboard.writeText(window.location.href)
    alert('Link kopyalandi!')
  }
}

const showMoreOptions = (short: any) => {
  // Show more options menu
}

// Progress simulation
let progressInterval: any = null
onMounted(() => {
  progressInterval = setInterval(() => {
    progress.value = (progress.value + 1) % 100
  }, 100)

  // Hide scroll hint after 3 seconds
  setTimeout(() => {
    showScrollHint.value = false
  }, 3000)
})

onUnmounted(() => {
  if (progressInterval) clearInterval(progressInterval)
})
</script>

<style scoped>
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

@keyframes marquee {
  0% { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}

.animate-marquee {
  animation: marquee 10s linear infinite;
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: transform 0.3s ease;
}

.slide-up-enter-from,
.slide-up-leave-to {
  transform: translateY(100%);
}
</style>
