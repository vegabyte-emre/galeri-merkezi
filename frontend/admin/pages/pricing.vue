<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Fiyat Planları</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Landing sayfasında gösterilecek fiyat planlarını yönetin</p>
      </div>
      <button
        @click="showCreateModal = true"
        class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
      >
        <Plus class="w-4 h-4 inline mr-2" />
        Yeni Plan
      </button>
    </div>

    <!-- Plans List -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="plan in plans"
        :key="plan.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border-2 p-6 relative"
        :class="plan.isFeatured 
          ? 'border-primary-500' 
          : 'border-gray-200 dark:border-gray-700'"
      >
        <div v-if="plan.isFeatured" class="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
          <span class="px-4 py-1 bg-gradient-to-r from-primary-500 to-primary-600 text-white text-sm font-semibold rounded-full">
            Popüler
          </span>
        </div>

        <div class="text-center mb-6">
          <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">{{ plan.name }}</h3>
          <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">{{ plan.description }}</p>
          <div class="mb-2">
            <span class="text-4xl font-bold text-gray-900 dark:text-white">
              {{ plan.priceCustom ? plan.priceDisplay : (plan.priceMonthly ? plan.priceMonthly.toLocaleString('tr-TR') : '0') }}
            </span>
            <span v-if="!plan.priceCustom" class="text-gray-600 dark:text-gray-400">₺/ay</span>
          </div>
          <p class="text-xs text-gray-500 dark:text-gray-400">{{ plan.billingNote || 'Aylık ödeme' }}</p>
        </div>

        <div class="mb-4">
          <div class="text-xs text-gray-500 dark:text-gray-400 mb-2">Özellikler:</div>
          <ul class="space-y-1">
            <li
              v-for="(feature, idx) in (plan.features || []).slice(0, 3)"
              :key="idx"
              class="text-sm text-gray-700 dark:text-gray-300 flex items-start gap-2"
            >
              <Check class="w-4 h-4 text-green-500 flex-shrink-0 mt-0.5" />
              <span>{{ feature }}</span>
            </li>
            <li v-if="(plan.features || []).length > 3" class="text-xs text-gray-500 dark:text-gray-400">
              +{{ (plan.features || []).length - 3 }} özellik daha
            </li>
          </ul>
        </div>

        <div class="flex items-center gap-2">
          <button
            @click="editPlan(plan)"
            class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-sm font-semibold"
          >
            Düzenle
          </button>
          <button
            @click="deletePlan(plan.id)"
            class="px-3 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors"
          >
            <Trash2 class="w-4 h-4" />
          </button>
        </div>

        <div class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700 flex items-center justify-between">
          <label class="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              :checked="plan.isActive"
              @change="toggleActive(plan)"
              class="w-4 h-4 text-primary-600 rounded focus:ring-primary-500"
            />
            <span class="text-sm text-gray-700 dark:text-gray-300">Aktif</span>
          </label>
          <span class="text-xs text-gray-500 dark:text-gray-400">Sıra: {{ plan.sortOrder }}</span>
        </div>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <div
      v-if="showCreateModal || editingPlan"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="closeModal"
    >
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div class="p-6">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-bold text-gray-900 dark:text-white">
              {{ editingPlan ? 'Plan Düzenle' : 'Yeni Plan' }}
            </h2>
            <button
              @click="closeModal"
              class="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
            >
              <X class="w-5 h-5 text-gray-500" />
            </button>
          </div>

          <form @submit.prevent="savePlan" class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Plan Adı *
                </label>
                <input
                  v-model="form.name"
                  type="text"
                  required
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Slug *
                </label>
                <input
                  v-model="form.slug"
                  type="text"
                  required
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Açıklama
              </label>
              <input
                v-model="form.description"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>

            <div class="grid grid-cols-3 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Aylık Fiyat (₺)
                </label>
                <input
                  v-model.number="form.priceMonthly"
                  type="number"
                  step="0.01"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Yıllık Fiyat (₺)
                </label>
                <input
                  v-model.number="form.priceYearly"
                  type="number"
                  step="0.01"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Sıra
                </label>
                <input
                  v-model.number="form.sortOrder"
                  type="number"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="flex items-center gap-2 cursor-pointer">
                  <input
                    v-model="form.priceCustom"
                    type="checkbox"
                    class="w-4 h-4 text-primary-600 rounded focus:ring-primary-500"
                  />
                  <span class="text-sm text-gray-700 dark:text-gray-300">Özel Fiyat</span>
                </label>
              </div>
              <div v-if="form.priceCustom">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Özel Fiyat Gösterimi
                </label>
                <input
                  v-model="form.priceDisplay"
                  type="text"
                  placeholder="Özel"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Ödeme Notu
              </label>
              <input
                v-model="form.billingNote"
                type="text"
                placeholder="Aylık ödeme"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Özellikler (Her satıra bir özellik)
              </label>
              <textarea
                v-model="featuresText"
                rows="6"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="50 araç yükleme&#10;Temel stok yönetimi&#10;E-posta desteği"
              ></textarea>
            </div>

            <div class="flex items-center gap-4">
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.isFeatured"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded focus:ring-primary-500"
                />
                <span class="text-sm text-gray-700 dark:text-gray-300">Popüler Plan</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.isActive"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded focus:ring-primary-500"
                />
                <span class="text-sm text-gray-700 dark:text-gray-300">Aktif</span>
              </label>
            </div>

            <div class="flex items-center gap-3 pt-4">
              <button
                type="submit"
                class="flex-1 px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
              >
                {{ editingPlan ? 'Güncelle' : 'Oluştur' }}
              </button>
              <button
                type="button"
                @click="closeModal"
                class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
              >
                İptal
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Plus, X, Check, Trash2 } from 'lucide-vue-next'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()

