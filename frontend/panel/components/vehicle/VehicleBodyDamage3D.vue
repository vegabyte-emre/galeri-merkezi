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
      Önce durumu seçin, sonra 3D araç üzerinde ilgili parçaya tıklayın. Fare ile döndürebilirsiniz.
    </p>

    <!-- 3D Viewer and Part List -->
    <div class="flex flex-col lg:flex-row gap-8 items-start">
      <!-- 3D Canvas Container -->
      <div class="flex-1 relative">
        <div 
          ref="canvasContainer"
          class="w-full aspect-[4/3] bg-gradient-to-br from-slate-100 via-gray-100 to-slate-200 dark:from-slate-800 dark:via-gray-800 dark:to-slate-900 rounded-3xl shadow-lg overflow-hidden cursor-grab active:cursor-grabbing"
        >
          <canvas ref="canvas" class="w-full h-full"></canvas>
        </div>
        
        <!-- Controls overlay -->
        <div class="absolute bottom-4 left-4 flex gap-2">
          <button 
            @click="resetCamera"
            class="p-2 bg-white/90 dark:bg-gray-700/90 rounded-lg shadow-md hover:bg-white dark:hover:bg-gray-600 transition-colors"
            title="Görünümü Sıfırla"
          >
            <svg class="w-5 h-5 text-gray-600 dark:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
            </svg>
          </button>
          <button 
            @click="toggleAutoRotate"
            class="p-2 bg-white/90 dark:bg-gray-700/90 rounded-lg shadow-md hover:bg-white dark:hover:bg-gray-600 transition-colors"
            :class="autoRotate ? 'ring-2 ring-primary-500' : ''"
            title="Otomatik Döndür"
          >
            <svg class="w-5 h-5 text-gray-600 dark:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
            </svg>
          </button>
        </div>

        <!-- Hovered part name -->
        <div 
          v-if="hoveredPart"
          class="absolute top-4 left-1/2 -translate-x-1/2 px-4 py-2 bg-black/75 text-white text-sm rounded-lg shadow-lg"
        >
          {{ getPartLabel(hoveredPart) }}
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
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'

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

const canvas = ref<HTMLCanvasElement | null>(null)
const canvasContainer = ref<HTMLDivElement | null>(null)
const selectedStatus = ref<DamageStatus>('boyali')
const hoveredPart = ref<string | null>(null)
const autoRotate = ref(false)

// Three.js instances
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls
let carGroup: THREE.Group
let carParts: Map<string, THREE.Mesh> = new Map()
let raycaster: THREE.Raycaster
let mouse: THREE.Vector2
let animationId: number

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

const statusColors: Record<DamageStatus, number> = {
  'orijinal': 0x94a3b8,
  'lokal_boyali': 0xfb923c,
  'boyali': 0x3b82f6,
  'degisen': 0xef4444
}

const getPartLabel = (part: string): string => partLabels[part] || part

const getPartColor = (part: string): number => {
  const status = props.modelValue[part] || 'orijinal'
  return statusColors[status]
}

