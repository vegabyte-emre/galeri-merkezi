import { ref, readonly } from 'vue'

export type ToastType = 'success' | 'error' | 'warning' | 'info'

export interface Toast {
  id: string
  type: ToastType
  message: string
  duration?: number
}

export const useToast = () => {
  const toasts = ref<Toast[]>([])

  const show = (type: ToastType, message: string, duration = 3000) => {
    const id = Math.random().toString(36).substring(7)
    const toast: Toast = { id, type, message, duration }
    
    toasts.value.push(toast)

    if (duration > 0) {
      setTimeout(() => {
        remove(id)
      }, duration)
    }

    return id
  }

  const remove = (id: string) => {
    const index = toasts.value.findIndex(t => t.id === id)
    if (index > -1) {
      toasts.value.splice(index, 1)
    }
  }

  const success = (message: string, duration?: number) => show('success', message, duration)
  const error = (message: string, duration?: number) => show('error', message, duration)
  const warning = (message: string, duration?: number) => show('warning', message, duration)
  const info = (message: string, duration?: number) => show('info', message, duration)

  return {
    toasts: readonly(toasts),
    show,
    remove,
    success,
    error,
    warning,
    info
  }
}

