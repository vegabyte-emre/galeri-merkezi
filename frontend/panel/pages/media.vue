<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Medya Kütüphanesi</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Tüm görsellerinizi buradan yönetin</p>
      </div>
      <div class="flex items-center gap-3">
        <button
          @click="showUploadModal = true"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          <Upload class="w-4 h-4 inline mr-2" />
          Yükle
        </button>
        <select
          v-model="viewMode"
          class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-700 dark:text-gray-300"
        >
          <option value="grid">Grid</option>
          <option value="list">Liste</option>
        </select>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-4">
      <div class="flex items-center gap-4">
        <div class="flex-1">
          <div class="relative">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Medya ara..."
              class="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
          </div>
        </div>
        <select
          v-model="filterType"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
        >
          <option value="">Tüm Türler</option>
          <option value="image">Görsel</option>
          <option value="video">Video</option>
          <option value="document">Döküman</option>
        </select>
        <select
          v-model="sortBy"
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
        >
          <option value="date-desc">En Yeni</option>
          <option value="date-asc">En Eski</option>
          <option value="name-asc">İsme Göre (A-Z)</option>
          <option value="name-desc">İsme Göre (Z-A)</option>
          <option value="size-desc">Boyut (Büyükten Küçüğe)</option>
        </select>
      </div>
    </div>

    <!-- Media Grid -->
    <div v-if="viewMode === 'grid'" class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-4">
      <div
        v-for="media in filteredMedia"
        :key="media.id"
        class="group relative aspect-square bg-gray-100 dark:bg-gray-700 rounded-xl overflow-hidden cursor-pointer hover:shadow-xl transition-all"
        @click="selectMedia(media)"
      >
        <img
          v-if="media.type === 'image'"
          :src="media.url"
          :alt="media.name"
          class="w-full h-full object-cover"
        />
        <div
          v-else
          class="w-full h-full flex items-center justify-center bg-gradient-to-br from-primary-400 to-primary-600"
        >
          <FileText class="w-12 h-12 text-white opacity-50" />
        </div>
        
        <!-- Overlay -->
        <div class="absolute inset-0 bg-black/0 group-hover:bg-black/50 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100">
          <div class="flex items-center gap-2">
            <button
              @click.stop="downloadMedia(media.id)"
              class="p-2 bg-white/90 rounded-lg hover:bg-white transition-colors"
            >
              <Download class="w-4 h-4 text-gray-900" />
            </button>
            <button
              @click.stop="deleteMedia(media.id)"
              class="p-2 bg-red-500/90 rounded-lg hover:bg-red-500 transition-colors"
            >
              <Trash2 class="w-4 h-4 text-white" />
            </button>
          </div>
        </div>

        <!-- Selected Indicator -->
        <div
          v-if="selectedMedia.includes(media.id)"
          class="absolute top-2 right-2 w-6 h-6 bg-primary-500 rounded-full flex items-center justify-center"
        >
          <Check class="w-4 h-4 text-white" />
        </div>

        <!-- Info -->
        <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-2">
          <div class="text-white text-xs font-semibold truncate">{{ media.name }}</div>
          <div class="text-white/80 text-xs">{{ formatSize(media.size) }}</div>
        </div>
      </div>
    </div>

    <!-- Media List -->
    <div v-else class="space-y-2">
      <div
        v-for="media in filteredMedia"
        :key="media.id"
        class="flex items-center gap-4 p-4 bg-white dark:bg-gray-800 rounded-xl shadow-lg border border-gray-200 dark:border-gray-700 hover:shadow-xl transition-all cursor-pointer"
        @click="selectMedia(media)"
      >
        <div class="w-16 h-16 rounded-lg bg-gray-100 dark:bg-gray-700 flex items-center justify-center flex-shrink-0">
          <img
            v-if="media.type === 'image'"
            :src="media.url"
            :alt="media.name"
            class="w-full h-full object-cover rounded-lg"
          />
          <FileText v-else class="w-8 h-8 text-gray-400" />
        </div>
        <div class="flex-1 min-w-0">
          <div class="font-semibold text-gray-900 dark:text-white truncate">{{ media.name }}</div>
          <div class="text-sm text-gray-500 dark:text-gray-400">
            {{ formatSize(media.size) }} • {{ formatDate(media.uploadedAt) }}
          </div>
        </div>
        <div class="flex items-center gap-2">
          <button
            @click.stop="downloadMedia(media.id)"
            class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          >
            <Download class="w-4 h-4 text-gray-600 dark:text-gray-400" />
          </button>
          <button
            @click.stop="deleteMedia(media.id)"
            class="p-2 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/30 transition-colors"
          >
            <Trash2 class="w-4 h-4 text-red-600 dark:text-red-400" />
          </button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div
      v-if="filteredMedia.length === 0"
      class="text-center py-16 bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700"
    >
      <Upload class="w-24 h-24 text-gray-400 mx-auto mb-4" />
      <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Henüz Medya Yok</h3>
      <p class="text-gray-600 dark:text-gray-400 mb-6">
        İlk medyanızı yükleyerek başlayın
      </p>
      <button
        @click="showUploadModal = true"
        class="inline-block px-6 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
      >
        Medya Yükle
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Upload, Search, Download, Trash2, FileText, Check } from 'lucide-vue-next'
import { ref, computed } from 'vue'