// Create sedan car model procedurally
function createSedan(): THREE.Group {
  const car = new THREE.Group()
  
  // Materials with better lighting
  const createMaterial = (color: number) => new THREE.MeshPhysicalMaterial({
    color,
    metalness: 0.6,
    roughness: 0.4,
    clearcoat: 0.3,
    clearcoatRoughness: 0.2
  })
  
  const wheelMaterial = new THREE.MeshStandardMaterial({
    color: 0x1a1a1a,
    metalness: 0.8,
    roughness: 0.3
  })
  
  const glassMaterial = new THREE.MeshPhysicalMaterial({
    color: 0x88ccff,
    metalness: 0.1,
    roughness: 0.1,
    transmission: 0.9,
    transparent: true,
    opacity: 0.3
  })

  // Car dimensions
  const bodyLength = 4.5
  const bodyWidth = 1.8
  const bodyHeight = 0.4
  const cabinHeight = 0.5

  // Main body (lower part)
  const bodyGeometry = new THREE.BoxGeometry(bodyLength, bodyHeight, bodyWidth)
  bodyGeometry.translate(0, bodyHeight / 2, 0)
  
  // Front Bumper
  const frontBumperGeometry = new THREE.BoxGeometry(0.3, 0.35, bodyWidth)
  frontBumperGeometry.translate(bodyLength / 2 + 0.15, 0.175, 0)
  const frontBumper = new THREE.Mesh(frontBumperGeometry, createMaterial(getPartColor('on_tampon')))
  frontBumper.userData = { partName: 'on_tampon' }
  frontBumper.castShadow = true
  frontBumper.receiveShadow = true
  car.add(frontBumper)
  carParts.set('on_tampon', frontBumper)

  // Rear Bumper
  const rearBumperGeometry = new THREE.BoxGeometry(0.3, 0.35, bodyWidth)
  rearBumperGeometry.translate(-bodyLength / 2 - 0.15, 0.175, 0)
  const rearBumper = new THREE.Mesh(rearBumperGeometry, createMaterial(getPartColor('arka_tampon')))
  rearBumper.userData = { partName: 'arka_tampon' }
  rearBumper.castShadow = true
  rearBumper.receiveShadow = true
  car.add(rearBumper)
  carParts.set('arka_tampon', rearBumper)

  // Hood (Kaput)
  const hoodGeometry = new THREE.BoxGeometry(1.3, 0.08, bodyWidth - 0.4)
  hoodGeometry.translate(1.2, bodyHeight + 0.04, 0)
  const hood = new THREE.Mesh(hoodGeometry, createMaterial(getPartColor('on_kaput')))
  hood.userData = { partName: 'on_kaput' }
  hood.castShadow = true
  hood.receiveShadow = true
  car.add(hood)
  carParts.set('on_kaput', hood)

  // Trunk (Bagaj)
  const trunkGeometry = new THREE.BoxGeometry(1.0, 0.08, bodyWidth - 0.4)
  trunkGeometry.translate(-1.5, bodyHeight + 0.04, 0)
  const trunk = new THREE.Mesh(trunkGeometry, createMaterial(getPartColor('bagaj')))
  trunk.userData = { partName: 'bagaj' }
  trunk.castShadow = true
  trunk.receiveShadow = true
  car.add(trunk)
  carParts.set('bagaj', trunk)

  // Roof (Tavan)
  const roofGeometry = new THREE.BoxGeometry(1.8, 0.08, bodyWidth - 0.3)
  roofGeometry.translate(-0.1, bodyHeight + cabinHeight + 0.04, 0)
  const roof = new THREE.Mesh(roofGeometry, createMaterial(getPartColor('tavan')))
  roof.userData = { partName: 'tavan' }
  roof.castShadow = true
  roof.receiveShadow = true
  car.add(roof)
  carParts.set('tavan', roof)

  // Front Left Fender (Sol Ön Çamurluk)
  const fenderFLGeometry = new THREE.BoxGeometry(1.2, bodyHeight + 0.05, 0.15)
  fenderFLGeometry.translate(1.2, (bodyHeight + 0.05) / 2, bodyWidth / 2 + 0.05)
  const fenderFL = new THREE.Mesh(fenderFLGeometry, createMaterial(getPartColor('on_camurluk_sol')))
  fenderFL.userData = { partName: 'on_camurluk_sol' }
  fenderFL.castShadow = true
  fenderFL.receiveShadow = true
  car.add(fenderFL)
  carParts.set('on_camurluk_sol', fenderFL)

  // Front Right Fender (Sağ Ön Çamurluk)
  const fenderFRGeometry = new THREE.BoxGeometry(1.2, bodyHeight + 0.05, 0.15)
  fenderFRGeometry.translate(1.2, (bodyHeight + 0.05) / 2, -bodyWidth / 2 - 0.05)
  const fenderFR = new THREE.Mesh(fenderFRGeometry, createMaterial(getPartColor('on_camurluk_sag')))
  fenderFR.userData = { partName: 'on_camurluk_sag' }
  fenderFR.castShadow = true
  fenderFR.receiveShadow = true
  car.add(fenderFR)
  carParts.set('on_camurluk_sag', fenderFR)

  // Rear Left Fender (Sol Arka Çamurluk)
  const fenderRLGeometry = new THREE.BoxGeometry(1.1, bodyHeight + 0.05, 0.15)
  fenderRLGeometry.translate(-1.4, (bodyHeight + 0.05) / 2, bodyWidth / 2 + 0.05)
  const fenderRL = new THREE.Mesh(fenderRLGeometry, createMaterial(getPartColor('arka_camurluk_sol')))
  fenderRL.userData = { partName: 'arka_camurluk_sol' }
  fenderRL.castShadow = true
  fenderRL.receiveShadow = true
  car.add(fenderRL)
  carParts.set('arka_camurluk_sol', fenderRL)

  // Rear Right Fender (Sağ Arka Çamurluk)
  const fenderRRGeometry = new THREE.BoxGeometry(1.1, bodyHeight + 0.05, 0.15)
  fenderRRGeometry.translate(-1.4, (bodyHeight + 0.05) / 2, -bodyWidth / 2 - 0.05)
  const fenderRR = new THREE.Mesh(fenderRRGeometry, createMaterial(getPartColor('arka_camurluk_sag')))
  fenderRR.userData = { partName: 'arka_camurluk_sag' }
  fenderRR.castShadow = true
  fenderRR.receiveShadow = true
  car.add(fenderRR)
  carParts.set('arka_camurluk_sag', fenderRR)

  // Front Left Door (Sol Ön Kapı)
  const doorFLGeometry = new THREE.BoxGeometry(1.0, bodyHeight + cabinHeight - 0.1, 0.08)
  doorFLGeometry.translate(0.6, (bodyHeight + cabinHeight - 0.1) / 2, bodyWidth / 2 + 0.04)
  const doorFL = new THREE.Mesh(doorFLGeometry, createMaterial(getPartColor('on_kapi_sol')))
  doorFL.userData = { partName: 'on_kapi_sol' }
  doorFL.castShadow = true
  doorFL.receiveShadow = true
  car.add(doorFL)
  carParts.set('on_kapi_sol', doorFL)

  // Front Right Door (Sağ Ön Kapı)
  const doorFRGeometry = new THREE.BoxGeometry(1.0, bodyHeight + cabinHeight - 0.1, 0.08)
  doorFRGeometry.translate(0.6, (bodyHeight + cabinHeight - 0.1) / 2, -bodyWidth / 2 - 0.04)
  const doorFR = new THREE.Mesh(doorFRGeometry, createMaterial(getPartColor('on_kapi_sag')))
  doorFR.userData = { partName: 'on_kapi_sag' }
  doorFR.castShadow = true
  doorFR.receiveShadow = true
  car.add(doorFR)
  carParts.set('on_kapi_sag', doorFR)

  // Rear Left Door (Sol Arka Kapı)
  const doorRLGeometry = new THREE.BoxGeometry(0.9, bodyHeight + cabinHeight - 0.1, 0.08)
  doorRLGeometry.translate(-0.4, (bodyHeight + cabinHeight - 0.1) / 2, bodyWidth / 2 + 0.04)
  const doorRL = new THREE.Mesh(doorRLGeometry, createMaterial(getPartColor('arka_kapi_sol')))
  doorRL.userData = { partName: 'arka_kapi_sol' }
  doorRL.castShadow = true
  doorRL.receiveShadow = true
  car.add(doorRL)
  carParts.set('arka_kapi_sol', doorRL)

  // Rear Right Door (Sağ Arka Kapı)
  const doorRRGeometry = new THREE.BoxGeometry(0.9, bodyHeight + cabinHeight - 0.1, 0.08)
  doorRRGeometry.translate(-0.4, (bodyHeight + cabinHeight - 0.1) / 2, -bodyWidth / 2 - 0.04)
  const doorRR = new THREE.Mesh(doorRRGeometry, createMaterial(getPartColor('arka_kapi_sag')))
  doorRR.userData = { partName: 'arka_kapi_sag' }
  doorRR.castShadow = true
  doorRR.receiveShadow = true
  car.add(doorRR)
  carParts.set('arka_kapi_sag', doorRR)

  // Cabin frame (non-clickable)
  const cabinShape = new THREE.Shape()
  cabinShape.moveTo(0.5, 0)
  cabinShape.lineTo(1.0, 0)
  cabinShape.lineTo(0.7, cabinHeight)
  cabinShape.lineTo(-0.8, cabinHeight)
  cabinShape.lineTo(-1.0, 0)
  cabinShape.lineTo(0.5, 0)
  
  const cabinExtrudeSettings = { 
    steps: 1, 
    depth: bodyWidth - 0.4, 
    bevelEnabled: false 
  }
  const cabinGeometry = new THREE.ExtrudeGeometry(cabinShape, cabinExtrudeSettings)
  cabinGeometry.translate(0, bodyHeight, -(bodyWidth - 0.4) / 2)
  const cabin = new THREE.Mesh(cabinGeometry, new THREE.MeshStandardMaterial({ 
    color: 0x2a2a2a,
    metalness: 0.3,
    roughness: 0.5
  }))
  cabin.castShadow = true
  cabin.receiveShadow = true
  car.add(cabin)

  // Windows (decorative)
  const windowGeometry = new THREE.PlaneGeometry(0.9, cabinHeight - 0.1)
  
  // Left front window
  const windowFL = new THREE.Mesh(windowGeometry, glassMaterial)
  windowFL.position.set(0.55, bodyHeight + cabinHeight / 2, bodyWidth / 2 - 0.15)
  windowFL.rotation.y = Math.PI / 2
  car.add(windowFL)
  
  // Right front window
  const windowFR = new THREE.Mesh(windowGeometry, glassMaterial)
  windowFR.position.set(0.55, bodyHeight + cabinHeight / 2, -bodyWidth / 2 + 0.15)
  windowFR.rotation.y = -Math.PI / 2
  car.add(windowFR)

  // Wheels
  const wheelGeometry = new THREE.CylinderGeometry(0.35, 0.35, 0.25, 32)
  wheelGeometry.rotateX(Math.PI / 2)
  
  const wheelPositions = [
    { x: 1.3, z: bodyWidth / 2 + 0.15 },
    { x: 1.3, z: -bodyWidth / 2 - 0.15 },
    { x: -1.3, z: bodyWidth / 2 + 0.15 },
    { x: -1.3, z: -bodyWidth / 2 - 0.15 }
  ]
  
  wheelPositions.forEach(pos => {
    const wheel = new THREE.Mesh(wheelGeometry, wheelMaterial)
    wheel.position.set(pos.x, 0.35, pos.z)
    wheel.castShadow = true
    car.add(wheel)
    
    // Rim
    const rimGeometry = new THREE.CylinderGeometry(0.25, 0.25, 0.26, 16)
    rimGeometry.rotateX(Math.PI / 2)
    const rimMaterial = new THREE.MeshStandardMaterial({ color: 0xcccccc, metalness: 0.9, roughness: 0.2 })
    const rim = new THREE.Mesh(rimGeometry, rimMaterial)
    rim.position.set(pos.x, 0.35, pos.z)
    car.add(rim)
  })

  // Headlights
  const headlightGeometry = new THREE.SphereGeometry(0.1, 16, 16)
  const headlightMaterial = new THREE.MeshBasicMaterial({ color: 0xffffcc })
  
  const headlightL = new THREE.Mesh(headlightGeometry, headlightMaterial)
  headlightL.position.set(bodyLength / 2 + 0.2, 0.3, bodyWidth / 3)
  car.add(headlightL)
  
  const headlightR = new THREE.Mesh(headlightGeometry, headlightMaterial)
  headlightR.position.set(bodyLength / 2 + 0.2, 0.3, -bodyWidth / 3)
  car.add(headlightR)

  // Taillights
  const taillightGeometry = new THREE.BoxGeometry(0.05, 0.1, 0.2)
  const taillightMaterial = new THREE.MeshBasicMaterial({ color: 0xff0000 })
  
  const taillightL = new THREE.Mesh(taillightGeometry, taillightMaterial)
  taillightL.position.set(-bodyLength / 2 - 0.2, 0.35, bodyWidth / 3)
  car.add(taillightL)
  
  const taillightR = new THREE.Mesh(taillightGeometry, taillightMaterial)
  taillightR.position.set(-bodyLength / 2 - 0.2, 0.35, -bodyWidth / 3)
  car.add(taillightR)

  return car
}

