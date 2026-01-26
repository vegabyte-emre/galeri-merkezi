<template>
  <div class="space-y-6">
    <!-- Legend -->
    <div class="flex flex-wrap items-center gap-4 p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
      <div 
        v-for="status in damageStatuses" 
        :key="status.value"
        class="flex items-center gap-2 cursor-pointer"
        @click="selectedStatus = status.value"
        :class="selectedStatus === status.value ? 'ring-2 ring-offset-2 ring-primary-500 rounded-lg p-1' : 'p-1'"
      >
        <div 
          class="w-5 h-5 rounded border-2"
          :style="{ backgroundColor: status.color, borderColor: status.borderColor }"
        ></div>
        <span class="text-sm text-gray-700 dark:text-gray-300">{{ status.label }}</span>
      </div>
    </div>

    <!-- Instructions -->
    <p class="text-sm text-gray-500 dark:text-gray-400">
      Önce durumu seçin, sonra araç üzerinde ilgili parçaya tıklayın.
    </p>

    <!-- Car Diagram -->
    <div class="flex flex-col lg:flex-row gap-8 items-start">
      <!-- Car SVG -->
      <div class="flex-1 relative bg-gradient-to-br from-gray-100 to-gray-200 dark:from-gray-800 dark:to-gray-900 rounded-2xl p-8">
        <svg viewBox="0 0 400 500" class="w-full max-w-md mx-auto">
          <!-- Car Top View -->
          <g transform="translate(50, 20)">
            <!-- Car Body Outline -->
            <path 
              d="M150,0 L200,10 Q250,20 270,60 L280,140 L280,320 Q270,380 200,400 L100,400 Q30,380 20,320 L20,140 L30,60 Q50,20 100,10 Z"
              fill="none"
              stroke="#374151"
              stroke-width="2"
              class="dark:stroke-gray-500"
            />
            
            <!-- Front Bumper -->
            <path 
              d="M80,20 L220,20 Q240,30 250,50 L50,50 Q60,30 80,20 Z"
              :fill="getPartColor('on_tampon')"
              :stroke="getPartBorder('on_tampon')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('on_tampon')"
            />
            <text x="150" y="40" text-anchor="middle" class="text-[10px] fill-gray-600 dark:fill-gray-400 pointer-events-none">Ön Tampon</text>

            <!-- Hood -->
            <path 
              d="M50,55 L250,55 L260,120 L40,120 Z"
              :fill="getPartColor('on_kaput')"
              :stroke="getPartBorder('on_kaput')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('on_kaput')"
            />
            <text x="150" y="95" text-anchor="middle" class="text-[10px] fill-gray-600 dark:fill-gray-400 pointer-events-none">Kaput</text>

            <!-- Front Left Fender -->
            <path 
              d="M20,70 L45,55 L35,120 L15,140 Z"
              :fill="getPartColor('on_camurluk_sol')"
              :stroke="getPartBorder('on_camurluk_sol')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('on_camurluk_sol')"
            />
            
            <!-- Front Right Fender -->
            <path 
              d="M280,70 L255,55 L265,120 L285,140 Z"
              :fill="getPartColor('on_camurluk_sag')"
              :stroke="getPartBorder('on_camurluk_sag')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('on_camurluk_sag')"
            />

            <!-- Roof -->
            <path 
              d="M60,125 L240,125 L250,260 L50,260 Z"
              :fill="getPartColor('tavan')"
              :stroke="getPartBorder('tavan')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('tavan')"
            />
            <text x="150" y="200" text-anchor="middle" class="text-[10px] fill-gray-600 dark:fill-gray-400 pointer-events-none">Tavan</text>

            <!-- Front Left Door -->
            <path 
              d="M15,145 L35,125 L45,195 L15,195 Z"
              :fill="getPartColor('on_kapi_sol')"
              :stroke="getPartBorder('on_kapi_sol')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('on_kapi_sol')"
            />

            <!-- Front Right Door -->
            <path 
              d="M285,145 L265,125 L255,195 L285,195 Z"
              :fill="getPartColor('on_kapi_sag')"
              :stroke="getPartBorder('on_kapi_sag')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('on_kapi_sag')"
            />

            <!-- Rear Left Door -->
            <path 
              d="M15,200 L45,200 L50,270 L20,280 Z"
              :fill="getPartColor('arka_kapi_sol')"
              :stroke="getPartBorder('arka_kapi_sol')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('arka_kapi_sol')"
            />

            <!-- Rear Right Door -->
            <path 
              d="M285,200 L255,200 L250,270 L280,280 Z"
              :fill="getPartColor('arka_kapi_sag')"
              :stroke="getPartBorder('arka_kapi_sag')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('arka_kapi_sag')"
            />

            <!-- Rear Left Fender -->
            <path 
              d="M20,285 L50,275 L55,340 L30,350 Z"
              :fill="getPartColor('arka_camurluk_sol')"
              :stroke="getPartBorder('arka_camurluk_sol')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('arka_camurluk_sol')"
            />

            <!-- Rear Right Fender -->
            <path 
              d="M280,285 L250,275 L245,340 L270,350 Z"
              :fill="getPartColor('arka_camurluk_sag')"
              :stroke="getPartBorder('arka_camurluk_sag')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('arka_camurluk_sag')"
            />

            <!-- Trunk -->
            <path 
              d="M55,265 L245,265 L240,340 L60,340 Z"
              :fill="getPartColor('bagaj')"
              :stroke="getPartBorder('bagaj')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('bagaj')"
            />
            <text x="150" y="310" text-anchor="middle" class="text-[10px] fill-gray-600 dark:fill-gray-400 pointer-events-none">Bagaj</text>

            <!-- Rear Bumper -->
            <path 
              d="M60,345 L240,345 Q260,360 250,380 L50,380 Q40,360 60,345 Z"
              :fill="getPartColor('arka_tampon')"
              :stroke="getPartBorder('arka_tampon')"
              stroke-width="2"
              class="cursor-pointer hover:opacity-80 transition-opacity"
              @click="togglePart('arka_tampon')"
            />
            <text x="150" y="368" text-anchor="middle" class="text-[10px] fill-gray-600 dark:fill-gray-400 pointer-events-none">Arka Tampon</text>

            <!-- Wheels (decorative) -->
            <ellipse cx="50" cy="85" rx="25" ry="15" fill="#1f2937" class="dark:fill-gray-600"/>
            <ellipse cx="250" cy="85" rx="25" ry="15" fill="#1f2937" class="dark:fill-gray-600"/>
            <ellipse cx="50" cy="320" rx="25" ry="15" fill="#1f2937" class="dark:fill-gray-600"/>
            <ellipse cx="250" cy="320" rx="25" ry="15" fill="#1f2937" class="dark:fill-gray-600"/>

            <!-- Part Labels on sides -->
            <text x="-10" y="170" text-anchor="end" class="text-[8px] fill-gray-500 dark:fill-gray-400">Sol Ön Kapı</text>
            <text x="310" y="170" text-anchor="start" class="text-[8px] fill-gray-500 dark:fill-gray-400">Sağ Ön Kapı</text>
            <text x="-10" y="240" text-anchor="end" class="text-[8px] fill-gray-500 dark:fill-gray-400">Sol Arka Kapı</text>
            <text x="310" y="240" text-anchor="start" class="text-[8px] fill-gray-500 dark:fill-gray-400">Sağ Arka Kapı</text>
          </g>
        </svg>
      </div>

      <!-- Part List -->
      <div class="w-full lg:w-80 space-y-4">
        <!-- Boyalı Parçalar -->
        <div v-if="paintedParts.length > 0" class="p-4 bg-blue-50 dark:bg-blue-900/20 rounded-xl border border-blue-200 dark:border-blue-800">
          <h4 class="font-semibold text-blue-900 dark:text-blue-100 mb-2 flex items-center gap-2">
            <div class="w-3 h-3 bg-blue-500 rounded"></div>
            Boyalı Parçalar
          </h4>
          <ul class="space-y-1">
            <li v-for="part in paintedParts" :key="part" class="text-sm text-blue-700 dark:text-blue-300 flex items-center gap-2">
              <span class="w-1.5 h-1.5 bg-blue-500 rounded-full"></span>
              {{ getPartLabel(part) }}
            </li>
          </ul>
        </div>

        <!-- Lokal Boyalı Parçalar -->
        <div v-if="localPaintedParts.length > 0" class="p-4 bg-orange-50 dark:bg-orange-900/20 rounded-xl border border-orange-200 dark:border-orange-800">
          <h4 class="font-semibold text-orange-900 dark:text-orange-100 mb-2 flex items-center gap-2">
            <div class="w-3 h-3 bg-orange-400 rounded"></div>
            Lokal Boyalı Parçalar
          </h4>
          <ul class="space-y-1">
            <li v-for="part in localPaintedParts" :key="part" class="text-sm text-orange-700 dark:text-orange-300 flex items-center gap-2">
              <span class="w-1.5 h-1.5 bg-orange-400 rounded-full"></span>
              {{ getPartLabel(part) }}
            </li>
          </ul>
        </div>

        <!-- Değişen Parçalar -->
        <div v-if="replacedParts.length > 0" class="p-4 bg-red-50 dark:bg-red-900/20 rounded-xl border border-red-200 dark:border-red-800">
          <h4 class="font-semibold text-red-900 dark:text-red-100 mb-2 flex items-center gap-2">
            <div class="w-3 h-3 bg-red-500 rounded"></div>
            Değişen Parçalar
          </h4>
          <ul class="space-y-1">
            <li v-for="part in replacedParts" :key="part" class="text-sm text-red-700 dark:text-red-300 flex items-center gap-2">
              <span class="w-1.5 h-1.5 bg-red-500 rounded-full"></span>
              {{ getPartLabel(part) }}
            </li>
          </ul>
        </div>

        <!-- All Original -->
        <div v-if="paintedParts.length === 0 && localPaintedParts.length === 0 && replacedParts.length === 0" class="p-4 bg-green-50 dark:bg-green-900/20 rounded-xl border border-green-200 dark:border-green-800">
          <h4 class="font-semibold text-green-900 dark:text-green-100 flex items-center gap-2">
            <div class="w-3 h-3 bg-gray-400 rounded"></div>
            Tüm parçalar orijinal
          </h4>
        </div>

        <!-- Reset Button -->
        <button 
          type="button"
          @click="resetAll"
          class="w-full py-2 px-4 text-sm font-medium text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
        >
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
  { value: 'orijinal' as DamageStatus, label: 'Orijinal', color: '#9ca3af', borderColor: '#6b7280' },
  { value: 'lokal_boyali' as DamageStatus, label: 'Lokal Boyalı', color: '#fb923c', borderColor: '#ea580c' },
  { value: 'boyali' as DamageStatus, label: 'Boyalı', color: '#3b82f6', borderColor: '#2563eb' },
  { value: 'degisen' as DamageStatus, label: 'Değişen', color: '#ef4444', borderColor: '#dc2626' }
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
  bagaj: 'Bagaj',
  arka_tampon: 'Arka Tampon',
  tavan: 'Tavan'
}

const getPartLabel = (part: string): string => {
  return partLabels[part] || part
}

const getPartColor = (part: string): string => {
  const status = props.modelValue[part] || 'orijinal'
  const statusObj = damageStatuses.find(s => s.value === status)
  return statusObj?.color || '#9ca3af'
}

const getPartBorder = (part: string): string => {
  const status = props.modelValue[part] || 'orijinal'
  const statusObj = damageStatuses.find(s => s.value === status)
  return statusObj?.borderColor || '#6b7280'
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
