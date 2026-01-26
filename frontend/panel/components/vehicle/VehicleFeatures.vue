<template>
  <div class="space-y-6">
    <!-- Güvenlik -->
    <div>
      <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3 flex items-center gap-2">
        <Shield class="w-4 h-4 text-green-500" />
        Güvenlik
      </h4>
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
        <label
          v-for="feature in safetyFeatures"
          :key="feature"
          class="flex items-center gap-2 p-2 rounded-lg cursor-pointer transition-all"
          :class="isSelected('guvenlik', feature) 
            ? 'bg-green-50 dark:bg-green-900/30 border border-green-300 dark:border-green-700' 
            : 'bg-gray-50 dark:bg-gray-700/50 border border-transparent hover:bg-gray-100 dark:hover:bg-gray-700'"
        >
          <input 
            type="checkbox" 
            :checked="isSelected('guvenlik', feature)"
            @change="toggleFeature('guvenlik', feature)"
            class="w-4 h-4 rounded border-gray-300 text-green-500 focus:ring-green-500"
          />
          <span class="text-sm text-gray-700 dark:text-gray-300">{{ feature }}</span>
        </label>
      </div>
    </div>

    <!-- İç Donanım -->
    <div>
      <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3 flex items-center gap-2">
        <Armchair class="w-4 h-4 text-blue-500" />
        İç Donanım
      </h4>
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
        <label
          v-for="feature in interiorFeatures"
          :key="feature"
          class="flex items-center gap-2 p-2 rounded-lg cursor-pointer transition-all"
          :class="isSelected('ic_donanim', feature) 
            ? 'bg-blue-50 dark:bg-blue-900/30 border border-blue-300 dark:border-blue-700' 
            : 'bg-gray-50 dark:bg-gray-700/50 border border-transparent hover:bg-gray-100 dark:hover:bg-gray-700'"
        >
          <input 
            type="checkbox" 
            :checked="isSelected('ic_donanim', feature)"
            @change="toggleFeature('ic_donanim', feature)"
            class="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500"
          />
          <span class="text-sm text-gray-700 dark:text-gray-300">{{ feature }}</span>
        </label>
      </div>
    </div>

    <!-- Dış Donanım -->
    <div>
      <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3 flex items-center gap-2">
        <Car class="w-4 h-4 text-orange-500" />
        Dış Donanım
      </h4>
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
        <label
          v-for="feature in exteriorFeatures"
          :key="feature"
          class="flex items-center gap-2 p-2 rounded-lg cursor-pointer transition-all"
          :class="isSelected('dis_donanim', feature) 
            ? 'bg-orange-50 dark:bg-orange-900/30 border border-orange-300 dark:border-orange-700' 
            : 'bg-gray-50 dark:bg-gray-700/50 border border-transparent hover:bg-gray-100 dark:hover:bg-gray-700'"
        >
          <input 
            type="checkbox" 
            :checked="isSelected('dis_donanim', feature)"
            @change="toggleFeature('dis_donanim', feature)"
            class="w-4 h-4 rounded border-gray-300 text-orange-500 focus:ring-orange-500"
          />
          <span class="text-sm text-gray-700 dark:text-gray-300">{{ feature }}</span>
        </label>
      </div>
    </div>

    <!-- Multimedya -->
    <div>
      <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3 flex items-center gap-2">
        <Music class="w-4 h-4 text-purple-500" />
        Multimedya
      </h4>
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
        <label
          v-for="feature in multimediaFeatures"
          :key="feature"
          class="flex items-center gap-2 p-2 rounded-lg cursor-pointer transition-all"
          :class="isSelected('multimedya', feature) 
            ? 'bg-purple-50 dark:bg-purple-900/30 border border-purple-300 dark:border-purple-700' 
            : 'bg-gray-50 dark:bg-gray-700/50 border border-transparent hover:bg-gray-100 dark:hover:bg-gray-700'"
        >
          <input 
            type="checkbox" 
            :checked="isSelected('multimedya', feature)"
            @change="toggleFeature('multimedya', feature)"
            class="w-4 h-4 rounded border-gray-300 text-purple-500 focus:ring-purple-500"
          />
          <span class="text-sm text-gray-700 dark:text-gray-300">{{ feature }}</span>
        </label>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Shield, Armchair, Car, Music } from 'lucide-vue-next'
import { reactive, watch } from 'vue'

interface Features {
  guvenlik: string[]
  ic_donanim: string[]
  dis_donanim: string[]
  multimedya: string[]
}

const props = defineProps<{
  modelValue: Features
}>()

const emit = defineEmits<{
  'update:modelValue': [value: Features]
}>()

// Safety features
const safetyFeatures = [
  'ABS', 'AEB', 'BAS', 'Çocuk Kilidi', 'Distronic', 'ESP / VSA',
  'Gece Görüş Sistemi', 'Hava Yastığı (Sürücü)', 'Hava Yastığı (Yolcu)',
  'Immobilizer', 'Isofix', 'Kör Nokta Uyarı Sistemi', 'Merkezi Kilit',
  'Şerit Takip Sistemi', 'Yokuş Kalkış Desteği', 'Yorgunluk Tespit Sistemi',
  'Zırhlı Araç'
]

// Interior features
const interiorFeatures = [
  'Adaptive Cruise Control', 'Anahtarsız Giriş ve Çalıştırma', 'Deri Koltuk',
  'Elektrikli Camlar', 'Fonksiyonel Direksiyon', 'Geri Görüş Kamerası',
  'Head-up Display', 'Hız Sabitleme Sistemi', 'Hidrolik Direksiyon',
  'Isıtmalı Direksiyon', 'Klima', 'Koltuklar (Elektrikli)', 'Koltuklar (Hafızalı)',
  'Koltuklar (Isıtmalı)', 'Koltuklar (Soğutmalı)', 'Kumaş Koltuk',
  'Otm. Kararan Dikiz Aynası', 'Ön Görüş Kamerası', 'Ön Koltuk Kol Dayaması',
  'Soğutmalı Torpido', 'Start / Stop', 'Üçüncü Sıra Koltuklar', 'Yol Bilgisayarı'
]

// Exterior features
const exteriorFeatures = [
  'Ayakla Açılan Bagaj Kapağı', 'Hardtop', 'Far (Adaptif)', 'Aynalar (Elektrikli)',
  'Aynalar (Isıtmalı)', 'Aynalar (Hafızalı)', 'Park Sensörü (Arka)', 'Park Sensörü (Ön)',
  'Park Asistanı', 'Sunroof', 'Akıllı Bagaj Kapağı', 'Panoramik Cam Tavan',
  'Römork Çeki Demiri', 'LED Farlar', 'Xenon Farlar', 'Sis Farları'
]

// Multimedia features
const multimediaFeatures = [
  'Android Auto', 'Apple CarPlay', 'Bluetooth', 'USB / AUX',
  'Navigasyon', 'Kablosuz Şarj', 'Premium Ses Sistemi', 'DVD / TV',
  'Arka Eğlence Sistemi', 'Dokunmatik Ekran', 'Sesli Komut'
]

const isSelected = (category: keyof Features, feature: string): boolean => {
  return props.modelValue[category]?.includes(feature) || false
}

const toggleFeature = (category: keyof Features, feature: string) => {
  const current = props.modelValue[category] || []
  const newValue = { ...props.modelValue }
  
  if (current.includes(feature)) {
    newValue[category] = current.filter(f => f !== feature)
  } else {
    newValue[category] = [...current, feature]
  }
  
  emit('update:modelValue', newValue)
}
</script>