const plans = ref<any[]>([])
const loading = ref(false)
const showCreateModal = ref(false)
const editingPlan = ref<any>(null)

const form = ref({
  name: '',
  slug: '',
  description: '',
  priceMonthly: null as number | null,
  priceYearly: null as number | null,
  priceCustom: false,
  priceDisplay: '',
  billingNote: '',
  isFeatured: false,
  isActive: true,
  sortOrder: 0,
  features: [] as string[]
})

const featuresText = computed({
  get: () => form.value.features.join('\n'),
  set: (value: string) => {
    form.value.features = value.split('\n').filter(f => f.trim())
  }
})

const loadPlans = async () => {
  loading.value = true
  try {
    const response = await api.get('/admin/pricing-plans')
    if (response.success) {
      plans.value = response.plans || []
    }
  } catch (error: any) {
    console.error('Fiyat planları yüklenemedi:', error)
    toast.error('Fiyat planları yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const editPlan = (plan: any) => {
  editingPlan.value = plan
  form.value = {
    name: plan.name,
    slug: plan.slug,
    description: plan.description || '',
    priceMonthly: plan.priceMonthly,
    priceYearly: plan.priceYearly,
    priceCustom: plan.priceCustom || false,
    priceDisplay: plan.priceDisplay || '',
    billingNote: plan.billingNote || '',
    isFeatured: plan.isFeatured || false,
    isActive: plan.isActive !== false,
    sortOrder: plan.sortOrder || 0,
    features: plan.features || []
  }
  showCreateModal.value = true
}

const savePlan = async () => {
  try {
    if (editingPlan.value) {
      await api.put(`/admin/pricing-plans/${editingPlan.value.id}`, form.value)
      toast.success('Plan güncellendi!')
    } else {
      await api.post('/admin/pricing-plans', form.value)
      toast.success('Plan oluşturuldu!')
    }
    closeModal()
    await loadPlans()
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const deletePlan = async (id: string) => {
  if (!confirm('Bu planı silmek istediğinize emin misiniz?')) return

  try {
    await api.delete(`/admin/pricing-plans/${id}`)
    toast.success('Plan silindi!')
    await loadPlans()
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const toggleActive = async (plan: any) => {
  try {
    await api.put(`/admin/pricing-plans/${plan.id}`, {
      isActive: !plan.isActive
    })
    plan.isActive = !plan.isActive
    toast.success(`Plan ${plan.isActive ? 'aktif' : 'pasif'} edildi!`)
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingPlan.value = null
  form.value = {
    name: '',
    slug: '',
    description: '',
    priceMonthly: null,
    priceYearly: null,
    priceCustom: false,
    priceDisplay: '',
    billingNote: '',
    isFeatured: false,
    isActive: true,
    sortOrder: 0,
    features: []
  }
}

onMounted(() => {
  loadPlans()
})
</script>
