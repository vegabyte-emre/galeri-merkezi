<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Oto Shorts Yonetimi</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Video icerikleri yonetin ve moderasyon yapin</p>
      </div>
      <div class="flex items-center gap-3">
        <button @click="refreshData" class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
          <RefreshCw class="w-4 h-4" />
        </button>
        <button @click="showSettings = true" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors flex items-center gap-2">
          <Settings class="w-4 h-4" />
          Ayarlar
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center">
            <Video class="w-6 h-6 text-white" />
          </div>
          <div>
            <p class="text-sm text-gray-500 dark:text-gray-400">Toplam Video</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.totalVideos }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-green-500 to-emerald-500 flex items-center justify-center">
            <CheckCircle class="w-6 h-6 text-white" />
          </div>
          <div>
            <p class="text-sm text-gray-500 dark:text-gray-400">Yayinda</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.publishedVideos }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-amber-500 to-orange-500 flex items-center justify-center">
            <Clock class="w-6 h-6 text-white" />
          </div>
          <div>
            <p class="text-sm text-gray-500 dark:text-gray-400">Beklemede</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.pendingVideos }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-500 flex items-center justify-center">
            <Eye class="w-6 h-6 text-white" />
          </div>
          <div>
            <p class="text-sm text-gray-500 dark:text-gray-400">Toplam Izlenme</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ formatNumber(stats.totalViews) }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl p-4 border border-gray-200 dark:border-gray-700">
      <div class="flex flex-wrap items-center gap-4">
        <div class="flex-1 min-w-[200px]">
          <div class="relative">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Video, galeri veya arac ara..."
              class="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
          </div>
        </div>
        <select
          v-model="statusFilter"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
        >
          <option value="">Tum Durumlar</option>
          <option value="pending">Beklemede</option>
          <option value="processing">Isleniyor</option>
          <option value="published">Yayinda</option>
          <option value="rejected">Reddedildi</option>
          <option value="removed">Kaldirildi</option>
        </select>
        <select
          v-model="sortBy"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
        >
          <option value="newest">En Yeni</option>
          <option value="oldest">En Eski</option>
          <option value="views">En Cok Izlenen</option>
          <option value="likes">En Cok Begenilen</option>
        </select>
      </div>
    </div>

    <!-- Videos Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      <div
        v-for="video in filteredVideos"
        :key="video.id"
        class="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-lg transition-shadow group"
      >
        <!-- Thumbnail -->
        <div class="relative aspect-[9/16] bg-gray-900">
          <div class="absolute inset-0 flex items-center justify-center">
            <div class="w-20 h-20 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center">
              <Play class="w-10 h-10 text-white" />
            </div>
          </div>
          <!-- Status Badge -->
          <div class="absolute top-3 left-3">
            <span
              class="px-2 py-1 rounded-full text-xs font-semibold"
              :class="getStatusClass(video.status)"
            >
              {{ getStatusText(video.status) }}
            </span>
          </div>
          <!-- Duration -->
          <div class="absolute bottom-3 right-3 px-2 py-1 bg-black/70 rounded text-white text-xs">
            {{ formatDuration(video.duration_seconds) }}
          </div>
        </div>

        <!-- Info -->
        <div class="p-4">
          <div class="flex items-start gap-3">
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary-500 to-violet-500 flex items-center justify-center text-white font-bold text-sm flex-shrink-0">
              {{ video.gallery_name?.charAt(0) || 'G' }}
            </div>
            <div class="flex-1 min-w-0">
              <h3 class="font-semibold text-gray-900 dark:text-white truncate">{{ video.title || video.vehicle_title }}</h3>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ video.gallery_name }}</p>
            </div>
          </div>

          <!-- Stats -->
          <div class="flex items-center gap-4 mt-4 text-sm text-gray-500 dark:text-gray-400">
            <div class="flex items-center gap-1">
              <Eye class="w-4 h-4" />
              {{ formatNumber(video.view_count) }}
            </div>
            <div class="flex items-center gap-1">
              <Heart class="w-4 h-4" />
              {{ formatNumber(video.like_count) }}
            </div>
            <div class="flex items-center gap-1">
              <MessageCircle class="w-4 h-4" />
              {{ video.comment_count || 0 }}
            </div>
          </div>

          <!-- Actions -->
          <div class="flex items-center gap-2 mt-4">
            <button
              v-if="video.status === 'pending'"
              @click="approveVideo(video.id)"
              class="flex-1 px-3 py-2 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-lg text-sm font-semibold hover:bg-green-200 dark:hover:bg-green-900/50 transition-colors"
            >
              Onayla
            </button>
            <button
              v-if="video.status === 'pending'"
              @click="rejectVideo(video.id)"
              class="flex-1 px-3 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg text-sm font-semibold hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors"
            >
              Reddet
            </button>
            <button
              v-if="video.status === 'published'"
              @click="removeVideo(video.id)"
              class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg text-sm font-semibold hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
            >
              Kaldir
            </button>
            <button
              @click="viewDetails(video)"
              class="px-3 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
            >
              <MoreHorizontal class="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="filteredVideos.length === 0" class="text-center py-16">
      <Video class="w-16 h-16 mx-auto text-gray-300 dark:text-gray-600 mb-4" />
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">Video Bulunamadi</h3>
      <p class="text-gray-500 dark:text-gray-400">Arama kriterlerinize uygun video yok.</p>
    </div>

    <!-- Settings Modal -->
    <div v-if="showSettings" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div class="bg-white dark:bg-gray-800 rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto m-4">
        <div class="p-6 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Oto Shorts Ayarlari</h2>
          <button @click="showSettings = false" class="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="p-6 space-y-6">
          <!-- Auto Approve -->
          <div class="flex items-center justify-between">
            <div>
              <h4 class="font-semibold text-gray-900 dark:text-white">Otomatik Onay</h4>
              <p class="text-sm text-gray-500 dark:text-gray-400">Yeni videolari otomatik olarak yayinla</p>
            </div>
            <button
              @click="settings.autoApprove = !settings.autoApprove"
              class="w-12 h-6 rounded-full transition-colors"
              :class="settings.autoApprove ? 'bg-primary-500' : 'bg-gray-300 dark:bg-gray-600'"
            >
              <div
                class="w-5 h-5 rounded-full bg-white shadow transform transition-transform"
                :class="settings.autoApprove ? 'translate-x-6' : 'translate-x-0.5'"
              ></div>
            </button>
          </div>

          <!-- Max Video Duration -->
          <div>
            <label class="block font-semibold text-gray-900 dark:text-white mb-2">Maksimum Video Suresi (saniye)</label>
            <input
              v-model.number="settings.maxDuration"
              type="number"
              min="10"
              max="60"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
          </div>

          <!-- Max File Size -->
          <div>
            <label class="block font-semibold text-gray-900 dark:text-white mb-2">Maksimum Dosya Boyutu (MB)</label>
            <input
              v-model.number="settings.maxFileSize"
              type="number"
              min="5"
              max="100"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
          </div>

          <!-- Allow Comments -->
          <div class="flex items-center justify-between">
            <div>
              <h4 class="font-semibold text-gray-900 dark:text-white">Yorumlara Izin Ver</h4>
              <p class="text-sm text-gray-500 dark:text-gray-400">Kullanicilar videolara yorum yapabilsin</p>
            </div>
            <button
              @click="settings.allowComments = !settings.allowComments"
              class="w-12 h-6 rounded-full transition-colors"
              :class="settings.allowComments ? 'bg-primary-500' : 'bg-gray-300 dark:bg-gray-600'"
            >
              <div
                class="w-5 h-5 rounded-full bg-white shadow transform transition-transform"
                :class="settings.allowComments ? 'translate-x-6' : 'translate-x-0.5'"
              ></div>
            </button>
          </div>

          <!-- Allow Likes -->
          <div class="flex items-center justify-between">
            <div>
              <h4 class="font-semibold text-gray-900 dark:text-white">Begenilere Izin Ver</h4>
              <p class="text-sm text-gray-500 dark:text-gray-400">Kullanicilar videolari begenebilsin</p>
            </div>
            <button
              @click="settings.allowLikes = !settings.allowLikes"
              class="w-12 h-6 rounded-full transition-colors"
              :class="settings.allowLikes ? 'bg-primary-500' : 'bg-gray-300 dark:bg-gray-600'"
            >
              <div
                class="w-5 h-5 rounded-full bg-white shadow transform transition-transform"
                :class="settings.allowLikes ? 'translate-x-6' : 'translate-x-0.5'"
              ></div>
            </button>
          </div>

          <!-- Featured Hashtags -->
          <div>
            <label class="block font-semibold text-gray-900 dark:text-white mb-2">One Cikan Hashtagler</label>
            <input
              v-model="settings.featuredHashtags"
              type="text"
              placeholder="#otoshorts, #araba, #galeri"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Virgul ile ayirin</p>
          </div>
        </div>
        <div class="p-6 border-t border-gray-200 dark:border-gray-700 flex justify-end gap-3">
          <button @click="showSettings = false" class="px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg">
            Iptal
          </button>
          <button @click="saveSettings" class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700">
            Kaydet
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  Video, CheckCircle, Clock, Eye, Search, Settings, RefreshCw,
  Play, Heart, MessageCircle, MoreHorizontal, X
} from 'lucide-vue-next'