function initScene() {
  if (!canvas.value || !canvasContainer.value) return

  const width = canvasContainer.value.clientWidth
  const height = canvasContainer.value.clientHeight

  // Scene
  scene = new THREE.Scene()
  scene.background = new THREE.Color(0xf1f5f9)

  // Camera
  camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000)
  camera.position.set(6, 4, 6)
  camera.lookAt(0, 0.5, 0)

  // Renderer
  renderer = new THREE.WebGLRenderer({ 
    canvas: canvas.value, 
    antialias: true,
    alpha: true
  })
  renderer.setSize(width, height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 1.2

  // Controls
  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true
  controls.dampingFactor = 0.05
  controls.minDistance = 4
  controls.maxDistance = 15
  controls.maxPolarAngle = Math.PI / 2 + 0.1
  controls.target.set(0, 0.5, 0)

  // Lighting
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.5)
  scene.add(ambientLight)

  const directionalLight = new THREE.DirectionalLight(0xffffff, 1)
  directionalLight.position.set(10, 15, 10)
  directionalLight.castShadow = true
  directionalLight.shadow.mapSize.width = 2048
  directionalLight.shadow.mapSize.height = 2048
  directionalLight.shadow.camera.near = 0.5
  directionalLight.shadow.camera.far = 50
  directionalLight.shadow.camera.left = -10
  directionalLight.shadow.camera.right = 10
  directionalLight.shadow.camera.top = 10
  directionalLight.shadow.camera.bottom = -10
  scene.add(directionalLight)

  const fillLight = new THREE.DirectionalLight(0xffffff, 0.3)
  fillLight.position.set(-5, 5, -5)
  scene.add(fillLight)

  // Ground
  const groundGeometry = new THREE.PlaneGeometry(30, 30)
  const groundMaterial = new THREE.MeshStandardMaterial({ 
    color: 0xe2e8f0,
    roughness: 0.8,
    metalness: 0.1
  })
  const ground = new THREE.Mesh(groundGeometry, groundMaterial)
  ground.rotation.x = -Math.PI / 2
  ground.receiveShadow = true
  scene.add(ground)

  // Grid helper
  const gridHelper = new THREE.GridHelper(20, 40, 0xcccccc, 0xdddddd)
  gridHelper.position.y = 0.01
  scene.add(gridHelper)

  // Create car
  carGroup = createSedan()
  scene.add(carGroup)

  // Raycaster for interaction
  raycaster = new THREE.Raycaster()
  mouse = new THREE.Vector2()

  // Event listeners
  renderer.domElement.addEventListener('click', onCanvasClick)
  renderer.domElement.addEventListener('mousemove', onCanvasMouseMove)
  window.addEventListener('resize', onWindowResize)

  // Start animation
  animate()
}

