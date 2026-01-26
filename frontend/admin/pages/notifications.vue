<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Bildirimler</h1>
        <p class="text-gray-500 dark:text-gray-400">Sistem bildirimleri ve uyarılar</p>
      </div>
      <button
        v-if="notifications.length > 0 && unreadCount > 0"
        @click="markAllAsRead"
        class="px-4 py-2 text-sm font-medium text-primary-600 hover:text-primary-700 dark:text-primary-400"
      >
        Tümünü okundu işaretle
      </button>
    </div>

    <!-- Notifications List -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden">
      <div v-if="loading" class="p-8 text-center">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500 mx-auto"></div>
        <p class="mt-2 text-gray-500 dark:text-gray-400">Yükleniyor...</p>
      </div>

      <div v-else-if="notifications.length === 0" class="p-8 text-center">
        <Bell class="w-12 h-12 text-gray-300 dark:text-gray-600 mx-auto" />
        <p class="mt-2 text-gray-500 dark:text-gray-400">Henüz bildirim yok</p>
      </div>

      <div v-else class="divide-y divide-gray-200 dark:divide-gray-700">
        <div
          v-for="notification in notifications"
          :key="notification.id"
          :class="[
            'p-4 hover:bg-gray-50 dark:hover:bg-gray-700/50 cursor-pointer transition-colors',
            !notification.read_at && 'bg-blue-50/50 dark:bg-blue-900/10'
          ]"
          @click="handleNotificationClick(notification)"
        >
          <div class="flex items-start gap-4">
            <!-- Icon -->
            <div :class="[
              'p-2 rounded-lg',
              getNotificationIconClass(notification.type)
            ]">
              <component :is="getNotificationIcon(notification.type)" class="w-5 h-5" />
            </div>
            
            <!-- Content -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2">
                <p class="font-medium text-gray-900 dark:text-white">{{ notification.title }}</p>
                <span 
                  v-if="!notification.read_at" 
                  class="px-2 py-0.5 text-xs font-medium bg-blue-100 text-blue-600 dark:bg-blue-900/30 dark:text-blue-400 rounded-full"
                >
                  Yeni
                </span>
              </div>
              <p class="text-sm text-gray-600 dark:text-gray-300 mt-1">{{ notification.body }}</p>
              <p class="text-xs text-gray-400 dark:text-gray-500 mt-2">{{ formatDate(notification.created_at) }}</p>
            </div>
            
            <!-- Unread indicator -->
            <div v-if="!notification.read_at" class="w-2 h-2 bg-blue-500 rounded-full"></div>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="pagination.totalPages > 1" class="p-4 border-t border-gray-200 dark:border-gray-700 flex justify-center gap-2">
        <button
          v-for="page in pagination.totalPages"
          :key="page"
          @click="loadNotifications(page)"
          :class="[
            'px-3 py-1 rounded-lg text-sm font-medium transition-colors',
            page === pagination.page
              ? 'bg-primary-500 text-white'
              : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
          ]"
        >
          {{ page }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Bell, Car, CheckCircle, XCircle, AlertTriangle, Info, Building2 } from 'lucide-vue-next'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()

interface Notification {
  id: string
  type: string
  title: string
  body: string
  data?: any
  read_at?: string
  created_at: string
}

const notifications = ref<Notification[]>([])
const loading = ref(true)
const pagination = ref({
  page: 1,
  limit: 20,
  total: 0,
  totalPages: 0
})

const unreadCount = computed(() => notifications.value.filter(n => !n.read_at).length)

const loadNotifications = async (page = 1) => {
  loading.value = true
  try {
    const response = await api.get<any>(`/notifications?page=${page}&limit=${pagination.value.limit}`)
    if (response.success) {
      notifications.value = response.data || []
      if (response.pagination) {
        pagination.value = response.pagination
      }
    }
  } catch (error) {
    console.error('Bildirimler yüklenemedi:', error)
    toast.error('Bildirimler yüklenemedi')
  } finally {
    loading.value = false
  }
}

const handleNotificationClick = async (notification: Notification) => {
  // Mark as read
  if (!notification.read_at) {
    try {
      await api.post(`/notifications/${notification.id}/read`)
      notification.read_at = new Date().toISOString()
    } catch (error) {
      console.error('Bildirim okundu işaretlenemedi:', error)
    }
  }

  // Navigate based on type
  if (notification.type === 'vehicle_submitted_for_approval' && notification.data?.vehicleId) {
    navigateTo('/vehicle-approvals')
  } else if (notification.type === 'gallery_registered' && notification.data?.galleryId) {
    navigateTo(`/galleries/${notification.data.galleryId}`)
  }
}

const markAllAsRead = async () => {
  try {
    await api.post('/notifications/read-all')
    notifications.value.forEach(n => {
      if (!n.read_at) n.read_at = new Date().toISOString()
    })
    toast.success('Tüm bildirimler okundu işaretlendi')
  } catch (error) {
    console.error('Bildirimler işaretlenemedi:', error)
    toast.error('Bildirimler işaretlenemedi')
  }
}

const getNotificationIcon = (type: string) => {
  switch (type) {
    case 'vehicle_submitted_for_approval':
      return Car
    case 'vehicle_approved':
      return CheckCircle
    case 'vehicle_rejected':
      return XCircle
    case 'gallery_registered':
      return Building2
    case 'warning':
      return AlertTriangle
    default:
      return Info
  }
}

const getNotificationIconClass = (type: string) => {
  switch (type) {
    case 'vehicle_submitted_for_approval':
      return 'bg-orange-100 text-orange-600 dark:bg-orange-900/30 dark:text-orange-400'
    case 'vehicle_approved':
      return 'bg-green-100 text-green-600 dark:bg-green-900/30 dark:text-green-400'
    case 'vehicle_rejected':
      return 'bg-red-100 text-red-600 dark:bg-red-900/30 dark:text-red-400'
    case 'gallery_registered':
      return 'bg-blue-100 text-blue-600 dark:bg-blue-900/30 dark:text-blue-400'
    case 'warning':
      return 'bg-yellow-100 text-yellow-600 dark:bg-yellow-900/30 dark:text-yellow-400'
    default:
      return 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400'
  }
}

const formatDate = (dateStr: string) => {
  const date = new Date(dateStr)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 1) return 'Az önce'
  if (minutes < 60) return `${minutes} dakika önce`
  if (hours < 24) return `${hours} saat önce`
  if (days < 7) return `${days} gün önce`
  return date.toLocaleDateString('tr-TR', { day: 'numeric', month: 'long', year: 'numeric' })
}

onMounted(() => {
  loadNotifications()
})
</script>