const searchQuery = ref('')
const statusFilter = ref('')
const sortBy = ref('newest')
const showSettings = ref(false)

const stats = ref({
  totalVideos: 0,
  publishedVideos: 0,
  pendingVideos: 0,
  totalViews: 0
})

const settings = ref({
  autoApprove: false,
  maxDuration: 30,
  maxFileSize: 30,
  allowComments: true,
  allowLikes: true,
  featuredHashtags: '#otoshorts, #araba, #galeri'
})

const videos = ref<any[]>([])

// Demo data
onMounted(() => {
  stats.value = {
    totalVideos: 156,
    publishedVideos: 142,
    pendingVideos: 8,
    totalViews: 45230
  }

  videos.value = [
    { id: 1, title: '2024 BMW 320i Tanitim', gallery_name: 'Yilmaz Oto', status: 'published', duration_seconds: 28, view_count: 12500, like_count: 890, comment_count: 45 },
    { id: 2, title: 'Mercedes C200 AMG', gallery_name: 'Kaya Motors', status: 'pending', duration_seconds: 25, view_count: 0, like_count: 0, comment_count: 0 },
    { id: 3, title: 'Audi A4 2023 Model', gallery_name: 'Premium Auto', status: 'published', duration_seconds: 30, view_count: 8700, like_count: 620, comment_count: 32 },
    { id: 4, title: 'VW Golf 8 GTI', gallery_name: 'Demir Galeri', status: 'processing', duration_seconds: 22, view_count: 0, like_count: 0, comment_count: 0 },
    { id: 5, title: 'Toyota Corolla Hybrid', gallery_name: 'Arslan Oto', status: 'published', duration_seconds: 27, view_count: 5400, like_count: 380, comment_count: 18 },
    { id: 6, title: 'Honda Civic RS', gallery_name: 'Ozturk Auto', status: 'rejected', duration_seconds: 35, view_count: 0, like_count: 0, comment_count: 0 },
    { id: 7, title: 'Skoda Octavia 2024', gallery_name: 'Yilmaz Oto', status: 'pending', duration_seconds: 29, view_count: 0, like_count: 0, comment_count: 0 },
    { id: 8, title: 'Peugeot 308 GT', gallery_name: 'Kaya Motors', status: 'published', duration_seconds: 26, view_count: 3200, like_count: 210, comment_count: 12 }
  ]
})