function animate() {
  animationId = requestAnimationFrame(animate)
  
  if (autoRotate.value && carGroup) {
    carGroup.rotation.y += 0.005
  }
  
  controls.update()
  renderer.render(scene, camera)
}

function onWindowResize() {
  if (!canvasContainer.value) return
  
  const width = canvasContainer.value.clientWidth
  const height = canvasContainer.value.clientHeight
  
  camera.aspect = width / height
  camera.updateProjectionMatrix()
  renderer.setSize(width, height)
}

function onCanvasClick(event: MouseEvent) {
  if (!canvas.value) return
  
  const rect = canvas.value.getBoundingClientRect()
  mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
  mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1
  
  raycaster.setFromCamera(mouse, camera)
  const intersects = raycaster.intersectObjects(Array.from(carParts.values()), false)
  
  if (intersects.length > 0) {
    const mesh = intersects[0].object as THREE.Mesh
    const partName = mesh.userData.partName
    if (partName) {
      togglePart(partName)
    }
  }
}

function onCanvasMouseMove(event: MouseEvent) {
  if (!canvas.value) return
  
  const rect = canvas.value.getBoundingClientRect()
  mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
  mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1
  
  raycaster.setFromCamera(mouse, camera)
  const intersects = raycaster.intersectObjects(Array.from(carParts.values()), false)
  
  // Reset all parts to non-hovered state
  carParts.forEach((mesh) => {
    const mat = mesh.material as THREE.MeshPhysicalMaterial
    mat.emissive.setHex(0x000000)
  })
  
  if (intersects.length > 0) {
    const mesh = intersects[0].object as THREE.Mesh
    const partName = mesh.userData.partName
    hoveredPart.value = partName || null
    
    // Highlight hovered part
    const mat = mesh.material as THREE.MeshPhysicalMaterial
    mat.emissive.setHex(0x333333)
    
    canvas.value.style.cursor = 'pointer'
  } else {
    hoveredPart.value = null
    canvas.value.style.cursor = 'grab'
  }
}

