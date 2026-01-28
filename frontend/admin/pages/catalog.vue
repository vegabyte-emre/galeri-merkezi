<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Araç Kataloğu Yönetimi</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Araç markalarını, serilerini ve modellerini yönetin</p>
      </div>
      <button 
        @click="refreshStats"
        class="flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-200 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
      >
        <RefreshCw class="w-4 h-4" :class="{ 'animate-spin': loading }" />
        Yenile
      </button>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
        <div class="flex items-center gap-3">
          <div class="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
            <Car class="w-5 h-5 text-blue-600 dark:text-blue-400" />
          </div>
          <div>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.brands }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400">Marka</p>
          </div>
        </div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
        <div class="flex items-center gap-3">
          <div class="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
            <Layers class="w-5 h-5 text-green-600 dark:text-green-400" />
          </div>
          <div>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.series }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400">Seri</p>
          </div>
        </div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
        <div class="flex items-center gap-3">
          <div class="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
            <Grid3x3 class="w-5 h-5 text-purple-600 dark:text-purple-400" />
          </div>
          <div>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.models }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400">Model</p>
          </div>
        </div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
        <div class="flex items-center gap-3">
          <div class="p-2 bg-orange-100 dark:bg-orange-900/30 rounded-lg">
            <List class="w-5 h-5 text-orange-600 dark:text-orange-400" />
          </div>
          <div>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.altModels }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400">Alt Model</p>
          </div>
        </div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
        <div class="flex items-center gap-3">
          <div class="p-2 bg-red-100 dark:bg-red-900/30 rounded-lg">
            <Settings class="w-5 h-5 text-red-600 dark:text-red-400" />
          </div>
          <div>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.trims }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400">Donanım</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Excel Import Section -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
        <FileSpreadsheet class="w-5 h-5 text-green-600" />
        Excel ile Katalog Güncelleme
      </h2>
      
      <div class="space-y-4">
        <!-- Instructions -->
        <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
          <h3 class="font-semibold text-blue-800 dark:text-blue-200 mb-2">Excel Dosyası Formatı</h3>
          <p class="text-sm text-blue-700 dark:text-blue-300 mb-2">Dosyanız aşağıdaki sütunları içermelidir:</p>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-2 text-xs">
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Ana Kategori</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Alt Kategori</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Marka</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Seri</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Model</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Alt Model</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Donanım</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Kasa Tipi</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Yakıt Tipi</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Vites</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Motor Gücü</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Motor Hacmi</span>
            <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded">Çekiş</span>
          </div>
        </div>

        <!-- Drop Zone -->
        <div
          @dragover.prevent="isDragging = true"
          @dragleave.prevent="isDragging = false"
          @drop.prevent="handleFileDrop"
          class="border-2 border-dashed rounded-xl p-8 text-center transition-colors"
          :class="isDragging 
            ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20' 
            : 'border-gray-300 dark:border-gray-600 hover:border-primary-400'"
        >
          <input
            ref="fileInput"
            type="file"
            accept=".xlsx,.xls,.csv"
            class="hidden"
            @change="handleFileSelect"
          />
          
          <div v-if="!selectedFile">
            <Upload class="w-12 h-12 mx-auto text-gray-400 mb-4" />
            <p class="text-gray-600 dark:text-gray-300 mb-2">
              Excel dosyasını sürükleyip bırakın veya
            </p>
            <button
              @click="$refs.fileInput.click()"
              class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
            >
              Dosya Seç
            </button>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
              Desteklenen formatlar: .xlsx, .xls, .csv
            </p>
          </div>

          <div v-else class="space-y-4">
            <div class="flex items-center justify-center gap-3">
              <FileSpreadsheet class="w-10 h-10 text-green-600" />
              <div class="text-left">
                <p class="font-medium text-gray-900 dark:text-white">{{ selectedFile.name }}</p>
                <p class="text-sm text-gray-500">{{ formatFileSize(selectedFile.size) }}</p>
              </div>
              <button
                @click="clearFile"
                class="p-2 text-gray-400 hover:text-red-500 transition-colors"
              >
                <X class="w-5 h-5" />
              </button>
            </div>

            <!-- Preview Section -->
            <div v-if="previewData" class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 text-left">
              <h4 class="font-semibold text-gray-900 dark:text-white mb-2">Önizleme</h4>
              <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                <div>
                  <span class="text-gray-500">Toplam Satır:</span>
                  <span class="font-bold text-gray-900 dark:text-white ml-2">{{ previewData.totalRows }}</span>
                </div>
                <div>
                  <span class="text-gray-500">Markalar:</span>
                  <span class="font-bold text-gray-900 dark:text-white ml-2">{{ previewData.brands }}</span>
                </div>
                <div>
                  <span class="text-gray-500">Seriler:</span>
                  <span class="font-bold text-gray-900 dark:text-white ml-2">{{ previewData.series }}</span>
                </div>
                <div>
                  <span class="text-gray-500">Modeller:</span>
                  <span class="font-bold text-gray-900 dark:text-white ml-2">{{ previewData.models }}</span>
                </div>
              </div>
            </div>

            <div class="flex gap-3 justify-center">
              <button
                @click="previewFile"
                :disabled="previewing"
                class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors disabled:opacity-50 flex items-center gap-2"
              >
                <Eye class="w-4 h-4" />
                {{ previewing ? 'Analiz Ediliyor...' : 'Önizle' }}
              </button>
              <button
                @click="importFile"
                :disabled="importing || !previewData"
                class="px-6 py-2 bg-gradient-to-r from-green-500 to-green-600 text-white rounded-lg hover:shadow-lg transition-all disabled:opacity-50 flex items-center gap-2"
              >
                <Download class="w-4 h-4" />
                {{ importing ? 'İçe Aktarılıyor...' : 'İçe Aktar' }}
              </button>
            </div>
          </div>
        </div>

        <!-- Import Progress -->
        <div v-if="importing" class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
          <div class="flex items-center gap-3 mb-2">
            <Loader2 class="w-5 h-5 animate-spin text-primary-600" />
            <span class="font-medium text-gray-900 dark:text-white">{{ importStatus }}</span>
          </div>
          <div class="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2">
            <div 
              class="bg-primary-600 h-2 rounded-full transition-all duration-300"
              :style="{ width: `${importProgress}%` }"
            ></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Imports -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
        <History class="w-5 h-5 text-blue-600" />
        Son İçe Aktarmalar
      </h2>
      
      <div v-if="importHistory.length === 0" class="text-center py-8 text-gray-500">
        Henüz içe aktarma yapılmadı
      </div>
      
      <div v-else class="space-y-3">
        <div 
          v-for="item in importHistory" 
          :key="item.id"
          class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700 rounded-lg"
        >
          <div class="flex items-center gap-3">
            <div :class="item.status === 'success' ? 'text-green-500' : 'text-red-500'">
              <CheckCircle v-if="item.status === 'success'" class="w-5 h-5" />
              <XCircle v-else class="w-5 h-5" />
            </div>
            <div>
              <p class="font-medium text-gray-900 dark:text-white">{{ item.filename }}</p>
              <p class="text-sm text-gray-500">{{ item.date }} - {{ item.records }} kayıt</p>
            </div>
          </div>
          <span 
            class="px-3 py-1 text-xs font-medium rounded-full"
            :class="item.status === 'success' 
              ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400' 
              : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'"
          >
            {{ item.status === 'success' ? 'Başarılı' : 'Hatalı' }}
          </span>
        </div>
      </div>
    </div>

    <!-- Brand List -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2">
          <Car class="w-5 h-5 text-purple-600" />
          Markalar
        </h2>
        <input
          v-model="brandSearch"
          type="text"
          placeholder="Marka ara..."
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
        />
      </div>
      
      <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
        <div 
          v-for="brand in filteredBrands" 
          :key="brand.id"
          class="p-3 bg-gray-50 dark:bg-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors cursor-pointer"
        >
          <div class="flex items-center gap-2">
            <img 
              v-if="brand.logo_url" 
              :src="brand.logo_url" 
              class="w-8 h-8 object-contain"
              :alt="brand.name"
            />
            <div v-else class="w-8 h-8 bg-gray-200 dark:bg-gray-600 rounded flex items-center justify-center text-xs font-bold text-gray-500">
              {{ brand.name.charAt(0) }}
            </div>
            <div>
              <p class="font-medium text-gray-900 dark:text-white text-sm">{{ brand.name }}</p>
              <p class="text-xs text-gray-500">{{ brand.series_count || 0 }} seri</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { 
  Car, Layers, Grid3x3, List, Settings, RefreshCw, FileSpreadsheet, 
  Upload, X, Eye, Download, Loader2, History, CheckCircle, XCircle 
} from 'lucide-vue-next'

