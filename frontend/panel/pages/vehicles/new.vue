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
          Araclara Don
        </NuxtLink>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
          Yeni Arac Ekle
        </h1>
      </div>
      <!-- Ilan Bilgileri -->
      <div v-if="form.listingNumber" class="text-right">
        <p class="text-sm text-gray-500 dark:text-gray-400">Ilan No: <span class="font-semibold text-gray-900 dark:text-white">{{ form.listingNumber }}</span></p>
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
            Arac Secimi
          </h2>
          
          <!-- Row 1: Sinif, Marka, Seri -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4">
            <!-- Sinif Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Sinif *
              </label>
              <select 
                v-model="selectedClassId" 
                @change="onClassChange"
                required 
                class="input-field"
                :disabled="loadingClasses"
              >
                <option value="">{{ loadingClasses ? 'Yukleniyor...' : 'Sinif Secin' }}</option>
                <option v-for="cls in classes" :key="cls.id" :value="cls.id">
                  {{ cls.name }}
                </option>
              </select>
            </div>

            <!-- Marka Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Marka *
              </label>
              <select 
                v-model="selectedBrandId" 
                @change="onBrandChange"
                required 
                class="input-field"
                :disabled="!selectedClassId || loadingBrands"
              >
                <option value="">{{ loadingBrands ? 'Yukleniyor...' : (selectedClassId ? 'Marka Secin' : 'Once sinif secin') }}</option>
                <optgroup v-if="popularBrands.length > 0" label="Populer Markalar">
                  <option v-for="brand in popularBrands" :key="'pop-' + brand.id" :value="brand.id">
                    {{ brand.name }}
                  </option>
                </optgroup>
                <optgroup v-if="otherBrands.length > 0" label="Tum Markalar">
                  <option v-for="brand in otherBrands" :key="'other-' + brand.id" :value="brand.id">
                    {{ brand.name }}
                  </option>
                </optgroup>
              </select>
            </div>

            <!-- Seri Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Seri *
              </label>
              <select 
                v-model="selectedSeriesId" 
                @change="onSeriesChange"
                required 
                class="input-field"
                :disabled="!selectedBrandId || loadingSeries"
              >
                <option value="">{{ loadingSeries ? 'Yukleniyor...' : (selectedBrandId ? 'Seri Secin' : 'Once marka secin') }}</option>
                <option v-for="s in series" :key="s.id" :value="s.id">
                  {{ s.name }}
                </option>
              </select>
            </div>
          </div>

          <!-- Row 2: Model, Alt Model, Trim -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <!-- Model Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Model *
              </label>
              <select 
                v-model="selectedModelId" 
                @change="onModelChange"
                required 
                class="input-field"
                :disabled="!selectedSeriesId || loadingModels"
              >
                <option value="">{{ loadingModels ? 'Yukleniyor...' : (selectedSeriesId ? 'Model Secin' : 'Once seri secin') }}</option>
                <option v-for="m in models" :key="m.id" :value="m.id">
                  {{ m.name }}
                </option>
              </select>
            </div>

            <!-- Alt Model Selection -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Alt Model
              </label>
              <select 
                v-model="selectedAltModelId" 
                @change="onAltModelChange"
                class="input-field"
                :disabled="!selectedModelId || loadingAltModels"
              >
                <option value="">{{ loadingAltModels ? 'Yukleniyor...' : (selectedModelId ? 'Alt Model Secin (Opsiyonel)' : 'Once model secin') }}</option>
                <option v-for="am in altModels" :key="am.id" :value="am.id">
                  {{ am.name }}
                </option>
              </select>
            </div>

            <!-- Trim Selection - Alt Model secildikten sonra goster -->
            <div v-if="showTrimField">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Trim/Paket {{ requiresTrimSelection ? '*' : '' }}
              </label>
              <!-- Birden fazla trim varsa dropdown goster -->
              <template v-if="requiresTrimSelection && trims.length > 1">
                <select 
                  v-model="selectedTrimId" 
                  @change="onTrimChange"
                  required
                  class="input-field"
                  :disabled="loadingTrims"
                >
                  <option value="">{{ loadingTrims ? 'Yukleniyor...' : 'Trim Secin' }}</option>
                  <option v-for="t in trims" :key="t.id" :value="t.id">
                    {{ t.name || 'Standart' }}
                  </option>
                </select>
              </template>
              <!-- Tek trim varsa adini goster -->
              <template v-else-if="autoFilledTrimName">
                <div class="input-field bg-green-50 dark:bg-green-900/20 text-green-700 dark:text-green-400 flex items-center gap-2">
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path></svg>
                  {{ autoFilledTrimName }}
                </div>
              </template>
              <!-- Trim yok, sadece otomatik dolduruldu -->
              <template v-else>
                <div class="input-field bg-green-50 dark:bg-green-900/20 text-green-700 dark:text-green-400 flex items-center gap-2">
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path></svg>
                  Standart
                </div>
              </template>
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
              <div class="w-12 h-12 bg-primary-100 dark:bg-primary-800 rounded-full flex items-center justify-center" v-else>
                <Car class="w-6 h-6 text-primary-600 dark:text-primary-400" />
              </div>
              <div>
                <p class="font-semibold text-gray-900 dark:text-white">
                  {{ selectedBrand?.name }} {{ selectedSeries?.name || '' }} {{ selectedModel?.name || '' }}
                </p>
                <p v-if="selectedAltModel" class="text-sm text-gray-600 dark:text-gray-400">
                  {{ selectedAltModel.name }}
                </p>
                <p v-if="selectedTrim && selectedTrim.name" class="text-xs text-primary-600 dark:text-primary-400">
                  {{ selectedTrim.name }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Technical Details (Auto-filled) -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <Settings class="w-5 h-5 text-primary-500" />
            Teknik Ozellikler
            <span v-if="autoFilledSpecs" class="text-xs bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 px-2 py-0.5 rounded-full ml-2">
              Otomatik Dolduruldu
            </span>
          </h2>
          <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Kasa Tipi *
              </label>
              <select v-model="form.bodyType" required class="input-field">
                <option value="">Seciniz</option>
                <option v-for="bt in bodyTypes" :key="bt.value" :value="bt.value">{{ bt.label }}</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Yakit Tipi *
              </label>
              <select v-model="form.fuelType" required class="input-field">
                <option value="">Seciniz</option>
                <option v-for="ft in fuelTypes" :key="ft.value" :value="ft.value">{{ ft.label }}</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Vites *
              </label>
              <select v-model="form.transmission" required class="input-field">
                <option value="">Seciniz</option>
                <option v-for="t in transmissions" :key="t.value" :value="t.value">{{ t.label }}</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Motor Gucu (HP)
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
                Renk *
              </label>
              <select v-model="form.color" required class="input-field">
                <option value="">Seciniz</option>
                <option v-for="c in colors" :key="c.value" :value="c.value">{{ c.label }}</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Price and Condition -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <DollarSign class="w-5 h-5 text-primary-500" />
            Fiyat ve Durum
          </h2>
          <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Fiyat *
              </label>
              <div class="relative">
                <input v-model.number="form.basePrice" type="number" required min="0" class="input-field pr-16" placeholder="1.500.000" />
                <span class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 font-medium">TL</span>
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Kilometre *
              </label>
              <input v-model.number="form.mileage" type="number" required min="0" class="input-field" placeholder="50.000" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Yil *
              </label>
              <input v-model.number="form.year" type="number" required min="1900" :max="new Date().getFullYear() + 1" class="input-field" placeholder="2024" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Arac Durumu *
              </label>
              <select v-model="form.vehicleCondition" required class="input-field">
                <option value="">Seciniz</option>
                <option value="Sifir">Sifir</option>
                <option value="2. El">2. El</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Agir Hasar Kayitli *
              </label>
              <select v-model="form.heavyDamageRecord" required class="input-field">
                <option :value="false">Hayir</option>
                <option :value="true">Evet</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Takas *
              </label>
              <select v-model="form.tradeInAcceptable" required class="input-field">
                <option :value="false">Hayir</option>
                <option :value="true">Evet</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Description -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <FileText class="w-5 h-5 text-primary-500" />
            Aciklama
          </h2>
          <textarea
            v-model="form.description"
            rows="6"
            class="input-field"
            placeholder="Arac hakkinda detayli aciklama yazin..."
          ></textarea>
        </div>

        <!-- Actions -->
        <div class="flex items-center justify-end gap-3">
          <NuxtLink
            to="/vehicles"
            class="px-6 py-3 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-xl hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold"
          >
            Iptal
          </NuxtLink>
          <button
            type="button"
            @click="saveVehicle('draft')"
            :disabled="loading"
            class="px-6 py-3 bg-gray-600 text-white font-semibold rounded-xl hover:bg-gray-700 transition-all disabled:opacity-50"
          >
            Taslak Kaydet
          </button>
          <button
            type="submit"
            :disabled="loading"
            class="px-6 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-xl hover:shadow-lg transition-all disabled:opacity-50"
          >
            {{ loading ? 'Kaydediliyor...' : 'Kaydet ve Onaya Gönder' }}
          </button>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="space-y-6">
        <!-- Photo Upload -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <ImageIcon class="w-5 h-5 text-primary-500" />
            Fotograflar
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
            Fotograf Yukle
          </button>
        </div>

        <!-- Video Upload & Oto Shorts -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <Video class="w-5 h-5 text-rose-500" />
            Arac Videosu
            <span class="text-xs bg-rose-100 dark:bg-rose-900/30 text-rose-600 dark:text-rose-400 px-2 py-0.5 rounded-full ml-auto">
              Oto Shorts
            </span>
          </h3>
          
          <!-- Video Upload Area -->
          <div 
            v-if="!videoFile && !videoPreviewUrl"
            @click="triggerVideoUpload"
            @dragover.prevent="videoDragOver = true"
            @dragleave.prevent="videoDragOver = false"
            @drop.prevent="handleVideoDrop"
            class="aspect-video bg-gray-100 dark:bg-gray-700 rounded-xl flex flex-col items-center justify-center border-2 border-dashed cursor-pointer transition-all mb-4"
            :class="videoDragOver ? 'border-rose-500 bg-rose-50 dark:bg-rose-900/20' : 'border-gray-300 dark:border-gray-600 hover:border-rose-500 hover:bg-rose-50 dark:hover:bg-rose-900/20'"
          >
            <Video class="w-10 h-10 text-gray-400 mb-2" :class="videoDragOver ? 'text-rose-500' : ''" />
            <span class="text-sm text-gray-500 dark:text-gray-400 font-medium">Video Yukle</span>
            <span class="text-xs text-gray-400 mt-1">Maks. 30 MB • MP4, MOV, WebM</span>
          </div>

          <!-- Video Preview -->
          <div v-else class="relative aspect-video bg-black rounded-xl overflow-hidden mb-4">
            <video 
              v-if="videoPreviewUrl"
              :src="videoPreviewUrl"
              class="w-full h-full object-contain"
              controls
            ></video>
            
            <!-- Upload Progress -->
            <div v-if="videoUploading" class="absolute inset-0 bg-black/70 flex flex-col items-center justify-center">
              <Loader2 class="w-8 h-8 text-white animate-spin mb-2" />
              <span class="text-white text-sm font-medium">Yukleniyor... {{ videoUploadProgress }}%</span>
              <div class="w-32 h-1.5 bg-gray-700 rounded-full mt-2 overflow-hidden">
                <div class="h-full bg-rose-500 transition-all" :style="{ width: videoUploadProgress + '%' }"></div>
              </div>
            </div>

            <!-- Remove Button -->
            <button 
              v-if="!videoUploading"
              type="button"
              @click="removeVideo"
              class="absolute top-2 right-2 p-1.5 bg-black/60 hover:bg-black/80 rounded-full transition-colors"
            >
              <X class="w-4 h-4 text-white" />
            </button>

            <!-- Video Info -->
            <div v-if="videoFile && !videoUploading" class="absolute bottom-0 left-0 right-0 p-3 bg-gradient-to-t from-black/80 to-transparent">
              <p class="text-white text-xs font-medium truncate">{{ videoFile.name }}</p>
              <p class="text-gray-300 text-xs">{{ formatFileSize(videoFile.size) }}</p>
            </div>
          </div>

          <input 
            ref="videoInput"
            type="file" 
            accept="video/mp4,video/quicktime,video/webm,video/x-m4v,.mp4,.mov,.webm,.m4v"
            class="hidden"
            @change="handleVideoSelect"
          />

          <!-- Oto Shorts Toggle -->
          <div class="p-4 bg-gradient-to-r from-rose-50 to-orange-50 dark:from-rose-900/20 dark:to-orange-900/20 rounded-xl border border-rose-200 dark:border-rose-800/50">
            <label class="flex items-start gap-3 cursor-pointer">
              <input 
                type="checkbox" 
                v-model="form.publishToOtoShorts"
                class="mt-0.5 w-5 h-5 rounded border-rose-300 text-rose-500 focus:ring-rose-500"
              />
              <div class="flex-1">
                <span class="font-semibold text-gray-900 dark:text-white flex items-center gap-2">
                  <Play class="w-4 h-4 text-rose-500" />
                  Oto Shorts'da Yayinla
                </span>
                <p class="text-xs text-gray-600 dark:text-gray-400 mt-1">
                  Video, mobil uygulamadaki Oto Shorts bolumunde gosterilsin
                </p>
              </div>
            </label>
          </div>

          <!-- Video Tips -->
          <div class="mt-4 space-y-2 text-xs text-gray-500 dark:text-gray-400">
            <p class="flex items-center gap-1.5">
              <CheckCircle class="w-3.5 h-3.5 text-green-500" />
              Dikey video (9:16) Oto Shorts icin ideal
            </p>
            <p class="flex items-center gap-1.5">
              <CheckCircle class="w-3.5 h-3.5 text-green-500" />
              15-60 saniye arasi sureler oneriliyor
            </p>
          </div>
        </div>

        <!-- Ilan Bilgileri -->
        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl p-6 text-white">
          <h3 class="text-lg font-bold mb-3">Ilan Bilgileri</h3>
          <div class="space-y-3 text-sm">
            <div class="flex justify-between">
              <span class="opacity-80">Ilan No:</span>
              <span class="font-semibold">{{ form.listingNumber || 'Otomatik olusturulacak' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="opacity-80">Ilan Tarihi:</span>
              <span class="font-semibold">{{ form.listingDate || 'Kayit tarihinde' }}</span>
            </div>
          </div>
        </div>

        <!-- Status Card -->
        <div class="bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl p-6 text-white">
          <h3 class="text-lg font-bold mb-3">Yayinlama Durumu</h3>
          <div class="space-y-2 text-sm opacity-90">
            <p>* Arac eklendikten sonra Oto Pazari'nda listelenir</p>
            <p>* Diger bayiler aracinizi gorebilir</p>
            <p>* Mesaj ve teklif alabilirsiniz</p>
          </div>
        </div>

        <!-- Tips -->
        <div class="bg-amber-50 dark:bg-amber-900/20 rounded-2xl p-6 border border-amber-200 dark:border-amber-800">
          <h3 class="text-lg font-bold text-amber-900 dark:text-amber-100 mb-3 flex items-center gap-2">
            <AlertCircle class="w-5 h-5" />
            Ipuclari
          </h3>
          <ul class="space-y-2 text-sm text-amber-800 dark:text-amber-200">
            <li class="flex items-start gap-2">
              <CheckCircle class="w-4 h-4 mt-0.5 flex-shrink-0" />
              <span>Yuksek kaliteli fotograflar ekleyin</span>
            </li>
            <li class="flex items-start gap-2">
              <CheckCircle class="w-4 h-4 mt-0.5 flex-shrink-0" />
              <span>Detayli aciklama yazin</span>
            </li>
            <li class="flex items-start gap-2">
              <CheckCircle class="w-4 h-4 mt-0.5 flex-shrink-0" />
              <span>Rekabetci fiyat belirleyin</span>
            </li>
          </ul>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft, Upload, CheckCircle, Car, Settings, DollarSign, FileText, Image as ImageIcon, AlertCircle, Video, Play, X, Loader2 } from 'lucide-vue-next'
import { reactive, ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

interface CatalogClass {
  id: number
  name: string
}

interface Brand {
  id: number
  name: string
  logo_url: string | null
  is_popular: boolean
}

interface Series {
  id: number
  name: string
  brand_name: string
  model_count: number
}

interface Model {
  id: number
  name: string
  series_name: string
  brand_name: string
  alt_model_count: number
}

interface AltModel {
  id: number
  name: string
  model_name: string
  series_name: string
  brand_name: string
  trim_count: number
}

interface Trim {
  id: number
  name: string | null
  body_type: string | null
  fuel_type: string | null
  transmission: string | null
  engine_power: number | null
  engine_displacement: number | null
}

interface SelectOption {
  value: string
  label: string
}

const router = useRouter()
const api = useApi()
const toast = useToast()

const loading = ref(false)
const loadingClasses = ref(false)
const loadingBrands = ref(false)
const loadingSeries = ref(false)
const loadingModels = ref(false)
const loadingAltModels = ref(false)
const loadingTrims = ref(false)
const autoFilledSpecs = ref(false)
const requiresTrimSelection = ref(false)
const autoFilledTrimName = ref<string>('')

// Video upload state
const videoInput = ref<HTMLInputElement | null>(null)
const videoFile = ref<File | null>(null)
const videoPreviewUrl = ref<string>('')
const videoUploading = ref(false)
const videoUploadProgress = ref(0)
const videoDragOver = ref(false)
const MAX_VIDEO_SIZE = 30 * 1024 * 1024 // 30 MB

// Catalog data
const classes = ref<CatalogClass[]>([])
const brands = ref<Brand[]>([])
const series = ref<Series[]>([])
const models = ref<Model[]>([])
const altModels = ref<AltModel[]>([])
const trims = ref<Trim[]>([])

// Selection state
const selectedClassId = ref<number | ''>('')
const selectedBrandId = ref<number | ''>('')
const selectedSeriesId = ref<number | ''>('')
const selectedModelId = ref<number | ''>('')
const selectedAltModelId = ref<number | ''>('')
const selectedTrimId = ref<number | ''>('')

// Static options
const fuelTypes = ref<SelectOption[]>([
  { value: 'Benzin', label: 'Benzin' },
  { value: 'Dizel', label: 'Dizel' },
  { value: 'Elektrik', label: 'Elektrik' },
  { value: 'Hibrit', label: 'Hibrit' },
  { value: 'LPG', label: 'LPG' },
  { value: 'Benzin + LPG', label: 'Benzin + LPG' }
])

const transmissions = ref<SelectOption[]>([
  { value: 'Manuel', label: 'Manuel' },
  { value: 'Otomatik', label: 'Otomatik' },
  { value: 'Yari Otomatik', label: 'Yari Otomatik' }
])

const bodyTypes = ref<SelectOption[]>([
  { value: 'Sedan', label: 'Sedan' },
  { value: 'Hatchback 5 Kapi', label: 'Hatchback 5 Kapi' },
  { value: 'Hatchback 3 Kapi', label: 'Hatchback 3 Kapi' },
  { value: 'SUV', label: 'SUV' },
  { value: 'Coupe', label: 'Coupe' },
  { value: 'Cabrio', label: 'Cabrio' },
  { value: 'Station Wagon', label: 'Station Wagon' },
  { value: 'Pickup', label: 'Pickup' },
  { value: 'MPV', label: 'MPV' },
  { value: 'Crossover', label: 'Crossover' },
  { value: 'Roadster', label: 'Roadster' }
])

const colors = ref<SelectOption[]>([
  { value: 'Siyah', label: 'Siyah' },
  { value: 'Beyaz', label: 'Beyaz' },
  { value: 'Gri', label: 'Gri' },
  { value: 'Gumus', label: 'Gumus' },
  { value: 'Lacivert', label: 'Lacivert' },
  { value: 'Mavi', label: 'Mavi' },
  { value: 'Kirmizi', label: 'Kirmizi' },
  { value: 'Bordo', label: 'Bordo' },
  { value: 'Kahverengi', label: 'Kahverengi' },
  { value: 'Bej', label: 'Bej' },
  { value: 'Yesil', label: 'Yesil' },
  { value: 'Turuncu', label: 'Turuncu' },
  { value: 'Sari', label: 'Sari' },
  { value: 'Mor', label: 'Mor' },
  { value: 'Diger', label: 'Diger' }
])

// Computed properties
const popularBrands = computed(() => brands.value.filter(b => b.is_popular))
const otherBrands = computed(() => brands.value.filter(b => !b.is_popular))
const selectedBrand = computed(() => brands.value.find(b => b.id === selectedBrandId.value))
const selectedSeries = computed(() => series.value.find(s => s.id === selectedSeriesId.value))
const selectedModel = computed(() => models.value.find(m => m.id === selectedModelId.value))
const selectedAltModel = computed(() => altModels.value.find(am => am.id === selectedAltModelId.value))
const selectedTrim = computed(() => trims.value.find(t => t.id === selectedTrimId.value))

// Trim alanı sadece Alt Model seçildikten sonra (veya model seçilip alt model yoksa) ve specs yüklendiyse gösterilir
const showTrimField = computed(() => {
  // Alt model seçildi ve specs yüklendi
  if (selectedAltModelId.value && autoFilledSpecs.value) {
    return true
  }
  // Model seçildi, alt model yok ve specs yüklendi
  if (selectedModelId.value && altModels.value.length === 0 && autoFilledSpecs.value) {
    return true
  }
  // Trim seçimi gerekiyorsa her zaman göster
  if (requiresTrimSelection.value && trims.value.length > 0) {
    return true
  }
  return false
})

// Ilan numarasi olusturma fonksiyonu
const generateListingNumber = () => {
  const date = new Date()
  const year = date.getFullYear().toString().slice(-2)
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const day = date.getDate().toString().padStart(2, '0')
  const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0')
  return `GM${year}${month}${day}${random}`
}

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
  listingNumber: generateListingNumber(),
  listingDate: formatDate(new Date()),
  brand: '',
  series: '',
  model: '',
  altModel: '',
  trim: '',
  year: new Date().getFullYear(),
  mileage: null as number | null,
  fuelType: '',
  transmission: '',
  bodyType: '',
  color: '',
  enginePower: null as number | null,
  engineCc: null as number | null,
  vehicleCondition: '2. El',
  basePrice: null as number | null,
  sellerType: 'gallery',
  hasWarranty: false,
  tradeInAcceptable: false,
  heavyDamageRecord: false,
  description: '',
  // Video & Oto Shorts
  videoUrl: '' as string,
  publishToOtoShorts: true // Default olarak isaretli
})

// Load classes on mount
onMounted(async () => {
  await loadClasses()
})

// Load classes
const loadClasses = async () => {
  loadingClasses.value = true
  try {
    const response = await api.get<{ success: boolean; data: CatalogClass[] }>('/catalog/classes')
    if (response.success) {
      classes.value = response.data
      // Auto-select if only one class
      if (classes.value.length === 1) {
        selectedClassId.value = classes.value[0].id
        await loadBrands()
      }
    }
  } catch (error: any) {
    console.error('Siniflar yuklenemedi:', error)
    toast.error('Siniflar yuklenemedi')
  } finally {
    loadingClasses.value = false
  }
}

// On class change
const onClassChange = async () => {
  selectedBrandId.value = ''
  selectedSeriesId.value = ''
  selectedModelId.value = ''
  selectedAltModelId.value = ''
  selectedTrimId.value = ''
  brands.value = []
  series.value = []
  models.value = []
  altModels.value = []
  trims.value = []
  autoFilledSpecs.value = false
  
  if (!selectedClassId.value) return
  await loadBrands()
}

// Load brands
const loadBrands = async () => {
  if (!selectedClassId.value) return
  
  loadingBrands.value = true
  try {
    const response = await api.get<{ success: boolean; data: Brand[] }>(`/catalog/brands?classId=${selectedClassId.value}`)
    if (response.success && response.data) {
      brands.value = response.data
    }
  } catch (error: any) {
    console.error('Markalar yuklenemedi:', error)
    toast.error('Markalar yuklenemedi')
  } finally {
    loadingBrands.value = false
  }
}

// On brand change
const onBrandChange = async () => {
  selectedSeriesId.value = ''
  selectedModelId.value = ''
  selectedAltModelId.value = ''
  selectedTrimId.value = ''
  series.value = []
  models.value = []
  altModels.value = []
  trims.value = []
  autoFilledSpecs.value = false
  
  if (!selectedBrandId.value) return
  
  form.brand = selectedBrand.value?.name || ''
  await loadSeries()
}

// Load series
const loadSeries = async () => {
  if (!selectedBrandId.value) return
  
  loadingSeries.value = true
  try {
    const response = await api.get<{ success: boolean; data: Series[] }>(`/catalog/brands/${selectedBrandId.value}/series`)
    if (response.success) {
      series.value = response.data
    }
  } catch (error: any) {
    console.error('Seriler yuklenemedi:', error)
    toast.error('Seriler yuklenemedi')
  } finally {
    loadingSeries.value = false
  }
}

// On series change
const onSeriesChange = async () => {
  selectedModelId.value = ''
  selectedAltModelId.value = ''
  selectedTrimId.value = ''
  models.value = []
  altModels.value = []
  trims.value = []
  autoFilledSpecs.value = false
  
  if (!selectedSeriesId.value) return
  
  form.series = selectedSeries.value?.name || ''
  await loadModels()
}

// Load models
const loadModels = async () => {
  if (!selectedSeriesId.value) return
  
  loadingModels.value = true
  try {
    const response = await api.get<{ success: boolean; data: Model[] }>(`/catalog/series/${selectedSeriesId.value}/models`)
    if (response.success) {
      models.value = response.data
    }
  } catch (error: any) {
    console.error('Modeller yuklenemedi:', error)
    toast.error('Modeller yuklenemedi')
  } finally {
    loadingModels.value = false
  }
}

// On model change
const onModelChange = async () => {
  selectedAltModelId.value = ''
  selectedTrimId.value = ''
  altModels.value = []
  trims.value = []
  autoFilledSpecs.value = false
  requiresTrimSelection.value = false
  autoFilledTrimName.value = ''
  
  // Reset specs when model changes
  form.bodyType = ''
  form.fuelType = ''
  form.transmission = ''
  form.enginePower = null
  form.engineCc = null
  form.altModel = ''
  form.trim = ''
  
  if (!selectedModelId.value) return
  
  form.model = selectedModel.value?.name || ''
  
  // Load alt models
  await loadAltModels()
  
  // If no alt models, load specifications directly
  // This will determine if trim selection is needed and auto-fill specs
  if (altModels.value.length === 0) {
    await loadSpecifications()
  }
}

// Load alt models
const loadAltModels = async () => {
  if (!selectedModelId.value) return
  
  loadingAltModels.value = true
  try {
    const response = await api.get<{ success: boolean; data: AltModel[] }>(`/catalog/models/${selectedModelId.value}/alt-models`)
    if (response.success) {
      altModels.value = response.data
    }
  } catch (error: any) {
    console.error('Alt modeller yuklenemedi:', error)
  } finally {
    loadingAltModels.value = false
  }
}

// On alt model change
const onAltModelChange = async () => {
  selectedTrimId.value = ''
  trims.value = []
  requiresTrimSelection.value = false
  autoFilledSpecs.value = false
  autoFilledTrimName.value = ''
  
  // Reset specs when alt model changes
  form.bodyType = ''
  form.fuelType = ''
  form.transmission = ''
  form.enginePower = null
  form.engineCc = null
  form.trim = ''
  
  if (!selectedAltModelId.value) {
    return
  }
  
  form.altModel = selectedAltModel.value?.name || ''
  
  // Load specifications - this will determine if trim selection is needed
  // and either auto-fill specs or show trim selection
  await loadSpecifications()
}

// Load trims for alt model
const loadTrimsForAltModel = async () => {
  if (!selectedAltModelId.value) return
  
  loadingTrims.value = true
  try {
    const response = await api.get<{ success: boolean; data: Trim[] }>(`/catalog/alt-models/${selectedAltModelId.value}/trims`)
    if (response.success) {
      trims.value = response.data
    }
  } catch (error: any) {
    console.error('Trimler yuklenemedi:', error)
  } finally {
    loadingTrims.value = false
  }
}

// Load trims for model (when no alt model)
const loadTrimsForModel = async () => {
  if (!selectedModelId.value) return
  
  loadingTrims.value = true
  try {
    const response = await api.get<{ success: boolean; data: Trim[] }>(`/catalog/models/${selectedModelId.value}/trims`)
    if (response.success) {
      trims.value = response.data
    }
  } catch (error: any) {
    console.error('Trimler yuklenemedi:', error)
  } finally {
    loadingTrims.value = false
  }
}

// Load specifications and auto-fill form
// Supports both new API format (requires_trim_selection, auto_fill_specs, trims_for_selection)
// and old API format (bodyType, fuelType, etc.) for backward compatibility
const loadSpecifications = async () => {
  const altModelId = selectedAltModelId.value
  const modelId = selectedModelId.value
  
  if (!altModelId && !modelId) return
  
  try {
    const params = altModelId ? `altModelId=${altModelId}` : `modelId=${modelId}`
    const response = await api.get<{ success: boolean; data: any }>(`/catalog/specifications?${params}`)
    
    if (response.success && response.data) {
      const result = response.data
      
      // Check for new API format (requires_trim_selection) or old format (bodyType)
      const isNewFormat = 'requires_trim_selection' in result
      
      if (isNewFormat) {
        // New API format
        requiresTrimSelection.value = result.requires_trim_selection || false
        
        if (result.requires_trim_selection) {
          // User needs to select a trim - populate trims list
          trims.value = result.trims_for_selection || []
          selectedTrimId.value = ''
          autoFilledSpecs.value = false
          autoFilledTrimName.value = ''
        } else {
          // Auto-fill specs - no trim selection needed
          const autoFill = result.auto_fill_specs
          if (autoFill) {
            if (autoFill.body_type) form.bodyType = autoFill.body_type
            if (autoFill.fuel_type) form.fuelType = autoFill.fuel_type
            if (autoFill.transmission) form.transmission = autoFill.transmission
            if (autoFill.engine_power) form.enginePower = parseInt(String(autoFill.engine_power)) || null
            if (autoFill.engine_displacement) form.engineCc = parseInt(String(autoFill.engine_displacement)) || null
            if (autoFill.trim_id) selectedTrimId.value = autoFill.trim_id
            if (autoFill.trim_name) {
              form.trim = autoFill.trim_name
              autoFilledTrimName.value = autoFill.trim_name
            } else {
              autoFilledTrimName.value = ''
            }
            autoFilledSpecs.value = true
          }
          // Clear trims list since no selection needed
          trims.value = []
        }
      } else {
        // Old API format - auto-fill directly (backward compatible)
        requiresTrimSelection.value = false
        if (result.bodyType) form.bodyType = result.bodyType
        if (result.fuelType) form.fuelType = result.fuelType
        if (result.transmission) form.transmission = result.transmission
        if (result.enginePower) form.enginePower = result.enginePower
        if (result.engineDisplacement) form.engineCc = result.engineDisplacement
        autoFilledSpecs.value = true
        trims.value = []
      }
    }
  } catch (error: any) {
    console.error('Spesifikasyonlar yuklenemedi:', error)
    // Fallback to old behavior - load trims normally
    if (altModelId) {
      await loadTrimsForAltModel()
    } else if (modelId) {
      await loadTrimsForModel()
    }
  }
}

// On trim change - always override ALL specs with selected trim
const onTrimChange = () => {
  if (!selectedTrimId.value) {
    autoFilledSpecs.value = false
    autoFilledTrimName.value = ''
    return
  }
  
  const trim = selectedTrim.value
  if (!trim) return
  
  form.trim = trim.name || ''
  autoFilledTrimName.value = trim.name || ''
  
  // Always override ALL specs with trim-specific values
  if (trim.body_type) form.bodyType = trim.body_type
  if (trim.fuel_type) form.fuelType = trim.fuel_type
  if (trim.transmission) form.transmission = trim.transmission
  if (trim.engine_power) form.enginePower = parseInt(String(trim.engine_power)) || null
  if (trim.engine_displacement) form.engineCc = parseInt(String(trim.engine_displacement)) || null
  
  autoFilledSpecs.value = true
}

// Video Upload Functions
const triggerVideoUpload = () => {
  videoInput.value?.click()
}

const formatFileSize = (bytes: number): string => {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}

const validateVideoFile = (file: File): boolean => {
  // Check file size (max 30MB)
  if (file.size > MAX_VIDEO_SIZE) {
    toast.error(`Video boyutu cok buyuk. Maksimum ${formatFileSize(MAX_VIDEO_SIZE)} yuklenebilir.`)
    return false
  }
  
  // Check file type
  const allowedTypes = ['video/mp4', 'video/quicktime', 'video/webm', 'video/x-m4v']
  if (!allowedTypes.includes(file.type)) {
    toast.error('Gecersiz video formati. MP4, MOV veya WebM yukleyebilirsiniz.')
    return false
  }
  
  return true
}

const handleVideoSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return
  
  if (!validateVideoFile(file)) {
    target.value = ''
    return
  }
  
  videoFile.value = file
  videoPreviewUrl.value = URL.createObjectURL(file)
  toast.success('Video secildi. Arac kaydedildiginde yuklenecek.')
}