function togglePart(part: string) {
  const newValue = { ...props.modelValue }
  const currentStatus = newValue[part] || 'orijinal'
  
  if (currentStatus === selectedStatus.value) {
    newValue[part] = 'orijinal'
  } else {
    newValue[part] = selectedStatus.value
  }
  
  emit('update:modelValue', newValue)
  updatePartColors()
}

function updatePartColors() {
  carParts.forEach((mesh, partName) => {
    const color = getPartColor(partName)
    const material = mesh.material as THREE.MeshPhysicalMaterial
    material.color.setHex(color)
  })
}

function resetCamera() {
  camera.position.set(6, 4, 6)
  controls.target.set(0, 0.5, 0)
  if (carGroup) {
    carGroup.rotation.y = 0
  }
}

function toggleAutoRotate() {
  autoRotate.value = !autoRotate.value
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
  updatePartColors()
}

// Watch for external changes to modelValue
watch(() => props.modelValue, () => {
  updatePartColors()
}, { deep: true })

onMounted(() => {
  // Small delay to ensure DOM is ready
  setTimeout(initScene, 100)
})

onUnmounted(() => {
  cancelAnimationFrame(animationId)
  
  renderer?.domElement.removeEventListener('click', onCanvasClick)
  renderer?.domElement.removeEventListener('mousemove', onCanvasMouseMove)
  window.removeEventListener('resize', onWindowResize)
  
  // Dispose Three.js resources
  scene?.traverse((object) => {
    if (object instanceof THREE.Mesh) {
      object.geometry.dispose()
      if (Array.isArray(object.material)) {
        object.material.forEach(mat => mat.dispose())
      } else {
        object.material.dispose()
      }
    }
  })
  
  renderer?.dispose()
  controls?.dispose()
})
</script>
