<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">E-posta Şablonları</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Sistem e-postalarının şablonlarını yönetin</p>
      </div>
      <button
        @click="showCreateModal = true"
        class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
      >
        <Plus class="w-4 h-4 inline mr-2" />
        Yeni Şablon
      </button>
    </div>

    <!-- Templates Grid -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="template in templates"
        :key="template.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 hover:shadow-xl transition-all cursor-pointer"
        @click="editTemplate(template.id)"
      >
        <div class="flex items-start justify-between mb-4">
          <div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-1">{{ template.name }}</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ template.category }}</p>
          </div>
          <span
            class="px-2 py-1 text-xs font-semibold rounded-full"
            :class="template.status === 'active' 
              ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' 
              : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400'"
          >
            {{ template.status === 'active' ? 'Aktif' : 'Pasif' }}
          </span>
        </div>
        
        <div class="mb-4">
          <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Konu</div>
          <div class="text-sm font-semibold text-gray-900 dark:text-white">{{ template.subject }}</div>
        </div>

        <div class="mb-4">
          <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Önizleme</div>
          <div class="text-sm text-gray-700 dark:text-gray-300 line-clamp-2">{{ template.preview }}</div>
        </div>

        <div class="flex items-center gap-2 pt-4 border-t border-gray-200 dark:border-gray-700">
          <button
            @click.stop="editTemplate(template.id)"
            class="flex-1 px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold text-sm"
          >
            Düzenle
          </button>
          <button
            @click.stop="previewTemplate(template.id)"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold text-sm"
          >
            Önizle
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Plus } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const showCreateModal = ref(false)
const loading = ref(false)

const templates = ref<any[]>([])

const loadTemplates = async () => {
  loading.value = true
  try {
    const data = await api.get<any>('/admin/email-templates')
    templates.value = data.templates || data || []
  } catch (error: any) {
    console.error('Şablonlar yüklenemedi:', error)
    toast.error('Şablonlar yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const editTemplate = (id: number) => {
  navigateTo(`/email-templates/${id}`)
}

const previewTemplate = async (id: number) => {
  try {
    const preview = await api.get<any>(`/admin/email-templates/${id}/preview`)
    // Show preview in modal or new window
    const previewWindow = window.open('', '_blank')
    if (previewWindow) {
      previewWindow.document.write(preview.html || preview)
      previewWindow.document.close()
    }
    toast.success('Önizleme açıldı!')
  } catch (error: any) {
    toast.error('Önizleme yüklenemedi: ' + error.message)
  }
}

onMounted(() => {
  loadTemplates()
})
</script>

