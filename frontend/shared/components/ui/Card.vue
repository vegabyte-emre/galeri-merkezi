<template>
  <div :class="cardClasses">
    <div v-if="$slots.header" class="px-6 py-4 border-b border-gray-200">
      <slot name="header" />
    </div>
    <div :class="bodyClasses">
      <slot />
    </div>
    <div v-if="$slots.footer" class="px-6 py-4 border-t border-gray-200">
      <slot name="footer" />
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  padding?: boolean
  shadow?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  padding: true,
  shadow: true
})

const cardClasses = computed(() => {
  const base = 'bg-white rounded-lg border border-gray-200'
  const shadowClass = props.shadow ? 'shadow-md' : ''
  return `${base} ${shadowClass}`
})

const bodyClasses = computed(() => {
  return props.padding ? 'px-6 py-4' : ''
})
</script>
















