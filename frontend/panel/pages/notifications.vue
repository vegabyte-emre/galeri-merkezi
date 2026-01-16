<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Bildirimler</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Tüm bildirimlerinizi buradan yönetin</p>
      </div>
      <div class="flex items-center gap-3">
        <button
          @click="markAllAsRead"
          class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-semibold"
        >
          Tümünü Okundu İşaretle
        </button>
        <button
          @click="deleteAll"
          class="px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold"
        >
          Tümünü Sil
        </button>
      </div>
    </div>

    <!-- Filter Tabs -->
    <div class="flex items-center gap-2 border-b border-gray-200 dark:border-gray-700">
      <button
        v-for="filter in filters"
        :key="filter.value"
        @click="activeFilter = filter.value"
        class="px-4 py-2 font-semibold text-sm border-b-2 transition-colors"
        :class="activeFilter === filter.value
          ? 'border-primary-500 text-primary-600 dark:text-primary-400'
          : 'border-transparent text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white'"
      >
        {{ filter.label }}
        <span
          v-if="filter.count"
          class="ml-2 px-2 py-0.5 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-full text-xs"
        >
          {{ filter.count }}
        </span>
      </button>
    </div>

    <!-- Notifications List -->
    <div class="space-y-3">
      <div
        v-for="notification in filteredNotifications"
        :key="notification.id"
        @click="handleNotificationClick(notification)"
        class="bg-white dark:bg-gray-800 rounded-xl shadow-lg border border-gray-200 dark:border-gray-700 p-4 hover:shadow-xl transition-all cursor-pointer"
        :class="{ 'bg-primary-50 dark:bg-primary-900/20 border-primary-300 dark:border-primary-700': !notification.is_read }"
      >
        <div class="flex items-start gap-4">
          <!-- Icon -->
          <div
            class="w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0"
            :class="getNotificationIconBg(notification.type)"
          >
            <component :is="getNotificationIcon(notification.type)" class="w-6 h-6" :class="getNotificationIconColor(notification.type)" />
          </div>

          <!-- Content -->
          <div class="flex-1 min-w-0">
            <div class="flex items-start justify-between mb-1">
              <h3 class="font-semibold text-gray-900 dark:text-white">{{ notification.title }}</h3>
              <span
                v-if="!notification.is_read"
                class="w-2 h-2 bg-primary-500 rounded-full flex-shrink-0 mt-2"
              ></span>
            </div>
            <p class="text-sm text-gray-600 dark:text-gray-400 mb-2">{{ notification.message }}</p>
            <div class="flex items-center gap-3 text-xs text-gray-500 dark:text-gray-400">
              <span>{{ formatDateTime(notification.created_at) }}</span>
              <span v-if="notification.type">•</span>
              <span v-if="notification.type">{{ notification.type }}</span>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex items-center gap-2 flex-shrink-0">
            <button
              @click.stop="toggleRead(notification.id)"
              class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-600 dark:text-gray-400 transition-colors"
            >
              <CheckCircle v-if="notification.is_read" class="w-4 h-4" />
              <Circle v-else class="w-4 h-4" />
            </button>
            <button
              @click.stop="deleteNotification(notification.id)"
              class="p-2 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/30 text-red-600 dark:text-red-400 transition-colors"
            >
              <Trash2 class="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div
        v-if="filteredNotifications.length === 0"
        class="text-center py-12 bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700"
      >
        <Bell class="w-16 h-16 text-gray-400 mx-auto mb-4" />
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2">Bildirim Yok</h3>
        <p class="text-gray-600 dark:text-gray-400">Henüz bildiriminiz bulunmuyor</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  Bell,
  CheckCircle,
  Circle,
  Trash2,
  Users,
  MessageSquare,
  Car,
  AlertCircle,
  DollarSign
} from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const router = useRouter()
const api = useApi()
const toast = useToast()

const activeFilter = ref('all')
const loading = ref(false)
const unreadCount = ref(0)

const filters = computed(() => [
  { label: 'Tümü', value: 'all', count: null },
  { label: 'Okunmamış', value: 'unread', count: unreadCount.value },
  { label: 'Teklifler', value: 'offer', count: null },
  { label: 'Mesajlar', value: 'message', count: null },
  { label: 'Sistem', value: 'system', count: null }
])

