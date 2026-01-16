<template>
  <div class="space-y-6">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">API Dokümantasyonu</h1>
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Platform API'sini kullanarak entegrasyonlar geliştirin</p>
    </div>

    <!-- Quick Start -->
    <div class="bg-gradient-to-r from-primary-600 to-primary-800 rounded-2xl p-8 text-white">
      <h2 class="text-xl font-bold mb-4">Hızlı Başlangıç</h2>
      <div class="space-y-4">
        <div>
          <div class="text-sm text-primary-100 mb-2">Base URL</div>
          <code class="block px-4 py-2 bg-white/20 rounded-lg font-mono text-sm">https://api.galerimerkezi.com/v1</code>
        </div>
        <div>
          <div class="text-sm text-primary-100 mb-2">Authentication</div>
          <code class="block px-4 py-2 bg-white/20 rounded-lg font-mono text-sm">Authorization: Bearer YOUR_API_KEY</code>
        </div>
      </div>
    </div>

    <!-- API Endpoints -->
    <div class="space-y-6">
      <div
        v-for="endpoint in endpoints"
        :key="endpoint.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6"
      >
        <div class="flex items-start justify-between mb-4">
          <div class="flex-1">
            <div class="flex items-center gap-3 mb-2">
              <span
                class="px-3 py-1 text-xs font-semibold rounded-full"
                :class="{
                  'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': endpoint.method === 'GET',
                  'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400': endpoint.method === 'POST',
                  'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': endpoint.method === 'PUT',
                  'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400': endpoint.method === 'DELETE'
                }"
              >
                {{ endpoint.method }}
              </span>
              <code class="text-sm font-mono text-gray-900 dark:text-white">{{ endpoint.path }}</code>
            </div>
            <p class="text-sm text-gray-600 dark:text-gray-400">{{ endpoint.description }}</p>
          </div>
          <button
            @click="toggleEndpoint(endpoint.id)"
            class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          >
            <ChevronDown
              class="w-5 h-5 text-gray-400"
              :class="{ 'rotate-180': openEndpoints.includes(endpoint.id) }"
            />
          </button>
        </div>

        <!-- Expanded Content -->
        <div v-if="openEndpoints.includes(endpoint.id)" class="space-y-4 pt-4 border-t border-gray-200 dark:border-gray-700">
          <!-- Request Example -->
          <div>
            <h4 class="font-semibold text-gray-900 dark:text-white mb-2">Request Example</h4>
            <pre class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg overflow-x-auto"><code class="text-sm">{{ endpoint.requestExample }}</code></pre>
          </div>

          <!-- Response Example -->
          <div>
            <h4 class="font-semibold text-gray-900 dark:text-white mb-2">Response Example</h4>
            <pre class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg overflow-x-auto"><code class="text-sm">{{ endpoint.responseExample }}</code></pre>
          </div>

          <!-- Parameters -->
          <div v-if="endpoint.parameters && endpoint.parameters.length > 0">
            <h4 class="font-semibold text-gray-900 dark:text-white mb-2">Parameters</h4>
            <div class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead class="bg-gray-50 dark:bg-gray-700/50">
                  <tr>
                    <th class="px-4 py-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400">Parametre</th>
                    <th class="px-4 py-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400">Tip</th>
                    <th class="px-4 py-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400">Gerekli</th>
                    <th class="px-4 py-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400">Açıklama</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                  <tr
                    v-for="param in endpoint.parameters"
                    :key="param.name"
                  >
                    <td class="px-4 py-2 font-mono text-gray-900 dark:text-white">{{ param.name }}</td>
                    <td class="px-4 py-2 text-gray-600 dark:text-gray-400">{{ param.type }}</td>
                    <td class="px-4 py-2">
                      <span
                        class="px-2 py-1 text-xs rounded-full"
                        :class="param.required 
                          ? 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400' 
                          : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400'"
                      >
                        {{ param.required ? 'Evet' : 'Hayır' }}
                      </span>
                    </td>
                    <td class="px-4 py-2 text-gray-600 dark:text-gray-400">{{ param.description }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ChevronDown } from 'lucide-vue-next'
