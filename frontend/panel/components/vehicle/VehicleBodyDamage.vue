<template>
  <div class="space-y-6">
    <!-- Legend -->
    <div class="flex flex-wrap items-center gap-3 p-4 bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-800 dark:to-gray-700 rounded-xl shadow-sm">
      <span class="text-sm font-medium text-gray-600 dark:text-gray-300 mr-2">Durum Seç:</span>
      <div 
        v-for="status in damageStatuses" 
        :key="status.value"
        class="flex items-center gap-2 px-3 py-2 rounded-lg cursor-pointer transition-all duration-200"
        :class="selectedStatus === status.value 
          ? 'bg-white dark:bg-gray-600 shadow-md ring-2 ring-offset-1 ring-primary-500 scale-105' 
          : 'hover:bg-white/50 dark:hover:bg-gray-600/50'"
        @click="selectedStatus = status.value"
      >
        <div 
          class="w-4 h-4 rounded-full shadow-inner"
          :style="{ backgroundColor: status.color, boxShadow: `inset 0 2px 4px ${status.shadowColor}` }"
        ></div>
        <span class="text-sm font-medium text-gray-700 dark:text-gray-200">{{ status.label }}</span>
      </div>
    </div>

    <!-- Instructions -->
    <p class="text-sm text-gray-500 dark:text-gray-400 flex items-center gap-2">
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
      </svg>
      Önce durumu seçin, sonra araç üzerinde ilgili parçaya tıklayın.
    </p>

    <!-- Car Diagram -->
    <div class="flex flex-col lg:flex-row gap-8 items-start">
      <!-- Modern Car SVG - Top View -->
      <div class="flex-1 relative bg-gradient-to-br from-slate-100 via-gray-100 to-slate-200 dark:from-slate-800 dark:via-gray-800 dark:to-slate-900 rounded-3xl p-8 shadow-lg">
        <!-- Grid pattern overlay -->
        <div class="absolute inset-0 opacity-5 rounded-3xl" style="background-image: radial-gradient(circle, #000 1px, transparent 1px); background-size: 20px 20px;"></div>
        
        <svg viewBox="0 0 300 420" class="w-full max-w-sm mx-auto relative z-10">
          <defs>
            <!-- Gradients for 3D effect -->
            <linearGradient id="wheelGradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#374151"/>
              <stop offset="50%" stop-color="#1f2937"/>
              <stop offset="100%" stop-color="#111827"/>
            </linearGradient>
            <linearGradient id="windowGradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#60a5fa"/>
              <stop offset="100%" stop-color="#3b82f6"/>
            </linearGradient>
            <!-- Shadow filter -->
            <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
              <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.15"/>
            </filter>
          </defs>

          <!-- Car Shadow -->
          <ellipse cx="150" cy="390" rx="100" ry="15" fill="#00000015" class="dark:fill-white/5"/>

          <!-- Main Car Body Container -->
          <g transform="translate(30, 10)">
            
            <!-- Front Bumper -->
            <path 
              d="M60,5 Q120,0 180,5 Q195,10 200,25 L40,25 Q45,10 60,5 Z"
              :fill="getPartColor('on_tampon')"
              :stroke="getPartBorder('on_tampon')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('on_tampon')"
            />

            <!-- Hood / Kaput -->
            <path 
              d="M40,30 L200,30 Q210,35 212,50 L212,110 Q210,115 200,120 L40,120 Q30,115 28,110 L28,50 Q30,35 40,30 Z"
              :fill="getPartColor('on_kaput')"
              :stroke="getPartBorder('on_kaput')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('on_kaput')"
            />
            <!-- Kaput detail lines -->
            <path d="M70,50 L70,100" stroke="#00000015" stroke-width="1" fill="none" class="pointer-events-none"/>
            <path d="M170,50 L170,100" stroke="#00000015" stroke-width="1" fill="none" class="pointer-events-none"/>

            <!-- Front Left Fender -->
            <path 
              d="M10,45 L25,30 L25,120 L10,135 Q5,90 10,45 Z"
              :fill="getPartColor('on_camurluk_sol')"
              :stroke="getPartBorder('on_camurluk_sol')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('on_camurluk_sol')"
            />

            <!-- Front Right Fender -->
            <path 
              d="M230,45 L215,30 L215,120 L230,135 Q235,90 230,45 Z"
              :fill="getPartColor('on_camurluk_sag')"
              :stroke="getPartBorder('on_camurluk_sag')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('on_camurluk_sag')"
            />

            <!-- Front Wheels -->
            <ellipse cx="15" cy="90" rx="12" ry="35" fill="url(#wheelGradient)" class="pointer-events-none"/>
            <ellipse cx="225" cy="90" rx="12" ry="35" fill="url(#wheelGradient)" class="pointer-events-none"/>
            
            <!-- Front Left Door -->
            <path 
              d="M10,140 L25,125 L25,200 L10,215 Q5,177 10,140 Z"
              :fill="getPartColor('on_kapi_sol')"
              :stroke="getPartBorder('on_kapi_sol')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('on_kapi_sol')"
            />

            <!-- Front Right Door -->
            <path 
              d="M230,140 L215,125 L215,200 L230,215 Q235,177 230,140 Z"
              :fill="getPartColor('on_kapi_sag')"
              :stroke="getPartBorder('on_kapi_sag')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('on_kapi_sag')"
            />

            <!-- Roof / Tavan with Windows -->
            <path 
              d="M30,125 L210,125 Q220,130 220,145 L220,260 Q220,275 210,280 L30,280 Q20,275 20,260 L20,145 Q20,130 30,125 Z"
              :fill="getPartColor('tavan')"
              :stroke="getPartBorder('tavan')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('tavan')"
            />
            <!-- Window detail (decorative) -->
            <rect x="45" y="145" width="150" height="50" rx="5" fill="url(#windowGradient)" opacity="0.7" class="pointer-events-none"/>
            <rect x="45" y="210" width="150" height="50" rx="5" fill="url(#windowGradient)" opacity="0.7" class="pointer-events-none"/>

            <!-- Rear Left Door -->
            <path 
              d="M10,220 L25,205 L25,290 L10,305 Q5,262 10,220 Z"
              :fill="getPartColor('arka_kapi_sol')"
              :stroke="getPartBorder('arka_kapi_sol')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('arka_kapi_sol')"
            />

            <!-- Rear Right Door -->
            <path 
              d="M230,220 L215,205 L215,290 L230,305 Q235,262 230,220 Z"
              :fill="getPartColor('arka_kapi_sag')"
              :stroke="getPartBorder('arka_kapi_sag')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('arka_kapi_sag')"
            />

            <!-- Rear Left Fender -->
            <path 
              d="M10,310 L25,295 L25,355 L10,370 Q5,340 10,310 Z"
              :fill="getPartColor('arka_camurluk_sol')"
              :stroke="getPartBorder('arka_camurluk_sol')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('arka_camurluk_sol')"
            />

            <!-- Rear Right Fender -->
            <path 
              d="M230,310 L215,295 L215,355 L230,370 Q235,340 230,310 Z"
              :fill="getPartColor('arka_camurluk_sag')"
              :stroke="getPartBorder('arka_camurluk_sag')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('arka_camurluk_sag')"
            />

            <!-- Rear Wheels -->
            <ellipse cx="15" cy="335" rx="12" ry="35" fill="url(#wheelGradient)" class="pointer-events-none"/>
            <ellipse cx="225" cy="335" rx="12" ry="35" fill="url(#wheelGradient)" class="pointer-events-none"/>

            <!-- Trunk / Bagaj -->
            <path 
              d="M28,285 L212,285 Q220,290 220,305 L220,360 Q218,365 210,370 L30,370 Q22,365 20,360 L20,305 Q20,290 28,285 Z"
              :fill="getPartColor('bagaj')"
              :stroke="getPartBorder('bagaj')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('bagaj')"
            />
            <!-- Bagaj detail line -->
            <path d="M60,305 L180,305" stroke="#00000015" stroke-width="1" fill="none" class="pointer-events-none"/>

            <!-- Rear Bumper -->
            <path 
              d="M40,375 L200,375 Q210,378 215,390 Q210,400 200,400 L40,400 Q30,400 25,390 Q30,378 40,375 Z"
              :fill="getPartColor('arka_tampon')"
              :stroke="getPartBorder('arka_tampon')"
              stroke-width="2"
              class="cursor-pointer hover:brightness-110 transition-all duration-200"
              filter="url(#shadow)"
              @click="togglePart('arka_tampon')"
            />

            <!-- Tail Lights (decorative) -->
            <rect x="30" y="372" width="25" height="8" rx="2" fill="#dc2626" opacity="0.8" class="pointer-events-none"/>
            <rect x="185" y="372" width="25" height="8" rx="2" fill="#dc2626" opacity="0.8" class="pointer-events-none"/>

            <!-- Headlights (decorative) -->
            <ellipse cx="55" cy="18" rx="12" ry="6" fill="#fbbf24" opacity="0.8" class="pointer-events-none"/>
            <ellipse cx="185" cy="18" rx="12" ry="6" fill="#fbbf24" opacity="0.8" class="pointer-events-none"/>

          </g>

          <!-- Labels on hover areas (positioned outside car) -->
          <g class="text-[9px] fill-gray-400 dark:fill-gray-500 font-medium pointer-events-none">
            <text x="150" y="25" text-anchor="middle">Ön Tampon</text>
            <text x="150" y="85" text-anchor="middle">Kaput</text>
            <text x="150" y="215" text-anchor="middle">Tavan</text>
            <text x="150" y="345" text-anchor="middle">Bagaj</text>
            <text x="150" y="408" text-anchor="middle">Arka Tampon</text>
          </g>
        </svg>

        <!-- Side Labels -->
        <div class="absolute left-2 top-1/2 -translate-y-1/2 flex flex-col gap-8 text-[10px] text-gray-400 dark:text-gray-500">
          <span>Ön Çamurluk</span>
          <span>Ön Kapı</span>
          <span>Arka Kapı</span>
          <span>Arka Çamurluk</span>
        </div>
        <div class="absolute right-2 top-1/2 -translate-y-1/2 flex flex-col gap-8 text-[10px] text-gray-400 dark:text-gray-500 text-right">
          <span>Ön Çamurluk</span>
          <span>Ön Kapı</span>
          <span>Arka Kapı</span>
          <span>Arka Çamurluk</span>
        </div>
      </div>

      <!-- Part List Panel -->
      <div class="w-full lg:w-80 space-y-4">
        <!-- Boyalı Parçalar -->
        <div v-if="paintedParts.length > 0" class="p-4 bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/30 dark:to-blue-800/20 rounded-xl border border-blue-200 dark:border-blue-700 shadow-sm">
          <h4 class="font-semibold text-blue-800 dark:text-blue-200 mb-3 flex items-center gap-2">
            <div class="w-3 h-3 bg-blue-500 rounded-full shadow-sm"></div>
            Boyalı Parçalar ({{ paintedParts.length }})
          </h4>
          <ul class="space-y-1.5">
            <li v-for="part in paintedParts" :key="part" class="text-sm text-blue-700 dark:text-blue-300 flex items-center gap-2">
              <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              {{ getPartLabel(part) }}
            </li>
          </ul>
        </div>

        <!-- Lokal Boyalı Parçalar -->
        <div v-if="localPaintedParts.length > 0" class="p-4 bg-gradient-to-br from-orange-50 to-amber-100 dark:from-orange-900/30 dark:to-amber-800/20 rounded-xl border border-orange-200 dark:border-orange-700 shadow-sm">
          <h4 class="font-semibold text-orange-800 dark:text-orange-200 mb-3 flex items-center gap-2">
            <div class="w-3 h-3 bg-orange-400 rounded-full shadow-sm"></div>
            Lokal Boyalı Parçalar ({{ localPaintedParts.length }})
          </h4>
          <ul class="space-y-1.5">
            <li v-for="part in localPaintedParts" :key="part" class="text-sm text-orange-700 dark:text-orange-300 flex items-center gap-2">
              <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              {{ getPartLabel(part) }}
            </li>
          </ul>
        </div>

        <!-- Değişen Parçalar -->
        <div v-if="replacedParts.length > 0" class="p-4 bg-gradient-to-br from-red-50 to-rose-100 dark:from-red-900/30 dark:to-rose-800/20 rounded-xl border border-red-200 dark:border-red-700 shadow-sm">
          <h4 class="font-semibold text-red-800 dark:text-red-200 mb-3 flex items-center gap-2">
            <div class="w-3 h-3 bg-red-500 rounded-full shadow-sm"></div>
            Değişen Parçalar ({{ replacedParts.length }})
          </h4>
          <ul class="space-y-1.5">
            <li v-for="part in replacedParts" :key="part" class="text-sm text-red-700 dark:text-red-300 flex items-center gap-2">
              <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              {{ getPartLabel(part) }}
            </li>
          </ul>
        </div>

        <!-- All Original -->
        <div v-if="paintedParts.length === 0 && localPaintedParts.length === 0 && replacedParts.length === 0" class="p-5 bg-gradient-to-br from-green-50 to-emerald-100 dark:from-green-900/30 dark:to-emerald-800/20 rounded-xl border border-green-200 dark:border-green-700 shadow-sm">
          <h4 class="font-semibold text-green-800 dark:text-green-200 flex items-center gap-2">
            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
            </svg>
            Tüm parçalar orijinal
          </h4>
          <p class="text-sm text-green-600 dark:text-green-400 mt-1">Araçta boya veya değişen parça bulunmamaktadır.</p>
        </div>

        <!-- Reset Button -->
        <button 
          type="button"
          @click="resetAll"
          class="w-full py-3 px-4 text-sm font-semibold text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-700 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-600 transition-all duration-200 shadow-sm border border-gray-200 dark:border-gray-600 flex items-center justify-center gap-2"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
          </svg>
          Tümünü Sıfırla
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