const notifications = ref<any[]>([])

const getNotificationIcon = (type: string) => {
  switch (type) {
    case 'offer':
      return Users
    case 'message':
      return MessageSquare
    case 'system':
      return Car
    default:
      return Bell
  }
}

const getNotificationIconBg = (type: string) => {
  switch (type) {
    case 'offer':
      return 'bg-green-100 dark:bg-green-900/30'
    case 'message':
      return 'bg-blue-100 dark:bg-blue-900/30'
    case 'system':
      return 'bg-purple-100 dark:bg-purple-900/30'
    default:
      return 'bg-gray-100 dark:bg-gray-900/30'
  }
}

const getNotificationIconColor = (type: string) => {
  switch (type) {
    case 'offer':
      return 'text-green-600 dark:text-green-400'
    case 'message':
      return 'text-blue-600 dark:text-blue-400'
    case 'system':
      return 'text-purple-600 dark:text-purple-400'
    default:
      return 'text-gray-600 dark:text-gray-400'
  }
}

const filteredNotifications = computed(() => {
  if (activeFilter.value === 'all') return notifications.value
  if (activeFilter.value === 'unread') return notifications.value.filter(n => !n.is_read)
  return notifications.value.filter(n => n.type === activeFilter.value)
})

const loadNotifications = async () => {
  try {
    loading.value = true
    const unreadOnly = activeFilter.value === 'unread' ? 'true' : 'false'
    const response = await api.get<{ success: boolean; data: any[]; unreadCount: number }>(`/notifications?unread_only=${unreadOnly}`)
    if (response.success && response.data) {
      notifications.value = response.data
      unreadCount.value = response.unreadCount || 0
    }
  } catch (error: any) {
    toast.error('Bildirimler yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const formatDateTime = (timestamp: string) => {
  const date = new Date(timestamp)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 1) return 'Az önce'
  if (minutes < 60) return `${minutes} dakika önce`
  if (hours < 24) return `${hours} saat önce`
  if (days < 7) return `${days} gün önce`
  return date.toLocaleDateString('tr-TR')
}

const handleNotificationClick = (notification: any) => {
  if (notification.related_entity_type === 'offer' && notification.related_entity_id) {
    router.push('/offers')
  } else if (notification.related_entity_type === 'message' && notification.related_entity_id) {
    router.push('/chats')
  } else if (notification.related_entity_type === 'vehicle' && notification.related_entity_id) {
    router.push('/vehicles')
  }
  if (!notification.is_read) {
    toggleRead(notification.id)
  }
}

const toggleRead = async (id: string) => {
  const notification = notifications.value.find(n => n.id === id)
  if (notification) {
    try {
      await api.put(`/notifications/${id}/read`)
      notification.is_read = !notification.is_read
      if (notification.is_read) {
        unreadCount.value = Math.max(0, unreadCount.value - 1)
      } else {
        unreadCount.value++
      }
    } catch (error: any) {
      toast.error('Bildirim güncellenemedi: ' + error.message)
    }
  }
}

const deleteNotification = async (id: string) => {
  if (confirm('Bu bildirimi silmek istediğinize emin misiniz?')) {
    try {
      await api.delete(`/notifications/${id}`)
      const wasUnread = notifications.value.find(n => n.id === id)?.is_read === false
      notifications.value = notifications.value.filter(n => n.id !== id)
      if (wasUnread) {
        unreadCount.value = Math.max(0, unreadCount.value - 1)
      }
      toast.success('Bildirim silindi')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

const markAllAsRead = async () => {
  try {
    await api.put('/notifications/read-all')
    notifications.value.forEach(n => { n.is_read = true })
    unreadCount.value = 0
    toast.success('Tüm bildirimler okundu olarak işaretlendi')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const deleteAll = async () => {
  if (confirm('Tüm bildirimleri silmek istediğinize emin misiniz?')) {
    try {
      // Delete all notifications one by one (backend doesn't have bulk delete)
      for (const notif of notifications.value) {
        await api.delete(`/notifications/${notif.id}`)
      }
      notifications.value = []
      unreadCount.value = 0
      toast.success('Tüm bildirimler silindi')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

onMounted(() => {
  loadNotifications()
})
</script>

