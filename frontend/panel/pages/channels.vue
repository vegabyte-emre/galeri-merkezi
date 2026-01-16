<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Kanal Yönetimi</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Pazar yerleri ile entegrasyonlarınızı yönetin</p>
      </div>
      <button
        @click="showAddModal = true"
        class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
      >
        <Plus class="w-4 h-4 inline mr-2" />
        Yeni Kanal Bağla
      </button>
    </div>

    <!-- Channels Grid -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="channel in channels"
        :key="channel.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border-2 p-6 transition-all"
        :class="channel.status === 'connected' 
          ? 'border-green-500' 
          : channel.status === 'pending' 
          ? 'border-yellow-500' 
          : 'border-gray-200 dark:border-gray-700'"
      >
        <!-- Channel Header -->
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold">
              {{ channel.name.charAt(0) }}
            </div>
            <div>
              <h3 class="font-bold text-gray-900 dark:text-white">{{ channel.name }}</h3>
              <p class="text-xs text-gray-500 dark:text-gray-400">{{ channel.type }}</p>
            </div>
          </div>
          <span
            class="px-2 py-1 text-xs font-semibold rounded-full"
            :class="{
              'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': channel.status === 'connected',
              'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': channel.status === 'pending',
              'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400': channel.status === 'disconnected'
            }"
          >
            {{ statusLabels[channel.status] }}
          </span>
        </div>

        <!-- Channel Stats -->
        <div v-if="channel.status === 'connected'" class="mb-4 space-y-2">
          <div class="flex items-center justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">Aktif İlan</span>
            <span class="font-semibold text-gray-900 dark:text-white">{{ channel.activeListings }}</span>
          </div>
          <div class="flex items-center justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">Bu Ay Görüntülenme</span>
            <span class="font-semibold text-gray-900 dark:text-white">{{ channel.views }}</span>
          </div>
          <div class="flex items-center justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">Bu Ay Lead</span>
            <span class="font-semibold text-gray-900 dark:text-white">{{ channel.leads }}</span>
          </div>
        </div>

        <!-- Channel Actions -->
        <div class="flex items-center gap-2 pt-4 border-t border-gray-200 dark:border-gray-700">
          <button
            v-if="channel.status === 'disconnected'"
            @click="connectChannel(channel.id)"
            class="flex-1 px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold text-sm"
          >
            Bağlan
          </button>
          <button
            v-if="channel.status === 'connected'"
            @click="disconnectChannel(channel.id)"
            class="flex-1 px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold text-sm"
          >
            Bağlantıyı Kes
          </button>
          <button
            v-if="channel.status === 'connected'"
            @click="configureChannel(channel.id)"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold text-sm"
          >
            Ayarlar
          </button>
        </div>
      </div>
    </div>

    <!-- Sync Status -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white">Senkronizasyon Durumu</h3>
        <button
          @click="syncAll"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          <RefreshCw class="w-4 h-4 inline mr-2" />
          Tümünü Senkronize Et
        </button>
      </div>
      <div class="space-y-3">
        <div
          v-for="sync in syncStatus"
          :key="sync.channel"
          class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl"
        >
          <div class="flex items-center gap-3">
            <div
              class="w-3 h-3 rounded-full"
              :class="sync.status === 'success' 
                ? 'bg-green-500' 
                : sync.status === 'syncing' 
                ? 'bg-yellow-500 animate-pulse' 
                : 'bg-gray-400'"
            ></div>
            <span class="font-medium text-gray-900 dark:text-white">{{ sync.channel }}</span>
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400">
            {{ sync.lastSync }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Plus, RefreshCw } from 'lucide-vue-next'
import { ref } from 'vue'

const showAddModal = ref(false)

const statusLabels: Record<string, string> = {
  connected: 'Bağlı',
  pending: 'Bekliyor',
  disconnected: 'Bağlı Değil'
}

const channels = ref([
  {
    id: 1,
    name: 'Sahibinden',
    type: 'Pazar Yeri',
    status: 'connected',
    activeListings: 42,
    views: 8450,
    leads: 120
  },
  {
    id: 2,
    name: 'Arabam',
    type: 'Pazar Yeri',
    status: 'connected',
    activeListings: 38,
    views: 3200,
    leads: 45
  },
  {
    id: 3,
    name: 'Otomobil.com',
    type: 'Pazar Yeri',
    status: 'pending',
    activeListings: 0,
    views: 0,
    leads: 0
  },
  {
    id: 4,
    name: 'İlan Ver',
    type: 'Pazar Yeri',
    status: 'disconnected',
    activeListings: 0,
    views: 0,
    leads: 0
  }
])

const syncStatus = ref([
  { channel: 'Sahibinden', status: 'success', lastSync: '2 dakika önce' },
  { channel: 'Arabam', status: 'success', lastSync: '5 dakika önce' },
  { channel: 'Otomobil.com', status: 'syncing', lastSync: 'Senkronize ediliyor...' }
])

const connectChannel = async (id: number) => {
  const channel = channels.value.find(c => c.id === id)
  if (channel) {
    try {
      const api = useApi()
      await api.post(`/channels/${id}/connect`)
      channel.status = 'pending'
    } catch (error: any) {
      alert('Hata: ' + error.message)
    }
  }
}

const disconnectChannel = async (id: number) => {
  if (confirm('Bu kanalın bağlantısını kesmek istediğinize emin misiniz?')) {
    const channel = channels.value.find(c => c.id === id)
    if (channel) {
      try {
        const api = useApi()
        await api.post(`/channels/${id}/disconnect`)
        channel.status = 'disconnected'
      } catch (error: any) {
        alert('Hata: ' + error.message)
      }
    }
  }
}

const configureChannel = (id: number) => {
  const channel = channels.value.find(c => c.id === id)
  if (channel) {
    const apiKey = prompt(`${channel.name} API Anahtarı:`, '')
    if (apiKey) {
      const api = useApi()
      api.post(`/channels/${id}/configure`, { apiKey })
        .then(() => {
          alert('Kanal yapılandırması kaydedildi!')
        })
        .catch((error: any) => {
          alert('Hata: ' + error.message)
        })
    }
  }
}

const syncAll = async () => {
  try {
    const api = useApi()
    await api.post('/channels/sync-all')
    alert('Tüm kanallar senkronize ediliyor...')
    
    // Update sync status
    syncStatus.value.forEach(sync => {
      sync.status = 'syncing'
      sync.lastSync = 'Senkronize ediliyor...'
    })
  } catch (error: any) {
    alert('Hata: ' + error.message)
  }
}
</script>

