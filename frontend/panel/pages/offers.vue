<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Teklifler</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Gelen ve giden teklifleri yönetin</p>
      </div>
      <div class="flex items-center gap-3">
        <button
          @click="activeTab = 'incoming'"
          class="px-4 py-2 rounded-lg font-semibold transition-colors"
          :class="activeTab === 'incoming' 
            ? 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400' 
            : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300'"
        >
          Gelen Teklifler ({{ incomingOffers.length }})
        </button>
        <button
          @click="activeTab = 'outgoing'"
          class="px-4 py-2 rounded-lg font-semibold transition-colors"
          :class="activeTab === 'outgoing' 
            ? 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400' 
            : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300'"
        >
          Giden Teklifler ({{ outgoingOffers.length }})
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600 dark:text-gray-400">Yükleniyor...</p>
    </div>

    <!-- Incoming Offers -->
    <div v-else-if="activeTab === 'incoming'" class="space-y-4">
      <div
        v-for="offer in incomingOffers"
        :key="offer.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 hover:shadow-xl transition-all"
      >
        <div class="flex items-start justify-between">
          <div class="flex-1">
            <div class="flex items-center gap-4 mb-4">
              <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center flex-shrink-0">
                <Car class="w-8 h-8 text-white" />
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-1">
                  {{ offer.vehicle.brand }} {{ offer.vehicle.model }}
                </h3>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  {{ offer.from }} • {{ formatDate(offer.date) }}
                </p>
              </div>
            </div>
            <div class="grid grid-cols-3 gap-4">
              <div>
                <div class="text-sm text-gray-600 dark:text-gray-400">Teklif Fiyatı</div>
                <div class="text-xl font-bold text-primary-600 dark:text-primary-400">{{ (offer.price || 0).toLocaleString('tr-TR') }} ₺</div>
              </div>
              <div>
                <div class="text-sm text-gray-600 dark:text-gray-400">Araç Fiyatı</div>
                <div class="text-lg font-semibold text-gray-900 dark:text-white">{{ (offer.vehicle.price || 0).toLocaleString('tr-TR') }} ₺</div>
              </div>
              <div>
                <div class="text-sm text-gray-600 dark:text-gray-400">Durum</div>
                <span
                  class="inline-block px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': offer.status === 'pending' || offer.status === 'sent' || offer.status === 'viewed',
                    'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': offer.status === 'accepted',
                    'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400': offer.status === 'rejected' || offer.status === 'cancelled' || offer.status === 'expired',
                    'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400': offer.status === 'counter_offer'
                  }"
                >
                  {{ statusLabels[offer.status] || offer.status }}
                </span>
              </div>
            </div>
            <p v-if="offer.message" class="text-sm text-gray-600 dark:text-gray-400 mb-4">
              {{ offer.message }}
            </p>
          </div>
          <div v-if="offer.status === 'pending' || offer.status === 'sent' || offer.status === 'viewed'" class="flex flex-col gap-2 ml-4">
            <button
              @click="acceptOffer(offer.id)"
              class="px-4 py-2 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-lg hover:bg-green-200 dark:hover:bg-green-900/50 transition-colors font-semibold"
            >
              Kabul Et
            </button>
            <button
              @click="rejectOffer(offer.id)"
              class="px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold"
            >
              Reddet
            </button>
            <button
              @click="counterOffer(offer.id)"
              class="px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold"
            >
              Karşı Teklif
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Outgoing Offers -->
    <div v-else-if="activeTab === 'outgoing'" class="space-y-4">
      <div
        v-for="offer in outgoingOffers"
        :key="offer.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 hover:shadow-xl transition-all"
      >
        <div class="flex items-start justify-between">
          <div class="flex-1">
            <div class="flex items-center gap-4 mb-4">
              <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center flex-shrink-0">
                <Car class="w-8 h-8 text-white" />
              </div>
              <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-1">
                  {{ offer.vehicle.brand }} {{ offer.vehicle.model }}
                </h3>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  {{ offer.to }} • {{ formatDate(offer.date) }}
                </p>
              </div>
            </div>
            <div class="grid grid-cols-3 gap-4">
              <div>
                <div class="text-sm text-gray-600 dark:text-gray-400">Teklif Fiyatı</div>
                <div class="text-xl font-bold text-primary-600 dark:text-primary-400">{{ offer.price }} ₺</div>
              </div>
              <div>
                <div class="text-sm text-gray-600 dark:text-gray-400">Araç Fiyatı</div>
                <div class="text-lg font-semibold text-gray-900 dark:text-white">{{ offer.vehicle.price }} ₺</div>
              </div>
              <div>
                <div class="text-sm text-gray-600 dark:text-gray-400">Durum</div>
                <span
                  class="inline-block px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400': offer.status === 'pending',
                    'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': offer.status === 'accepted',
                    'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400': offer.status === 'rejected'
                  }"
                >
                  {{ statusLabels[offer.status] }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else-if="!loading && ((activeTab === 'incoming' && incomingOffers.length === 0) || (activeTab === 'outgoing' && outgoingOffers.length === 0))" class="text-center py-16 bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700">
      <Car class="w-24 h-24 text-gray-400 mx-auto mb-4" />
      <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Henüz Teklif Yok</h3>
      <p class="text-gray-600 dark:text-gray-400">
        {{ activeTab === 'incoming' ? 'Gelen teklif bulunmuyor.' : 'Giden teklif bulunmuyor.' }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Car } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const activeTab = ref('incoming')
const loading = ref(false)

const statusLabels: Record<string, string> = {
  pending: 'Bekliyor',
  sent: 'Gönderildi',
  viewed: 'Görüntülendi',
  accepted: 'Kabul Edildi',
  rejected: 'Reddedildi',
  counter_offer: 'Karşı Teklif',
  cancelled: 'İptal Edildi',
  expired: 'Süresi Doldu'
}

const incomingOffers = ref<any[]>([])
const outgoingOffers = ref<any[]>([])

const loadOffers = async () => {
  loading.value = true
  try {
    // Load incoming offers
    const incomingRes = await api.get<{ success: boolean; data?: any[] }>('/offers/incoming')
    if (incomingRes.success && incomingRes.data) {
      incomingOffers.value = incomingRes.data.map((o: any) => ({
        id: o.id,
        vehicle: {
          brand: o.brand,
          model: o.model,
          price: o.base_price
        },
        from: o.buyer_gallery_name || 'Galeri',
        price: o.amount,
        status: o.status,
        date: o.created_at,
        message: o.note || ''
      }))
    }

    // Load outgoing offers
    const outgoingRes = await api.get<{ success: boolean; data?: any[] }>('/offers/outgoing')
    if (outgoingRes.success && outgoingRes.data) {
      outgoingOffers.value = outgoingRes.data.map((o: any) => ({
        id: o.id,
        vehicle: {
          brand: o.brand,
          model: o.model,
          price: o.base_price
        },
        to: o.seller_gallery_name || 'Galeri',
        price: o.amount,
        status: o.status,
        date: o.created_at
      }))
    }
  } catch (error: any) {
    console.error('Teklifler yüklenemedi:', error)
    toast.error('Teklifler yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR')
}

const acceptOffer = async (id: number) => {
  const offer = incomingOffers.value.find(o => o.id === id)
  if (offer) {
    try {
      await api.post(`/offers/${id}/accept`)
      offer.status = 'accepted'
      toast.success('Teklif kabul edildi!')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const rejectOffer = async (id: number) => {
  const offer = incomingOffers.value.find(o => o.id === id)
  if (offer) {
    try {
      await api.post(`/offers/${id}/reject`)
      offer.status = 'rejected'
      toast.success('Teklif reddedildi!')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const counterOffer = async (id: number) => {
  const offer = incomingOffers.value.find(o => o.id === id)
  if (offer) {
    const newPrice = prompt(`Mevcut teklif: ${offer.price.toLocaleString('tr-TR')} ₺\nKarşı teklif fiyatı:`, offer.price.toString())
    if (newPrice && !isNaN(Number(newPrice))) {
      try {
        await api.post(`/offers/${id}/counter`, { amount: Number(newPrice) })
        toast.success('Karşı teklif gönderildi!')
        await loadOffers()
      } catch (error: any) {
        toast.error('Hata: ' + error.message)
      }
    }
  }
}

onMounted(() => {
  loadOffers()
})
</script>