const filteredVideos = computed(() => {
  let result = [...videos.value]

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(v =>
      v.title?.toLowerCase().includes(query) ||
      v.gallery_name?.toLowerCase().includes(query)
    )
  }

  if (statusFilter.value) {
    result = result.filter(v => v.status === statusFilter.value)
  }

  switch (sortBy.value) {
    case 'oldest':
      result.reverse()
      break
    case 'views':
      result.sort((a, b) => b.view_count - a.view_count)
      break
    case 'likes':
      result.sort((a, b) => b.like_count - a.like_count)
      break
  }

  return result
})

const formatNumber = (num: number) => {
  if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M'
  if (num >= 1000) return (num / 1000).toFixed(1) + 'K'
  return num.toString()
}

const formatDuration = (seconds: number) => {
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const getStatusClass = (status: string) => {
  const classes: Record<string, string> = {
    pending: 'bg-amber-100 text-amber-800 dark:bg-amber-900/50 dark:text-amber-300',
    processing: 'bg-blue-100 text-blue-800 dark:bg-blue-900/50 dark:text-blue-300',
    published: 'bg-green-100 text-green-800 dark:bg-green-900/50 dark:text-green-300',
    rejected: 'bg-red-100 text-red-800 dark:bg-red-900/50 dark:text-red-300',
    removed: 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
  }
  return classes[status] || classes.pending
}

const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    pending: 'Beklemede',
    processing: 'Isleniyor',
    published: 'Yayinda',
    rejected: 'Reddedildi',
    removed: 'Kaldirildi'
  }
  return texts[status] || status
}

const refreshData = () => {
  // API call to refresh data
}

const approveVideo = (id: number) => {
  const video = videos.value.find(v => v.id === id)
  if (video) video.status = 'published'
}

const rejectVideo = (id: number) => {
  const video = videos.value.find(v => v.id === id)
  if (video) video.status = 'rejected'
}

const removeVideo = (id: number) => {
  const video = videos.value.find(v => v.id === id)
  if (video) video.status = 'removed'
}

const viewDetails = (video: any) => {
  console.log('View details:', video)
}

const saveSettings = () => {
  showSettings.value = false
  // API call to save settings
}
</script>