interface CatalogStats {
  brands: number
  series: number
  models: number
  altModels: number
  trims: number
}

interface Brand {
  id: number
  name: string
  logo_url: string | null
  series_count?: number
}

interface ImportHistoryItem {
  id: number
  filename: string
  date: string
  records: number
  status: 'success' | 'error'
}

interface PreviewData {
  totalRows: number
  brands: number
  series: number
  models: number
}

const loading = ref(false)
const stats = ref<CatalogStats>({ brands: 0, series: 0, models: 0, altModels: 0, trims: 0 })
const brands = ref<Brand[]>([])
const brandSearch = ref('')
const importHistory = ref<ImportHistoryItem[]>([])

// File upload
const fileInput = ref<HTMLInputElement | null>(null)
const selectedFile = ref<File | null>(null)
const isDragging = ref(false)
const previewing = ref(false)
const importing = ref(false)
const importProgress = ref(0)
const importStatus = ref('')
const previewData = ref<PreviewData | null>(null)

const filteredBrands = computed(() => {
  if (!brandSearch.value) return brands.value
  const search = brandSearch.value.toLowerCase()
  return brands.value.filter(b => b.name.toLowerCase().includes(search))
})

const formatFileSize = (bytes: number): string => {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}

const fetchStats = async () => {
  try {
    const response = await $fetch('/api/admin/catalog/stats')
    stats.value = response.data
  } catch (error) {
    console.error('Failed to fetch stats:', error)
  }
}

