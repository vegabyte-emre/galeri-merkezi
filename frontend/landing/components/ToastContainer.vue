<template>
  <Teleport to="body">
    <div class="fixed top-4 right-4 z-50 space-y-2">
      <TransitionGroup name="toast">
        <div
          v-for="toast in toasts"
          :key="toast.id"
          class="flex items-center gap-3 px-4 py-3 rounded-lg shadow-lg min-w-[300px] max-w-md"
          :class="{
            'bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-800 text-green-800 dark:text-green-200': toast.type === 'success',
            'bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200': toast.type === 'error',
            'bg-yellow-50 dark:bg-yellow-900/30 border border-yellow-200 dark:border-yellow-800 text-yellow-800 dark:text-yellow-200': toast.type === 'warning',
            'bg-blue-50 dark:bg-blue-900/30 border border-blue-200 dark:border-blue-800 text-blue-800 dark:text-blue-200': toast.type === 'info'
          }"
        >
          <component
            :is="iconMap[toast.type]"
            class="w-5 h-5 flex-shrink-0"
          />
          <p class="flex-1 text-sm font-medium">{{ toast.message }}</p>
          <button
            @click="remove(toast.id)"
            class="flex-shrink-0 text-current opacity-50 hover:opacity-100 transition-opacity"
          >
            <X class="w-4 h-4" />
          </button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { X, CheckCircle, AlertCircle, AlertTriangle, Info } from 'lucide-vue-next'
import { useToast } from '~/composables/useToast'

const { toasts, remove } = useToast()

const iconMap = {
  success: CheckCircle,
  error: AlertCircle,
  warning: AlertTriangle,
  info: Info
}
</script>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.toast-leave-to {
  opacity: 0;
  transform: translateX(100%);
}
</style>













