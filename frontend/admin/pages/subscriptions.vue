<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Abonelik Yönetimi</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Galeri aboneliklerini yönetin ve ödemeleri takip edin</p>
      </div>
      <div class="flex items-center gap-3">
        <button
          @click="showCreateModal = true"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          <Plus class="w-4 h-4 inline mr-2" />
          Yeni Abonelik
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400">Toplam Abonelik</div>
        <div class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ subscriptions.length }}</div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400">Aktif Abonelik</div>
        <div class="text-2xl font-bold text-green-600 dark:text-green-400 mt-1">{{ activeCount }}</div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400">Süresi Dolan</div>
        <div class="text-2xl font-bold text-red-600 dark:text-red-400 mt-1">{{ expiredCount }}</div>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-600 dark:text-gray-400">Aylık Gelir</div>
        <div class="text-2xl font-bold text-primary-600 dark:text-primary-400 mt-1">₺{{ monthlyRevenue.toLocaleString('tr-TR') }}</div>
      </div>
    </div>

    <!-- Subscriptions Table -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Galeri</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Plan</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Ödeme Tipi</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Başlangıç</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Bitiş</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Durum</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">İşlemler</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="subscription in subscriptions"
              :key="subscription.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold">
                    {{ subscription.galleryName.charAt(0) }}
                  </div>
                  <div>
                    <div class="font-medium text-gray-900 dark:text-white">{{ subscription.galleryName }}</div>
                    <div class="text-sm text-gray-500 dark:text-gray-400">{{ subscription.galleryEmail }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400': subscription.plan === 'basic',
                    'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400': subscription.plan === 'premium',
                    'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': subscription.plan === 'enterprise'
                  }"
                >
                  {{ planLabels[subscription.plan] }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                {{ subscription.paymentType === 'monthly' ? 'Aylık' : 'Yıllık' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatDate(subscription.startDate) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatDate(subscription.endDate) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': subscription.status === 'active',
                    'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400': subscription.status === 'expired',
                    'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': subscription.status === 'trial',
                    'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400': subscription.status === 'cancelled'
                  }"
                >
                  {{ statusLabels[subscription.status] }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex items-center justify-end gap-2">
                  <button
                    @click="editSubscription(subscription)"
                    class="px-3 py-1.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-xs font-semibold"
                  >
                    Düzenle
                  </button>
                  <button
                    v-if="subscription.status === 'active'"
                    @click="extendTrial(subscription.id)"
                    class="px-3 py-1.5 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-lg hover:bg-green-200 dark:hover:bg-green-900/50 transition-colors text-xs font-semibold"
                  >
                    Süre Uzat
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Create/Edit Subscription Modal -->
    <div
      v-if="showCreateModal || showEditModal"
      class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      @click.self="closeModal"
    >
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto">
        <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">
          {{ showEditModal ? 'Abonelik Düzenle' : 'Yeni Abonelik Oluştur' }}
        </h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Galeri
            </label>
            <select
              v-model="subscriptionForm.galleryId"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
              <option value="">Galeri Seçin</option>
              <option v-for="gallery in galleries" :key="gallery.id" :value="gallery.id">
                {{ gallery.name }}
              </option>
            </select>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Plan
              </label>
              <select
                v-model="subscriptionForm.plan"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="basic">Temel</option>
                <option value="premium">Premium</option>
                <option value="enterprise">Kurumsal</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Ödeme Tipi
              </label>
              <select
                v-model="subscriptionForm.paymentType"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="monthly">Aylık</option>
                <option value="yearly">Yıllık</option>
              </select>
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Başlangıç Tarihi
              </label>
              <input
                v-model="subscriptionForm.startDate"
                type="date"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Bitiş Tarihi
              </label>
              <input
                v-model="subscriptionForm.endDate"
                type="date"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
          </div>
          <div>
            <label class="flex items-center gap-2">
              <input
                v-model="subscriptionForm.isTrial"
                type="checkbox"
                class="w-4 h-4 text-primary-600 rounded"
              />
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Ücretsiz Deneme</span>
            </label>
          </div>
          <div v-if="subscriptionForm.isTrial">
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Deneme Süresi (Gün)
            </label>
            <input
              v-model.number="subscriptionForm.trialDays"
              type="number"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="30"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Durum
            </label>
            <select
              v-model="subscriptionForm.status"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
              <option value="active">Aktif</option>
              <option value="trial">Deneme</option>
              <option value="expired">Süresi Dolmuş</option>
              <option value="cancelled">İptal Edilmiş</option>
            </select>
          </div>
        </div>
        <div class="flex items-center justify-end gap-3 mt-6">
          <button
            @click="closeModal"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          >
            İptal
          </button>
          <button
            @click="saveSubscription"
            class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            {{ showEditModal ? 'Güncelle' : 'Oluştur' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Plus } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const subscriptions = ref<any[]>([])
const galleries = ref<any[]>([])

const subscriptionForm = ref({
  galleryId: null as number | null,
  plan: 'basic',
  paymentType: 'monthly',
  startDate: '',
  endDate: '',
  isTrial: false,
  trialDays: 30,
  status: 'active'
})

const planLabels: Record<string, string> = {
  basic: 'Temel',
  premium: 'Premium',
  enterprise: 'Kurumsal'
}

const statusLabels: Record<string, string> = {
  active: 'Aktif',
  expired: 'Süresi Dolmuş',
  trial: 'Deneme',
  cancelled: 'İptal Edilmiş'
}

const activeCount = computed(() => subscriptions.value.filter(s => s.status === 'active').length)
const expiredCount = computed(() => subscriptions.value.filter(s => s.status === 'expired').length)
const monthlyRevenue = computed(() => {
  return subscriptions.value
    .filter(s => s.status === 'active' && s.paymentType === 'monthly')
    .reduce((sum, s) => {
      const planPrices: Record<string, number> = { basic: 500, premium: 1500, enterprise: 3000 }
      return sum + (planPrices[s.plan] || 0)
    }, 0)
})

const loadSubscriptions = async () => {
  loading.value = true
  try {
    const data = await api.get('/subscriptions')
    subscriptions.value = data.subscriptions || data || []
  } catch (error: any) {
    console.error('Abonelikler yüklenemedi:', error)
    toast.error('Abonelikler yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const loadGalleries = async () => {
  try {
    const data = await api.get('/galleries')
    galleries.value = data.galleries || data || []
  } catch (error: any) {
    console.error('Galeriler yüklenemedi:', error)
  }
}

const editSubscription = (subscription: any) => {
  subscriptionForm.value = {
    galleryId: subscription.galleryId,
    plan: subscription.plan,
    paymentType: subscription.paymentType,
    startDate: subscription.startDate.split('T')[0],
    endDate: subscription.endDate.split('T')[0],
    isTrial: subscription.status === 'trial',
    trialDays: subscription.trialDays || 30,
    status: subscription.status
  }
  showEditModal.value = true
}

const extendTrial = async (id: number) => {
  const subscription = subscriptions.value.find(s => s.id === id)
  if (!subscription) return
  
  const days = prompt('Kaç gün uzatmak istiyorsunuz?', '30')
  if (!days || isNaN(Number(days))) return
  
  try {
    await api.post(`/subscriptions/${id}/extend-trial`, { days: Number(days) })
    toast.success('Deneme süresi uzatıldı!')
    await loadSubscriptions()
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const saveSubscription = async () => {
  if (!subscriptionForm.value.galleryId) {
    toast.warning('Lütfen bir galeri seçin')
    return
  }
  
  try {
    if (showEditModal.value) {
      const subscription = subscriptions.value.find(s => s.galleryId === subscriptionForm.value.galleryId)
      if (subscription) {
        await api.put(`/subscriptions/${subscription.id}`, subscriptionForm.value)
        toast.success('Abonelik güncellendi!')
      }
    } else {
      await api.post('/subscriptions', subscriptionForm.value)
      toast.success('Abonelik oluşturuldu!')
    }
    closeModal()
    await loadSubscriptions()
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const closeModal = () => {
  showCreateModal.value = false
  showEditModal.value = false
  subscriptionForm.value = {
    galleryId: null,
    plan: 'basic',
    paymentType: 'monthly',
    startDate: '',
    endDate: '',
    isTrial: false,
    trialDays: 30,
    status: 'active'
  }
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR')
}

onMounted(() => {
  loadSubscriptions()
  loadGalleries()
})
</script>

