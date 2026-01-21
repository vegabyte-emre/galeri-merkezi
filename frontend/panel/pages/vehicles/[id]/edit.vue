<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <NuxtLink
          to="/vehicles"
          class="text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 mb-2 inline-flex items-center gap-1"
        >
          <ArrowLeft class="w-4 h-4" />
          Araçlara Dön
        </NuxtLink>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
          Araç Düzenle
        </h1>
      </div>
      <!-- İlan Bilgileri -->
      <div v-if="form.listingNumber" class="text-right">
        <p class="text-sm text-gray-500 dark:text-gray-400">İlan No: <span class="font-semibold text-gray-900 dark:text-white">{{ form.listingNumber }}</span></p>
        <p class="text-xs text-gray-400">{{ form.listingDate }}</p>
      </div>
    </div>

    <form @submit.prevent="saveVehicle" class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Main Form -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Vehicle Selection - Hierarchical -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <Car class="w-5 h-5 text-primary-500" />
            Araç Seçimi
          </h2>
          <div class="grid grid-cols-4 gap-4">
            <!-- Brand Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Marka *
              </label>
              <div class="relative">
                <select 
                  v-model="selectedBrandId" 
                  @change="onBrandChange"
                  required 
                  class="input-field"
                  :disabled="loadingBrands"
                >
                  <option value="">{{ loadingBrands ? 'Yükleniyor...' : 'Marka Seçin' }}</option>
                  <optgroup v-if="popularBrands.length > 0" label="Popüler Markalar">
                    <option v-for="brand in popularBrands" :key="brand.id" :value="brand.id">
                      {{ brand.name }}
                    </option>
                  </optgroup>
                  <optgroup label="Tüm Markalar">
                    <option v-for="brand in otherBrands" :key="brand.id" :value="brand.id">
                      {{ brand.name }}
                    </option>
                  </optgroup>
                </select>
              </div>
            </div>

            <!-- Year Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Yıl *
              </label>
              <div class="relative">
                <select 
                  v-model="selectedYear" 
                  @change="onYearChange"
                  required 
                  class="input-field"
                  :disabled="!selectedBrandId || loadingYears"
                >
                  <option value="">{{ loadingYears ? 'Yükleniyor...' : (selectedBrandId ? 'Yıl Seçin' : 'Önce marka seçin') }}</option>
                  <option v-for="year in years" :key="year" :value="year">
                    {{ year }}
                  </option>
                </select>
              </div>
            </div>

            <!-- Model Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Model *
              </label>
              <div class="relative">
                <select 
                  v-model="selectedModelId" 
                  @change="onModelChange"
                  required 
                  class="input-field"
                  :disabled="!selectedYear || loadingModels"
                >
                  <option value="">{{ loadingModels ? 'Yükleniyor...' : (selectedYear ? 'Model Seçin' : 'Önce yıl seçin') }}</option>
                  <option v-for="model in models" :key="model.id" :value="model.id">
                    {{ model.name }}
                  </option>
                </select>
              </div>
            </div>

            <!-- Engine/Variant Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Motor/Versiyon
              </label>
              <div class="relative">
                <select 
                  v-model="selectedEngineId" 
                  @change="onEngineChange"
                  class="input-field"
                  :disabled="!selectedModelId || loadingEngines"
                >
                  <option value="">{{ loadingEngines ? 'Yükleniyor...' : (selectedModelId ? 'Versiyon Seçin (Opsiyonel)' : 'Önce model seçin') }}</option>
                  <option v-for="engine in engines" :key="engine.id" :value="engine.id">
                    {{ engine.name }}
                  </option>
                </select>
              </div>
            </div>
          </div>
          
          <!-- Selected Vehicle Info -->
          <div v-if="selectedBrand" class="mt-4 p-4 bg-primary-50 dark:bg-primary-900/20 rounded-xl">
            <div class="flex items-center gap-4">
              <img 
                v-if="selectedBrand.logo_url" 
                :src="selectedBrand.logo_url" 
                :alt="selectedBrand.name"
                class="w-12 h-12 object-contain"
              />
              <div>
                <p class="font-semibold text-gray-900 dark:text-white">
                  {{ selectedBrand.name }} {{ selectedYear ? selectedYear + ' ' : '' }}{{ selectedModel?.name || '' }}
                </p>
                <p v-if="selectedEngine" class="text-sm text-gray-600 dark:text-gray-400">
                  {{ selectedEngine.name }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Basic Info -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <DollarSign class="w-5 h-5 text-primary-500" />
            Fiyat ve Durum
          </h2>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Fiyat *
              </label>
              <div class="relative">
                <input v-model.number="form.basePrice" type="number" required min="0" class="input-field pr-16" placeholder="1.500.000" />
                <span class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 font-medium">₺</span>
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Yıl *
              </label>
              <input v-model.number="form.year" type="number" required min="1900" :max="new Date().getFullYear() + 1" class="input-field" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Yakıt Tipi *
              </label>
              <select v-model="form.fuelType" required class="input-field">
                <option value="">Seçiniz</option>
                <option value="Benzin">Benzin</option>
                <option value="Dizel">Dizel</option>
                <option value="Elektrik">Elektrik</option>
                <option value="Hibrit">Hibrit</option>
                <option value="LPG">LPG</option>
                <option value="Benzin + LPG">Benzin + LPG</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Vites *
              </label>
              <select v-model="form.transmission" required class="input-field">
                <option value="">Seçiniz</option>
                <option value="Manuel">Manuel</option>
                <option value="Otomatik">Otomatik</option>
                <option value="Yarı Otomatik">Yarı Otomatik</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Araç Durumu *
              </label>
              <select v-model="form.vehicleCondition" required class="input-field">
                <option value="">Seçiniz</option>
                <option value="Sıfır">Sıfır</option>
                <option value="2. El">2. El</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Kilometre *
              </label>
              <input v-model.number="form.mileage" type="number" required min="0" class="input-field" placeholder="50.000" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Kasa Tipi *
              </label>
              <select v-model="form.bodyType" required class="input-field">
                <option value="">Seçiniz</option>
                <option value="Sedan">Sedan</option>
                <option value="Hatchback">Hatchback</option>
                <option value="SUV">SUV</option>
                <option value="Coupe">Coupe</option>
                <option value="Cabrio">Cabrio</option>
                <option value="Station">Station Wagon</option>
                <option value="Pickup">Pickup</option>
                <option value="MPV">MPV</option>
                <option value="Crossover">Crossover</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Technical Details -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <Settings class="w-5 h-5 text-primary-500" />
            Teknik Özellikler
          </h2>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Motor Gücü (HP)
              </label>
              <input v-model.number="form.enginePower" type="number" class="input-field" placeholder="184" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Motor Hacmi (cc)
              </label>
              <input v-model.number="form.engineCc" type="number" class="input-field" placeholder="2000" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Çekiş
              </label>
              <select v-model="form.drivetrain" class="input-field">
                <option value="">Seçiniz</option>
                <option value="Önden Çekiş">Önden Çekiş</option>
                <option value="Arkadan İtiş">Arkadan İtiş</option>
                <option value="4x4 (Sürekli)">4x4 (Sürekli)</option>
                <option value="4x4 (Yarı Zamanlı)">4x4 (Yarı Zamanlı)</option>
                <option value="AWD">AWD</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Renk *
              </label>
              <select v-model="form.color" required class="input-field">
                <option value="">Seçiniz</option>
                <option value="Siyah">Siyah</option>
                <option value="Beyaz">Beyaz</option>
                <option value="Gri">Gri</option>
                <option value="Gümüş">Gümüş</option>
                <option value="Lacivert">Lacivert</option>
                <option value="Mavi">Mavi</option>
                <option value="Kırmızı">Kırmızı</option>
                <option value="Bordo">Bordo</option>
                <option value="Kahverengi">Kahverengi</option>
                <option value="Bej">Bej</option>
                <option value="Yeşil">Yeşil</option>
                <option value="Turuncu">Turuncu</option>
                <option value="Sarı">Sarı</option>
                <option value="Mor">Mor</option>
                <option value="Diğer">Diğer</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Additional Info -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <FileText class="w-5 h-5 text-primary-500" />
            Ek Bilgiler
          </h2>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Ağır Hasar Kayıtlı *
              </label>
              <select v-model="form.heavyDamageRecord" required class="input-field">
                <option :value="false">Hayır</option>
                <option :value="true">Evet</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Uyruk (Plaka) *
              </label>
              <select v-model="form.plateOrigin" required class="input-field">
                <option value="">Seçiniz</option>
                <option value="Türkiye">Türkiye</option>
                <option value="Yabancı">Yabancı</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Takas *
              </label>
              <select v-model="form.tradeInAcceptable" required class="input-field">
                <option :value="false">Hayır</option>
                <option :value="true">Evet</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Garanti
              </label>
              <select v-model="form.hasWarranty" class="input-field">
                <option :value="false">Hayır</option>
                <option :value="true">Evet</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Description -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <FileText class="w-5 h-5 text-primary-500" />
            Açıklama
          </h2>
          <textarea
            v-model="form.description"
            rows="6"
            class="input-field"
            placeholder="Araç hakkında detaylı açıklama yazın..."
          ></textarea>
        </div>

        <!-- Actions -->
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <!-- Status Actions -->
            <button
              v-if="vehicleStatus === 'draft'"
              type="button"
              @click="publishVehicle"
              :disabled="loading"
              class="px-4 py-2.5 bg-green-500 text-white font-semibold rounded-xl hover:bg-green-600 transition-all disabled:opacity-50 flex items-center gap-2"
            >
              <Play class="w-4 h-4" />
              Yayınla
            </button>
            <button
              v-if="vehicleStatus === 'published'"
              type="button"
              @click="pauseVehicle"
              :disabled="loading"
              class="px-4 py-2.5 bg-yellow-500 text-white font-semibold rounded-xl hover:bg-yellow-600 transition-all disabled:opacity-50 flex items-center gap-2"
            >
              <Pause class="w-4 h-4" />
              Duraklat
            </button>
            <button
              v-if="vehicleStatus === 'paused'"
              type="button"
              @click="publishVehicle"
              :disabled="loading"
              class="px-4 py-2.5 bg-green-500 text-white font-semibold rounded-xl hover:bg-green-600 transition-all disabled:opacity-50 flex items-center gap-2"
            >
              <Play class="w-4 h-4" />
              Tekrar Yayınla
            </button>
            <button
              v-if="vehicleStatus !== 'sold' && vehicleStatus !== 'archived'"
              type="button"
              @click="markAsSold"
              :disabled="loading"
              class="px-4 py-2.5 bg-blue-500 text-white font-semibold rounded-xl hover:bg-blue-600 transition-all disabled:opacity-50 flex items-center gap-2"
            >
              <Check class="w-4 h-4" />
              Satıldı
            </button>
          </div>
          <div class="flex items-center gap-3">
            <NuxtLink
              to="/vehicles"
              class="px-6 py-3 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-xl hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold"
            >
              İptal
            </NuxtLink>
            <button
              type="submit"
              :disabled="loading"
              class="px-6 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-xl hover:shadow-lg transition-all disabled:opacity-50"
            >
              {{ loading ? 'Kaydediliyor...' : 'Güncelle' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="space-y-6">
        <!-- Photo Upload -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <ImageIcon class="w-5 h-5 text-primary-500" />
            Fotoğraflar
          </h3>
          <div class="grid grid-cols-2 gap-3 mb-4">
            <div
              v-for="i in 6"
              :key="i"
              class="aspect-square bg-gray-100 dark:bg-gray-700 rounded-xl flex items-center justify-center border-2 border-dashed border-gray-300 dark:border-gray-600 cursor-pointer hover:border-primary-500 hover:bg-primary-50 dark:hover:bg-primary-900/20 transition-all group"
            >
              <div class="text-center">
                <Upload class="w-6 h-6 text-gray-400 group-hover:text-primary-500 mx-auto mb-1" />
                <span class="text-xs text-gray-400 group-hover:text-primary-500">{{ i === 1 ? 'Ana Foto' : 'Foto ' + i }}</span>
              </div>
            </div>
          </div>
          <button type="button" class="w-full px-4 py-2.5 bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 rounded-xl hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold">
            Fotoğraf Yükle
          </button>
        </div>

        <!-- İlan Bilgileri -->
        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl p-6 text-white">
          <h3 class="text-lg font-bold mb-3">İlan Bilgileri</h3>
          <div class="space-y-3 text-sm">
            <div class="flex justify-between">
              <span class="opacity-80">İlan No:</span>
              <span class="font-semibold">{{ form.listingNumber || '-' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="opacity-80">İlan Tarihi:</span>
              <span class="font-semibold">{{ form.listingDate || '-' }}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="opacity-80">Durum:</span>
              <span 
                class="px-2 py-1 rounded-full text-xs font-semibold"
                :class="{
                  'bg-green-400/30 text-green-100': vehicleStatus === 'published',
                  'bg-gray-400/30 text-gray-100': vehicleStatus === 'draft',
                  'bg-yellow-400/30 text-yellow-100': vehicleStatus === 'paused',
                  'bg-blue-400/30 text-blue-100': vehicleStatus === 'sold',
                  'bg-red-400/30 text-red-100': vehicleStatus === 'archived'
                }"
              >
                {{ statusLabels[vehicleStatus] || vehicleStatus }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft, Upload, Car, Settings, FileText, Image as ImageIcon, DollarSign, Play, Pause, Check } from 'lucide-vue-next'
import { reactive, ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

interface Brand {
  id: number
  name: string
  logo_url: string
  is_popular: boolean
}

interface Model {
  id: number
  name: string
  original_name?: string
  year_start: number | null
  year_end: number | null
  body_type: string | null
  engine_count: number
}

interface Engine {
  id: number
  name: string
  cylinders: string | null
  displacement_cc: number | null
  power_hp: number | null
  torque_nm: number | null
  fuel_type: string | null
  drive_type: string | null
  gearbox: string | null
}

const route = useRoute()
const router = useRouter()
const api = useApi()
const toast = useToast()

const vehicleId = route.params.id as string
const loading = ref(false)
const vehicleStatus = ref<string>('draft')
const loadingBrands = ref(false)
const loadingYears = ref(false)
const loadingModels = ref(false)
const loadingEngines = ref(false)

// Catalog data
const brands = ref<Brand[]>([])
const years = ref<number[]>([])
const models = ref<Model[]>([])
const engines = ref<Engine[]>([])

// Selection state
const selectedBrandId = ref<number | ''>('')
const selectedYear = ref<number | ''>('')
const selectedModelId = ref<number | ''>('')
const selectedEngineId = ref<number | ''>('')

// Status labels
const statusLabels: Record<string, string> = {
  published: 'Yayında',
  draft: 'Taslak',
  paused: 'Duraklatıldı',
  archived: 'Arşivlendi',
  sold: 'Satıldı'
}

// Computed properties
const popularBrands = computed(() => brands.value.filter(b => b.is_popular))
const otherBrands = computed(() => brands.value.filter(b => !b.is_popular))
const selectedBrand = computed(() => brands.value.find(b => b.id === selectedBrandId.value))
const selectedModel = computed(() => models.value.find(m => m.id === selectedModelId.value))
const selectedEngine = computed(() => engines.value.find(e => e.id === selectedEngineId.value))

const formatDate = (date: Date) => {
  return date.toLocaleDateString('tr-TR', { 
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const form = reactive({
  listingNumber: '',
  listingDate: '',
  brand: '',
  series: '',
  model: '',
  year: new Date().getFullYear(),
  mileage: null as number | null,
  plateNumber: '',
  fuelType: '',
  transmission: '',
  bodyType: '',
  color: '',
  enginePower: null as number | null,
  engineCc: null as number | null,
  drivetrain: '',
  vehicleCondition: '2. El',
  basePrice: null as number | null,
  sellerType: 'gallery',
  hasWarranty: false,
  tradeInAcceptable: false,
  heavyDamageRecord: false,
  plateOrigin: 'Türkiye',
  description: ''
})

// Load brands
const loadBrands = async () => {
  loadingBrands.value = true
  try {
    const response = await api.get<{ success: boolean; data: Brand[] }>('/catalog/brands')
    if (response.success) {
      brands.value = response.data
    }
  } catch (error: any) {
    console.error('Markalar yüklenemedi:', error)
    toast.error('Markalar yüklenemedi')
  } finally {
    loadingBrands.value = false
  }
}

// Load years when brand changes - extract years from model names
const onBrandChange = async () => {
  selectedYear.value = ''
  selectedModelId.value = ''
  selectedEngineId.value = ''
  years.value = []
  models.value = []
  engines.value = []
  
  if (!selectedBrandId.value) return
  
  // Update form brand
  form.brand = selectedBrand.value?.name || ''
  
  loadingYears.value = true
  try {
    // First, get all models for this brand
    const modelsResponse = await api.get<{ success: boolean; data: Model[] }>(`/catalog/brands/${selectedBrandId.value}/models`)
    if (modelsResponse.success && modelsResponse.data) {
      // Extract years from model names (format: "2025 Audi A3" -> 2025)
      const extractedYears = new Set<number>()
      
      modelsResponse.data.forEach((model: Model) => {
        // Extract year from model name using regex (e.g., "2025 Audi A3" -> 2025)
        const yearMatch = model.name.match(/^(\d{4})\s+/)
        if (yearMatch && yearMatch[1]) {
          const year = parseInt(yearMatch[1], 10)
          if (year >= 1900 && year <= new Date().getFullYear() + 1) {
            extractedYears.add(year)
          }
        }
      })
      
      // Convert Set to Array and sort descending (newest first)
      years.value = Array.from(extractedYears).sort((a, b) => b - a)
    }
  } catch (error: any) {
    console.error('Yıllar yüklenemedi:', error)
    toast.error('Yıllar yüklenemedi')
  } finally {
    loadingYears.value = false
  }
}

// Load models when year changes - filter models by selected year
const onYearChange = async () => {
  selectedModelId.value = ''
  selectedEngineId.value = ''
  models.value = []
  engines.value = []
  
  if (!selectedBrandId.value || !selectedYear.value) return
  
  loadingModels.value = true
  try {
    // Get all models for this brand
    const modelsResponse = await api.get<{ success: boolean; data: Model[] }>(`/catalog/brands/${selectedBrandId.value}/models`)
    if (modelsResponse.success && modelsResponse.data) {
      // Filter models by selected year and remove year prefix from name
      const yearStr = String(selectedYear.value)
      models.value = modelsResponse.data
        .filter((model: Model) => {
          // Check if model name starts with selected year
          return model.name.startsWith(yearStr + ' ')
        })
        .map((model: Model) => {
          // Remove year prefix from model name (e.g., "2025 Audi A3" -> "Audi A3")
          return {
            ...model,
            name: model.name.replace(/^\d{4}\s+/, ''),
            original_name: model.name
          }
        })
    }
  } catch (error: any) {
    console.error('Modeller yüklenemedi:', error)
    toast.error('Modeller yüklenemedi')
  } finally {
    loadingModels.value = false
  }
}

// Load engines when model changes
const onModelChange = async () => {
  selectedEngineId.value = ''
  engines.value = []
  
  if (!selectedModelId.value) return
  
  // Update form model (use original_name if available, otherwise name)
  const modelName = selectedModel.value?.original_name || selectedModel.value?.name || ''
  form.model = modelName
  
  // Set body type if available
  if (selectedModel.value?.body_type) {
    form.bodyType = selectedModel.value.body_type
  }
  
  // Set year from selected year
  if (selectedYear.value) {
    form.year = Number(selectedYear.value)
  }
  
  loadingEngines.value = true
  try {
    const response = await api.get<{ success: boolean; data: Engine[] }>(`/catalog/models/${selectedModelId.value}/engines`)
    if (response.success) {
      engines.value = response.data
    }
  } catch (error: any) {
    console.error('Motor seçenekleri yüklenemedi:', error)
  } finally {
    loadingEngines.value = false
  }
}

// Auto-fill form when engine is selected
const onEngineChange = () => {
  if (!selectedEngineId.value) return
  
  const engine = selectedEngine.value
  if (!engine) return
  
  // Auto-fill technical specs from engine data
  if (engine.power_hp) form.enginePower = engine.power_hp
  if (engine.displacement_cc) form.engineCc = engine.displacement_cc
  if (engine.fuel_type) form.fuelType = engine.fuel_type
  if (engine.drive_type) form.drivetrain = engine.drive_type
  
  // Parse transmission from gearbox
  if (engine.gearbox) {
    const gearbox = engine.gearbox.toLowerCase()
    if (gearbox.includes('automatic') || gearbox.includes('otomatik')) {
      form.transmission = 'Otomatik'
    } else if (gearbox.includes('manual') || gearbox.includes('manuel')) {
      form.transmission = 'Manuel'
    }
  }
  
  // Update series from engine name if it contains it
  form.series = engine.name
}

// Find brand ID by name
const findBrandIdByName = (brandName: string): number | null => {
  const brand = brands.value.find(b => 
    b.name.toUpperCase() === brandName.toUpperCase() ||
    b.name.toUpperCase().includes(brandName.toUpperCase()) ||
    brandName.toUpperCase().includes(b.name.toUpperCase())
  )
  return brand ? brand.id : null
}

onMounted(async () => {
  await loadBrands()
  
  if (vehicleId) {
    try {
      loading.value = true
      const response = await api.get<{ success: boolean; data: any }>(`/vehicles/${vehicleId}`)
      if (response.success && response.data) {
        const v = response.data
        form.listingNumber = v.listing_no || ''
        form.listingDate = v.created_at ? formatDate(new Date(v.created_at)) : ''
        form.brand = v.brand || ''
        form.series = v.series || ''
        form.model = v.model || ''
        form.year = v.year || new Date().getFullYear()
        form.mileage = v.mileage
        form.plateNumber = v.plate_number || ''
        form.fuelType = v.fuel_type || ''
        form.transmission = v.transmission || ''
        form.bodyType = v.body_type || ''
        form.color = v.color || ''
        form.enginePower = v.engine_power
        form.engineCc = v.engine_cc
        form.drivetrain = v.drivetrain || ''
        form.vehicleCondition = v.vehicle_condition || '2. El'
        form.basePrice = v.base_price
        form.sellerType = v.seller_type || 'gallery'
        form.hasWarranty = v.has_warranty || false
        form.tradeInAcceptable = v.trade_in_acceptable || false
        form.heavyDamageRecord = v.heavy_damage_record || false
        form.plateOrigin = v.plate_nationality === 'TR' ? 'Türkiye' : 'Yabancı'
        form.description = v.description || ''
        vehicleStatus.value = v.status || 'draft'
        
        // Try to set brand and year from existing data
        if (v.brand) {
          const brandId = findBrandIdByName(v.brand)
          if (brandId) {
            selectedBrandId.value = brandId
            await onBrandChange()
            
            // Set year if available
            if (v.year && years.value.includes(v.year)) {
              selectedYear.value = v.year
              await onYearChange()
              
              // Try to find and set model
              // This is tricky as we need to match the model name
              // For now, we'll just set the year
            }
          }
        }
      }
    } catch (error: any) {
      toast.error('Araç bilgileri yüklenemedi: ' + error.message)
      router.push('/vehicles')
    } finally {
      loading.value = false
    }
  }
})

const saveVehicle = async () => {
  if (!form.brand || !form.model || !form.year || !form.mileage || !form.basePrice || !form.fuelType || !form.transmission || !form.vehicleCondition || !form.bodyType || !form.color) {
    toast.error('Lütfen zorunlu alanları doldurun')
    return
  }

  loading.value = true
  try {
    await api.put(`/vehicles/${vehicleId}`, form)
    toast.success('Araç başarıyla güncellendi')
    router.push('/vehicles')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    loading.value = false
  }
}

// Yayınla
const publishVehicle = async () => {
  loading.value = true
  try {
    await api.post(`/vehicles/${vehicleId}/publish`)
    vehicleStatus.value = 'published'
    toast.success('Araç yayınlandı!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    loading.value = false
  }
}

// Duraklat
const pauseVehicle = async () => {
  loading.value = true
  try {
    await api.post(`/vehicles/${vehicleId}/pause`)
    vehicleStatus.value = 'paused'
    toast.success('Araç duraklatıldı')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    loading.value = false
  }
}

// Satıldı olarak işaretle
const markAsSold = async () => {
  if (!confirm('Bu aracı satıldı olarak işaretlemek istediğinize emin misiniz?')) return
  
  loading.value = true
  try {
    await api.post(`/vehicles/${vehicleId}/sold`)
    vehicleStatus.value = 'sold'
    toast.success('Araç satıldı olarak işaretlendi')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.input-field {
  @apply w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all;
}
</style>