const showUploadModal = ref(false)
const searchQuery = ref('')
const filterType = ref('')
const sortBy = ref('date-desc')
const viewMode = ref('grid')
const selectedMedia = ref<number[]>([])

const media = ref([
  {
    id: 1,
    name: 'bmw-320i-front.jpg',
    type: 'image',
    url: 'https://via.placeholder.com/300',
    size: 2456789,
    uploadedAt: '2024-01-20T14:30:00'
  },
  {
    id: 2,
    name: 'mercedes-c200-side.jpg',
    type: 'image',
    url: 'https://via.placeholder.com/300',
    size: 3124567,
    uploadedAt: '2024-01-20T13:15:00'
  },
  {
    id: 3,
    name: 'audi-a4-interior.jpg',
    type: 'image',
    url: 'https://via.placeholder.com/300',
    size: 1890234,
    uploadedAt: '2024-01-19T16:45:00'
  },
  {
    id: 4,
    name: 'vehicle-specs.pdf',
    type: 'document',
    url: '',
    size: 456789,
    uploadedAt: '2024-01-19T12:00:00'
  }
])

const filteredMedia = computed(() => {
  let filtered = media.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(m => m.name.toLowerCase().includes(query))
  }

  if (filterType.value) {
    filtered = filtered.filter(m => m.type === filterType.value)
  }

  // Sort
  filtered = [...filtered].sort((a, b) => {
    switch (sortBy.value) {
      case 'date-asc':
        return new Date(a.uploadedAt).getTime() - new Date(b.uploadedAt).getTime()
      case 'date-desc':
        return new Date(b.uploadedAt).getTime() - new Date(a.uploadedAt).getTime()
      case 'name-asc':
        return a.name.localeCompare(b.name)
      case 'name-desc':
        return b.name.localeCompare(a.name)
      case 'size-desc':
        return b.size - a.size
      default:
        return 0
    }
  })

  return filtered
})

const formatSize = (bytes: number) => {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR')
}

const selectMedia = (media: any) => {
  const index = selectedMedia.value.indexOf(media.id)
  if (index > -1) {
    selectedMedia.value.splice(index, 1)
  } else {
    selectedMedia.value.push(media.id)
  }
}

const downloadMedia = async (id: number) => {
  try {
    const api = useApi()
    const response = await api.get(`/media/${id}/download`, undefined, { responseType: 'blob' })
    
    const url = window.URL.createObjectURL(response)
    const a = document.createElement('a')
    a.href = url
    a.download = media.value.find(m => m.id === id)?.name || 'download'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
  } catch (error: any) {
    alert('İndirme başarısız: ' + error.message)
  }
}

const deleteMedia = async (id: number) => {
  if (confirm('Bu medyayı silmek istediğinize emin misiniz?')) {
    try {
      const api = useApi()
      await api.delete(`/media/${id}`)
      media.value = media.value.filter(m => m.id !== id)
    } catch (error: any) {
      alert('Hata: ' + error.message)
    }
  }
}
</script>