const handleVideoDrop = (event: DragEvent) => {
  videoDragOver.value = false
  const file = event.dataTransfer?.files[0]
  if (!file) return
  
  if (!file.type.startsWith('video/')) {
    toast.error('Lutfen bir video dosyasi surukleyin.')
    return
  }
  
  if (!validateVideoFile(file)) return
  
  videoFile.value = file
  videoPreviewUrl.value = URL.createObjectURL(file)
  toast.success('Video secildi. Arac kaydedildiginde yuklenecek.')
}

const removeVideo = () => {
  if (videoPreviewUrl.value) {
    URL.revokeObjectURL(videoPreviewUrl.value)
  }
  videoFile.value = null
  videoPreviewUrl.value = ''
  form.videoUrl = ''
  if (videoInput.value) {
    videoInput.value.value = ''
  }
}

const uploadVideo = async (vehicleId: string): Promise<string | null> => {
  if (!videoFile.value) return null
  
  videoUploading.value = true
  videoUploadProgress.value = 0
  
  try {
    const formData = new FormData()
    formData.append('video', videoFile.value)
    formData.append('vehicleId', vehicleId)
    formData.append('publishToOtoShorts', String(form.publishToOtoShorts))
    
    // Simulated progress (real implementation would use XMLHttpRequest or fetch with progress)
    const progressInterval = setInterval(() => {
      if (videoUploadProgress.value < 90) {
        videoUploadProgress.value += Math.random() * 15
      }
    }, 200)
    
    const response = await api.post<{ success: boolean; data: { videoUrl: string } }>('/vehicles/video', formData)
    
    clearInterval(progressInterval)
    videoUploadProgress.value = 100
    
    if (response.success && response.data?.videoUrl) {
      return response.data.videoUrl
    }
    return null
  } catch (error: any) {
    toast.error('Video yuklenirken hata olustu: ' + error.message)
    return null
  } finally {
    videoUploading.value = false
  }
}