type DamageStatus = 'orijinal' | 'lokal_boyali' | 'boyali' | 'degisen'

interface BodyDamage {
  [key: string]: DamageStatus
}

const props = defineProps<{
  modelValue: BodyDamage
}>()

const emit = defineEmits<{
  'update:modelValue': [value: BodyDamage]
}>()

const selectedStatus = ref<DamageStatus>('boyali')

const damageStatuses = [
  { value: 'orijinal' as DamageStatus, label: 'Orijinal', color: '#94a3b8', shadowColor: 'rgba(0,0,0,0.2)' },
  { value: 'lokal_boyali' as DamageStatus, label: 'Lokal Boyalı', color: '#fb923c', shadowColor: 'rgba(234,88,12,0.3)' },
  { value: 'boyali' as DamageStatus, label: 'Boyalı', color: '#3b82f6', shadowColor: 'rgba(37,99,235,0.3)' },
  { value: 'degisen' as DamageStatus, label: 'Değişen', color: '#ef4444', shadowColor: 'rgba(220,38,38,0.3)' }
]

const partLabels: Record<string, string> = {
  on_tampon: 'Ön Tampon',
  on_kaput: 'Kaput',
  on_camurluk_sol: 'Sol Ön Çamurluk',
  on_camurluk_sag: 'Sağ Ön Çamurluk',
  on_kapi_sol: 'Sol Ön Kapı',
  on_kapi_sag: 'Sağ Ön Kapı',
  arka_kapi_sol: 'Sol Arka Kapı',
  arka_kapi_sag: 'Sağ Arka Kapı',
  arka_camurluk_sol: 'Sol Arka Çamurluk',
  arka_camurluk_sag: 'Sağ Arka Çamurluk',
  bagaj: 'Bagaj Kapağı',
  arka_tampon: 'Arka Tampon',
  tavan: 'Tavan'
}

