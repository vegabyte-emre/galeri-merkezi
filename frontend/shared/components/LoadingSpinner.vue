<template>
  <div class="flex items-center justify-center" :class="containerClass">
    <div
      class="animate-spin rounded-full border-4 border-gray-200 border-t-primary-600"
      :class="spinnerClass"
    ></div>
    <span v-if="text" class="ml-3 text-gray-600 dark:text-gray-400">{{ text }}</span>
  </div>
</template>

<script setup lang="ts">
interface Props {
  size?: 'sm' | 'md' | 'lg'
  text?: string
  fullScreen?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  fullScreen: false
})

const spinnerClass = computed(() => {
  const sizes = {
    sm: 'w-4 h-4',
    md: 'w-8 h-8',
    lg: 'w-12 h-12'
  }
  return sizes[props.size]
})

const containerClass = computed(() => {
  if (props.fullScreen) {
    return 'fixed inset-0 bg-white/80 dark:bg-gray-900/80 z-50'
  }
  return 'py-8'
})
</script>














