<template>
  <div class="space-y-4">
    <!-- Upload Area -->
    <div
      @click="triggerFileInput"
      @dragover.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
      @drop.prevent="handleDrop"
      class="border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors"
      :class="isDragging 
        ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20' 
        : 'border-gray-300 dark:border-gray-600 hover:border-primary-400'"
    >
      <input
        ref="fileInput"
        type="file"
        :accept="accept"
        :multiple="multiple"
        @change="handleFileSelect"
        class="hidden"
      />
      
      <Upload class="w-12 h-12 text-gray-400 mx-auto mb-4" />
      <p class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
        {{ multiple ? 'Dosyaları sürükleyip bırakın' : 'Dosyayı sürükleyip bırakın' }}
      </p>
      <p class="text-xs text-gray-500 dark:text-gray-400">
        veya <span class="text-primary-600 dark:text-primary-400 font-semibold">tıklayarak seçin</span>
      </p>
      <p v-if="maxSize" class="text-xs text-gray-400 dark:text-gray-500 mt-2">
        Maksimum dosya boyutu: {{ formatSize(maxSize) }}
      </p>
    </div>

    <!-- Preview Grid -->
    <div v-if="previews.length > 0" class="grid grid-cols-2 md:grid-cols-4 gap-4">
      <div
        v-for="(preview, index) in previews"
        :key="index"
        class="relative group aspect-square rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-700"
      >
        <img
          :src="preview.url"
          :alt="preview.name"
          class="w-full h-full object-cover"
        />
        <div class="absolute inset-0 bg-black/0 group-hover:bg-black/50 transition-colors flex items-center justify-center">
          <button
            @click.stop="removeFile(index)"
            class="opacity-0 group-hover:opacity-100 transition-opacity p-2 bg-red-500 rounded-lg hover:bg-red-600"
          >
            <Trash2 class="w-4 h-4 text-white" />
          </button>
        </div>
        <div v-if="preview.uploading" class="absolute inset-0 bg-black/50 flex items-center justify-center">
          <LoadingSpinner size="sm" />
        </div>
        <div v-if="preview.progress" class="absolute bottom-0 left-0 right-0 bg-black/70 p-2">
          <div class="w-full bg-gray-600 rounded-full h-1">
            <div
              class="bg-primary-500 h-1 rounded-full transition-all"
              :style="{ width: `${preview.progress}%` }"
            ></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="error" class="p-3 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 rounded-lg">
      <p class="text-sm text-red-800 dark:text-red-200">{{ error }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Upload, Trash2 } from 'lucide-vue-next'
import { ref, computed } from 'vue'

interface Props {
  modelValue?: File[]
  accept?: string
  multiple?: boolean
  maxSize?: number // in bytes
  maxFiles?: number
}

const props = withDefaults(defineProps<Props>(), {
  accept: 'image/*',
  multiple: false,
  maxSize: 5 * 1024 * 1024, // 5MB
  maxFiles: 10
})

const emit = defineEmits<{
  'update:modelValue': [files: File[]]
}>()

const fileInput = ref<HTMLInputElement | null>(null)
const isDragging = ref(false)
const error = ref('')
const previews = ref<Array<{
  file: File
  url: string
  name: string
  uploading?: boolean
  progress?: number
}>>([])

const triggerFileInput = () => {
  fileInput.value?.click()
}

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files) {
    handleFiles(Array.from(target.files))
  }
}

const handleDrop = (event: DragEvent) => {
  isDragging.value = false
  if (event.dataTransfer?.files) {
    handleFiles(Array.from(event.dataTransfer.files))
  }
}

const handleFiles = (files: File[]) => {
  error.value = ''
  
  // Check max files
  if (previews.value.length + files.length > props.maxFiles!) {
    error.value = `Maksimum ${props.maxFiles} dosya yükleyebilirsiniz`
    return
  }

  files.forEach(file => {
    // Check file size
    if (file.size > props.maxSize!) {
      error.value = `${file.name} dosyası çok büyük (Maks: ${formatSize(props.maxSize!)})`
      return
    }

    // Check file type
    if (props.accept && !file.type.match(props.accept.replace('*', '.*'))) {
      error.value = `${file.name} desteklenmeyen dosya tipi`
      return
    }

    const url = URL.createObjectURL(file)
    previews.value.push({
      file,
      url,
      name: file.name,
      uploading: false,
      progress: 0
    })
  })

  emit('update:modelValue', previews.value.map(p => p.file))
}

const removeFile = (index: number) => {
  URL.revokeObjectURL(previews.value[index].url)
  previews.value.splice(index, 1)
  emit('update:modelValue', previews.value.map(p => p.file))
}

const formatSize = (bytes: number) => {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}

const uploadFile = async (index: number) => {
  const preview = previews.value[index]
  preview.uploading = true
  preview.progress = 0

  try {
    const formData = new FormData()
    formData.append('file', preview.file)

    const api = useApi()
    const response = await api.post('/media/upload', formData, {
      onUploadProgress: (progressEvent: any) => {
        if (progressEvent.lengthComputable) {
          preview.progress = Math.round((progressEvent.loaded * 100) / progressEvent.total)
        }
      }
    })

    preview.uploading = false
    preview.progress = 100
    return response
  } catch (error: any) {
    preview.uploading = false
    throw error
  }
}

const uploadAll = async () => {
  const uploads = previews.value.map((_, index) => uploadFile(index))
  return Promise.all(uploads)
}

defineExpose({
  uploadAll,
  uploadFile
})
</script>














