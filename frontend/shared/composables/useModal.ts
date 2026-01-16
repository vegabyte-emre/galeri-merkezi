export const useModal = () => {
  const isOpen = ref(false)
  const modalData = ref<any>(null)

  const open = (data?: any) => {
    modalData.value = data || null
    isOpen.value = true
    // Prevent body scroll
    if (process.client) {
      document.body.style.overflow = 'hidden'
    }
  }

  const close = () => {
    isOpen.value = false
    modalData.value = null
    // Restore body scroll
    if (process.client) {
      document.body.style.overflow = ''
    }
  }

  const toggle = () => {
    if (isOpen.value) {
      close()
    } else {
      open()
    }
  }

  return {
    isOpen: readonly(isOpen),
    modalData: readonly(modalData),
    open,
    close,
    toggle
  }
}














