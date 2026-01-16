<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Yedekleme & Geri Yükleme</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Veritabanı yedeklemelerini yönetin</p>
      </div>
      <button
        @click="createBackup"
        :disabled="creatingBackup"
        class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <Download class="w-4 h-4 inline mr-2" />
        {{ creatingBackup ? 'Yedekleme Oluşturuluyor...' : 'Yeni Yedekleme Oluştur' }}
      </button>
    </div>

    <!-- Backup Stats -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Toplam Yedekleme</div>
        <div class="text-3xl font-bold text-gray-900 dark:text-white">{{ backups.length }}</div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Toplam Boyut</div>
        <div class="text-3xl font-bold text-gray-900 dark:text-white">{{ totalSize }}</div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Son Yedekleme</div>
        <div class="text-lg font-bold text-gray-900 dark:text-white">{{ lastBackupDate }}</div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Otomatik Yedekleme</div>
        <div class="text-lg font-bold text-gray-900 dark:text-white">
          <span :class="autoBackup ? 'text-green-600 dark:text-green-400' : 'text-gray-400'">
            {{ autoBackup ? 'Aktif' : 'Pasif' }}
          </span>
        </div>
      </div>
    </div>

    <!-- Backup Schedule -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white">Otomatik Yedekleme Ayarları</h3>
        <label class="relative inline-flex items-center cursor-pointer">
          <input
            v-model="autoBackup"
            type="checkbox"
            class="sr-only peer"
          />
          <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 dark:peer-focus:ring-primary-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-primary-600"></div>
        </label>
      </div>
      <div v-if="autoBackup" class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Yedekleme Sıklığı
          </label>
          <select
            v-model="backupFrequency"
            class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          >
            <option value="daily">Günlük</option>
            <option value="weekly">Haftalık</option>
            <option value="monthly">Aylık</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Yedekleme Saati
          </label>
          <input
            v-model="backupTime"
            type="time"
            class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          />
        </div>
      </div>
      <button
        v-if="autoBackup"
        @click="saveSchedule"
        class="mt-4 px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold"
      >
        Ayarları Kaydet
      </button>
    </div>

    <!-- Backups List -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700">
      <div class="p-6 border-b border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white">Yedeklemeler</h3>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Tarih</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Boyut</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Tip</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Durum</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">İşlemler</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="backup in backups"
              :key="backup.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                {{ formatDateTime(backup.createdAt) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400">
                {{ backup.size }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="backup.type === 'manual' 
                    ? 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400' 
                    : 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400'"
                >
                  {{ backup.type === 'manual' ? 'Manuel' : 'Otomatik' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="backup.status === 'completed' 
                    ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' 
                    : 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400'"
                >
                  {{ backup.status === 'completed' ? 'Tamamlandı' : 'İşleniyor' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center gap-2">
                  <button
                    @click="downloadBackup(backup.id)"
                    class="px-3 py-1.5 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold text-xs"
                  >
                    İndir
                  </button>
                  <button
                    @click="restoreBackup(backup.id)"
                    class="px-3 py-1.5 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-lg hover:bg-green-200 dark:hover:bg-green-900/50 transition-colors font-semibold text-xs"
                  >
                    Geri Yükle
                  </button>
                  <button
                    @click="deleteBackup(backup.id)"
                    class="px-3 py-1.5 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold text-xs"
                  >
                    Sil
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Download } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const creatingBackup = ref(false)
const autoBackup = ref(true)
const backupFrequency = ref('daily')
const backupTime = ref('02:00')
const loading = ref(false)

const backups = ref<any[]>([])

const loadBackups = async () => {
  loading.value = true
  try {
    const data = await api.get('/backup')
    backups.value = data.backups || data || []
    
    // Load schedule settings
    if (data.schedule) {
      autoBackup.value = data.schedule.enabled || false
      backupFrequency.value = data.schedule.frequency || 'daily'
      backupTime.value = data.schedule.time || '02:00'
    }
  } catch (error: any) {
    console.error('Yedeklemeler yüklenemedi:', error)
    toast.error('Yedeklemeler yüklenemedi: ' + (error.message || 'Bilinmeyen hata'))
  } finally {
    loading.value = false
  }
}

const totalSize = computed(() => {
  if (backups.value.length === 0) return '0 GB'
  const totalBytes = backups.value.reduce((sum, b) => {
    const sizeStr = b.size || '0 GB'
    const sizeNum = parseFloat(sizeStr)
    const unit = sizeStr.includes('MB') ? 1024 : sizeStr.includes('GB') ? 1024 * 1024 : 1
    return sum + (sizeNum * unit)
  }, 0)
  if (totalBytes >= 1024 * 1024) {
    return `${(totalBytes / (1024 * 1024)).toFixed(1)} GB`
  } else if (totalBytes >= 1024) {
    return `${(totalBytes / 1024).toFixed(1)} MB`
  }
  return `${totalBytes.toFixed(1)} KB`
})

const lastBackupDate = computed(() => {
  if (backups.value.length === 0) return 'Henüz yok'
  return formatDateTime(backups.value[0].createdAt)
})

const formatDateTime = (timestamp: string) => {
  return new Date(timestamp).toLocaleString('tr-TR')
}

const createBackup = async () => {
  creatingBackup.value = true
  try {
    const api = useApi()
    const response = await api.post('/backup/create')
    backups.value.unshift({
      id: response.id,
      createdAt: response.createdAt,
      size: response.size,
      type: 'manual',
      status: 'completed'
    })
    toast.success('Yedekleme başarıyla oluşturuldu!')
    await loadBackups()
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    creatingBackup.value = false
  }
}

const downloadBackup = async (id: number) => {
  try {
    const api = useApi()
    const blob = await api.get(`/backup/${id}/download`, { responseType: 'blob' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `backup-${id}.sql`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
    toast.success('Yedekleme indirildi!')
  } catch (error: any) {
    toast.error('İndirme başarısız: ' + error.message)
  }
}

const restoreBackup = async (id: number) => {
  if (confirm('Bu yedeklemeyi geri yüklemek istediğinize emin misiniz? Bu işlem mevcut verileri değiştirecektir.')) {
    try {
      const api = useApi()
      await api.post(`/backup/${id}/restore`)
      toast.success('Yedekleme geri yüklendi!')
    } catch (error: any) {
      alert('Hata: ' + error.message)
    }
  }
}

const deleteBackup = async (id: number) => {
  if (confirm('Bu yedeklemeyi silmek istediğinize emin misiniz?')) {
    try {
      const api = useApi()
      await api.delete(`/backup/${id}`)
      backups.value = backups.value.filter(b => b.id !== id)
      toast.success('Yedekleme silindi!')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const saveSchedule = async () => {
  try {
    const api = useApi()
    await api.put('/backup/schedule', {
      enabled: autoBackup.value,
      frequency: backupFrequency.value,
      time: backupTime.value
    })
    toast.success('Yedekleme ayarları kaydedildi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

onMounted(() => {
  loadBackups()
})
</script>