const getPartLabel = (part: string): string => {
  return partLabels[part] || part
}

const getPartColor = (part: string): string => {
  const status = props.modelValue[part] || 'orijinal'
  const statusObj = damageStatuses.find(s => s.value === status)
  return statusObj?.color || '#94a3b8'
}

const getPartBorder = (part: string): string => {
  const status = props.modelValue[part] || 'orijinal'
  // Darker shade for border
  const borderColors: Record<DamageStatus, string> = {
    'orijinal': '#64748b',
    'lokal_boyali': '#ea580c',
    'boyali': '#2563eb',
    'degisen': '#dc2626'
  }
  return borderColors[status] || '#64748b'
}

const togglePart = (part: string) => {
  const newValue = { ...props.modelValue }
  const currentStatus = newValue[part] || 'orijinal'
  
  if (currentStatus === selectedStatus.value) {
    // If already this status, reset to original
    newValue[part] = 'orijinal'
  } else {
    newValue[part] = selectedStatus.value
  }
  
  emit('update:modelValue', newValue)
}

const paintedParts = computed(() => {
  return Object.entries(props.modelValue)
    .filter(([_, status]) => status === 'boyali')
    .map(([part]) => part)
})

const localPaintedParts = computed(() => {
  return Object.entries(props.modelValue)
    .filter(([_, status]) => status === 'lokal_boyali')
    .map(([part]) => part)
})

const replacedParts = computed(() => {
  return Object.entries(props.modelValue)
    .filter(([_, status]) => status === 'degisen')
    .map(([part]) => part)
})

const resetAll = () => {
  emit('update:modelValue', {})
}
</script>