const saveVehicle = async (saveType: string = 'publish') => {
  if (!form.brand || !form.series || !form.model || !form.year || !form.mileage || !form.basePrice || !form.fuelType || !form.transmission || !form.vehicleCondition || !form.bodyType || !form.color) {
    toast.error('Lutfen zorunlu alanlari doldurun')
    return
  }

  loading.value = true
  try {
    const payload = { 
      ...form,
      listing_number: form.listingNumber,
      listing_date: new Date().toISOString(),
      publish_to_oto_shorts: form.publishToOtoShorts
    }
    
    const response = await api.post<{ success: boolean; data: any }>('/vehicles', payload)
    
    if (response.success && response.data) {
      const vehicleId = response.data.id
      
      // Upload video if selected
      if (videoFile.value) {
        const videoUrl = await uploadVideo(vehicleId)
        if (videoUrl) {
          // Update vehicle with video URL
          await api.put(`/vehicles/${vehicleId}`, { 
            video_url: videoUrl,
            publish_to_oto_shorts: form.publishToOtoShorts
          })
          
          if (form.publishToOtoShorts) {
            toast.success('Video Oto Shorts\'a gonderildi!')
          }
        }
      }
      
      if (saveType === 'publish') {
        // Submit the vehicle for superadmin approval
        await api.post(`/vehicles/${vehicleId}/submit-approval`)
        toast.success('Araç onaya gönderildi (Süperadmin onayı bekleniyor)')
      } else {
        toast.success('Arac taslak olarak kaydedildi')
      }
    }
    
    router.push('/vehicles')
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
