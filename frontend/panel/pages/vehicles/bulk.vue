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
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Toplu İşlemler</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Birden fazla aracı aynı anda yönetin</p>
      </div>
    </div>

    <!-- Steps -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <div class="flex items-center justify-between mb-8">
        <div
          v-for="(step, index) in steps"
          :key="index"
          class="flex items-center flex-1"
        >
          <div class="flex flex-col items-center flex-1">
            <div
              class="w-10 h-10 rounded-full flex items-center justify-center font-semibold transition-all"
              :class="currentStep > index 
                ? 'bg-primary-500 text-white' 
                : currentStep === index 
                ? 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 border-2 border-primary-500' 
                : 'bg-gray-100 dark:bg-gray-700 text-gray-400'"
            >
              {{ currentStep > index ? '✓' : index + 1 }}
            </div>
            <span class="mt-2 text-xs text-gray-600 dark:text-gray-400 text-center">{{ step }}</span>
          </div>
          <div
            v-if="index < steps.length - 1"
            class="flex-1 h-0.5 mx-2"
            :class="currentStep > index ? 'bg-primary-500' : 'bg-gray-200 dark:bg-gray-700'"
          ></div>
        </div>
      </div>

      <!-- Step 1: Upload -->
      <div v-if="currentStep === 0" class="space-y-6">
        <div class="border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-xl p-12 text-center hover:border-primary-500 transition-colors cursor-pointer">
          <Upload class="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2">Excel Dosyası Yükle</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-4">
            Araç bilgilerinizi içeren Excel dosyasını yükleyin
          </p>
          <input
            type="file"
            accept=".xlsx,.xls,.csv"
            @change="handleFileUpload"
            class="hidden"
            id="file-upload"
          />
          <label
            for="file-upload"
            class="inline-block px-6 py-3 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold cursor-pointer"
          >
            Dosya Seç
          </label>
          <p class="text-sm text-gray-500 dark:text-gray-400 mt-4">
            Desteklenen formatlar: .xlsx, .xls, .csv
          </p>
        </div>

        <div v-if="uploadedFile" class="p-4 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-800 rounded-lg">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <FileCheck class="w-5 h-5 text-green-600 dark:text-green-400" />
              <div>
                <div class="font-semibold text-green-900 dark:text-green-100">{{ uploadedFile.name }}</div>
                <div class="text-sm text-green-700 dark:text-green-300">{{ uploadedFile.size }} KB</div>
              </div>
            </div>
            <button
              @click="uploadedFile = null"
              class="text-red-600 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300"
            >
              <X class="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      <!-- Step 2: Preview -->
      <div v-if="currentStep === 1" class="space-y-6">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white">Önizleme</h3>
          <div class="text-sm text-gray-600 dark:text-gray-400">
            {{ previewData.length }} araç bulundu
          </div>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-gray-50 dark:bg-gray-700/50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">
                  <input type="checkbox" class="rounded" />
                </th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Marka</th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Model</th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Yıl</th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Km</th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Fiyat</th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Durum</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
              <tr
                v-for="(row, index) in previewData"
                :key="index"
                class="hover:bg-gray-50 dark:hover:bg-gray-700/50"
              >
                <td class="px-4 py-3">
                  <input type="checkbox" v-model="row.selected" class="rounded" />
                </td>
                <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">{{ row.brand }}</td>
                <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">{{ row.model }}</td>
                <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">{{ row.year }}</td>
                <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">{{ row.km }}</td>
                <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">{{ row.price }} ₺</td>
                <td class="px-4 py-3">
                  <span
                    class="px-2 py-1 text-xs font-semibold rounded-full"
                    :class="row.status === 'valid' 
                      ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' 
                      : 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400'"
                  >
                    {{ row.status === 'valid' ? 'Geçerli' : 'Hatalı' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Step 3: Confirm -->
      <div v-if="currentStep === 2" class="space-y-6">
        <div class="text-center">
          <CheckCircle class="w-16 h-16 text-green-500 mx-auto mb-4" />
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">İşlem Özeti</h3>
          <p class="text-gray-600 dark:text-gray-400">
            {{ selectedCount }} araç eklenecek
          </p>
        </div>
        <div class="grid grid-cols-3 gap-4">
          <div class="text-center p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
            <div class="text-2xl font-bold text-gray-900 dark:text-white">{{ selectedCount }}</div>
            <div class="text-sm text-gray-600 dark:text-gray-400">Seçilen</div>
          </div>
          <div class="text-center p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
            <div class="text-2xl font-bold text-gray-900 dark:text-white">{{ validCount }}</div>
            <div class="text-sm text-gray-600 dark:text-gray-400">Geçerli</div>
          </div>
          <div class="text-center p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
            <div class="text-2xl font-bold text-red-600 dark:text-red-400">{{ errorCount }}</div>
            <div class="text-sm text-gray-600 dark:text-gray-400">Hatalı</div>
          </div>
        </div>
      </div>

      <!-- Navigation -->
      <div class="flex items-center justify-between pt-6 border-t border-gray-200 dark:border-gray-700">
        <button
          v-if="currentStep > 0"
          @click="currentStep--"
          class="px-6 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold"
        >
          Geri
        </button>
        <div v-else></div>
        
        <button
          v-if="currentStep < steps.length - 1"
          @click="nextStep"
          :disabled="!canProceed"
          class="px-6 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
        >
          İleri
        </button>
        <button
          v-else
          @click="importVehicles"
          :disabled="loading"
          class="px-6 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ loading ? 'İçe Aktarılıyor...' : 'İçe Aktar' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft, Upload, FileCheck, X, CheckCircle } from 'lucide-vue-next'
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const currentStep = ref(0)
const loading = ref(false)
const uploadedFile = ref<File | null>(null)

const steps = ['Dosya Yükle', 'Önizleme', 'Onayla']

const previewData = ref([
  { selected: true, brand: 'BMW', model: '320i', year: 2020, km: 45000, price: 850000, status: 'valid' },
  { selected: true, brand: 'Mercedes', model: 'C200', year: 2019, km: 60000, price: 920000, status: 'valid' },
  { selected: false, brand: 'Audi', model: 'A4', year: 2021, km: 30000, price: 1150000, status: 'valid' },
  { selected: true, brand: '', model: 'Passat', year: 2018, km: 75000, price: 650000, status: 'invalid' }
])

const canProceed = computed(() => {
  if (currentStep.value === 0) return uploadedFile.value !== null
  if (currentStep.value === 1) return selectedCount.value > 0
  return true
})

const selectedCount = computed(() => previewData.value.filter(r => r.selected).length)
const validCount = computed(() => previewData.value.filter(r => r.selected && r.status === 'valid').length)
const errorCount = computed(() => previewData.value.filter(r => r.selected && r.status === 'invalid').length)

const handleFileUpload = async (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    uploadedFile.value = target.files[0]
    
    try {
      const formData = new FormData()
      formData.append('file', target.files[0])
      
      const api = useApi()
      const response = await api.post('/vehicles/bulk/parse', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      })
      
      previewData.value = response.data.map((row: any) => ({
        ...row,
        selected: true,
        status: row.valid ? 'valid' : 'invalid'
      }))
      
      nextStep()
    } catch (error: any) {
      alert('Dosya yüklenirken hata oluştu: ' + error.message)
    }
  }
}

const nextStep = () => {
  if (currentStep.value < steps.length - 1) {
    currentStep.value++
  }
}

const importVehicles = async () => {
  loading.value = true
  try {
    const selected = previewData.value.filter(r => r.selected && r.status === 'valid')
    
    const api = useApi()
    const response = await api.post('/vehicles/bulk/import', {
      vehicles: selected.map(r => ({
        brand: r.brand,
        model: r.model,
        year: r.year,
        km: r.km,
        price: r.price
      }))
    })
    
    alert(`${response.count} araç başarıyla eklendi!`)
    router.push('/vehicles')
  } catch (error: any) {
    alert('Hata: ' + error.message)
  } finally {
    loading.value = false
  }
}
</script>