import { ref } from 'vue'

const openEndpoints = ref<number[]>([])

const endpoints = ref([
  {
    id: 1,
    method: 'GET',
    path: '/vehicles',
    description: 'Tüm araçları listeler',
    requestExample: `GET /api/v1/vehicles
Headers:
  Authorization: Bearer YOUR_API_KEY
Query Parameters:
  ?page=1&limit=20&brand=BMW`,
    responseExample: `{
  "data": [
    {
      "id": 1,
      "brand": "BMW",
      "model": "320i",
      "year": 2020,
      "price": 850000
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}`,
    parameters: [
      { name: 'page', type: 'integer', required: false, description: 'Sayfa numarası' },
      { name: 'limit', type: 'integer', required: false, description: 'Sayfa başına kayıt sayısı' },
      { name: 'brand', type: 'string', required: false, description: 'Marka filtresi' }
    ]
  },
  {
    id: 2,
    method: 'POST',
    path: '/vehicles',
    description: 'Yeni araç oluşturur',
    requestExample: `POST /api/v1/vehicles
Headers:
  Authorization: Bearer YOUR_API_KEY
  Content-Type: application/json

Body:
{
  "brand": "BMW",
  "model": "320i",
  "year": 2020,
  "km": 45000,
  "price": 850000
}`,
    responseExample: `{
  "id": 1,
  "brand": "BMW",
  "model": "320i",
  "year": 2020,
  "km": 45000,
  "price": 850000,
  "createdAt": "2024-01-20T10:00:00Z"
}`,
    parameters: [
      { name: 'brand', type: 'string', required: true, description: 'Araç markası' },
      { name: 'model', type: 'string', required: true, description: 'Araç modeli' },
      { name: 'year', type: 'integer', required: true, description: 'Üretim yılı' },
      { name: 'km', type: 'integer', required: true, description: 'Kilometre' },
      { name: 'price', type: 'integer', required: true, description: 'Fiyat (TL)' }
    ]
  },
  {
    id: 3,
    method: 'GET',
    path: '/vehicles/{id}',
    description: 'Belirli bir aracın detaylarını getirir',
    requestExample: `GET /api/v1/vehicles/1
Headers:
  Authorization: Bearer YOUR_API_KEY`,
    responseExample: `{
  "id": 1,
  "brand": "BMW",
  "model": "320i",
  "year": 2020,
  "km": 45000,
  "price": 850000,
  "fuelType": "Benzin",
  "transmission": "Otomatik",
  "color": "Siyah"
}`,
    parameters: [
      { name: 'id', type: 'integer', required: true, description: 'Araç ID' }
    ]
  },
  {
    id: 4,
    method: 'PUT',
    path: '/vehicles/{id}',
    description: 'Araç bilgilerini günceller',
    requestExample: `PUT /api/v1/vehicles/1
Headers:
  Authorization: Bearer YOUR_API_KEY
  Content-Type: application/json

Body:
{
  "price": 800000
}`,
    responseExample: `{
  "id": 1,
  "price": 800000,
  "updatedAt": "2024-01-20T11:00:00Z"
}`,
    parameters: [
      { name: 'id', type: 'integer', required: true, description: 'Araç ID' },
      { name: 'price', type: 'integer', required: false, description: 'Yeni fiyat' }
    ]
  },
  {
    id: 5,
    method: 'DELETE',
    path: '/vehicles/{id}',
    description: 'Aracı siler',
    requestExample: `DELETE /api/v1/vehicles/1
Headers:
  Authorization: Bearer YOUR_API_KEY`,
    responseExample: `{
  "message": "Araç başarıyla silindi"
}`,
    parameters: [
      { name: 'id', type: 'integer', required: true, description: 'Araç ID' }
    ]
  }
])

const toggleEndpoint = (id: number) => {
  const index = openEndpoints.value.indexOf(id)
  if (index > -1) {
    openEndpoints.value.splice(index, 1)
  } else {
    openEndpoints.value.push(id)
  }
}
</script>