const fetchBrands = async () => {
  try {
    const response = await $fetch('/api/admin/catalog/brands')
    brands.value = response.data || []
  } catch (error) {
    console.error('Failed to fetch brands:', error)
  }
}

const refreshStats = async () => {
  loading.value = true
  await Promise.all([fetchStats(), fetchBrands()])
  loading.value = false
}

const handleFileDrop = (event: DragEvent) => {
  isDragging.value = false
  const files = event.dataTransfer?.files
  if (files && files.length > 0) {
    selectedFile.value = files[0]
    previewData.value = null
  }
}

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    selectedFile.value = target.files[0]
    previewData.value = null
  }
}

const clearFile = () => {
  selectedFile.value = null
  previewData.value = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const previewFile = async () => {
  if (!selectedFile.value) return
  
  previewing.value = true
  try {
    const formData = new FormData()
    formData.append('file', selectedFile.value)
    formData.append('preview', 'true')
    
    const response = await $fetch('/api/admin/catalog/import', {
      method: 'POST',
      body: formData
    })
    
    previewData.value = response.data
  } catch (error) {
    console.error('Preview failed:', error)
    alert('Dosya analizi başarısız oldu')
  } finally {
    previewing.value = false
  }
}

const importFile = async () => {
  if (!selectedFile.value || !previewData.value) return
  
  importing.value = true
  importProgress.value = 0
  importStatus.value = 'Dosya yükleniyor...'
  
  try {
    const formData = new FormData()
    formData.append('file', selectedFile.value)
    
    // Simulate progress for UX
    const progressInterval = setInterval(() => {
      if (importProgress.value < 90) {
        importProgress.value += 10
        if (importProgress.value === 30) importStatus.value = 'Veriler işleniyor...'
        if (importProgress.value === 60) importStatus.value = 'Veritabanı güncelleniyor...'
        if (importProgress.value === 80) importStatus.value = 'Tamamlanıyor...'
      }
    }, 500)
    
    const response = await $fetch('/api/admin/catalog/import', {
      method: 'POST',
      body: formData
    })
    
    clearInterval(progressInterval)
    importProgress.value = 100
    importStatus.value = 'Tamamlandı!'
    
    // Add to history
    importHistory.value.unshift({
      id: Date.now(),
      filename: selectedFile.value.name,
      date: new Date().toLocaleString('tr-TR'),
      records: response.data.totalRecords,
      status: 'success'
    })
    
    // Refresh stats
    await refreshStats()
    
    // Clear file after success
    setTimeout(() => {
      clearFile()
      importing.value = false
    }, 1500)
    
  } catch (error) {
    console.error('Import failed:', error)
    importStatus.value = 'İçe aktarma başarısız!'
    
    importHistory.value.unshift({
      id: Date.now(),
      filename: selectedFile.value?.name || 'Bilinmeyen',
      date: new Date().toLocaleString('tr-TR'),
      records: 0,
      status: 'error'
    })
    
    setTimeout(() => {
      importing.value = false
    }, 2000)
  }
}

onMounted(() => {
  refreshStats()
})
</script>
