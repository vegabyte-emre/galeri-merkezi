<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 transition-colors duration-300">
    <!-- Sidebar -->
    <aside 
      :class="[
        'fixed left-0 top-0 h-full w-64 bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-800 z-40 transition-transform duration-300 flex flex-col',
        isSidebarOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
      ]"
    >
      <!-- Logo -->
      <div class="flex-shrink-0 flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-800">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center shadow-lg">
            <Car class="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 class="text-lg font-semibold text-gray-900 dark:text-white" style="font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif;">Otobia</h1>
            <p class="text-xs text-gray-500 dark:text-gray-400">Galeri Paneli</p>
          </div>
        </div>
        <button
          @click="isSidebarOpen = false"
          class="md:hidden p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400"
        >
          <X class="w-5 h-5" />
        </button>
      </div>

      <!-- Navigation - Scrollable -->
      <nav class="flex-1 overflow-y-auto p-4 space-y-2">
        <NuxtLink
          v-for="item in navItems"
          :key="item.path"
          :to="item.path"
          :class="[
            'flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group',
            item.highlight 
              ? (item.color === 'orange' 
                  ? 'bg-gradient-to-r from-amber-500 to-orange-500 text-white shadow-lg hover:shadow-xl hover:scale-[1.02]'
                  : item.color === 'violet'
                    ? 'bg-gradient-to-r from-violet-500 to-fuchsia-500 text-white shadow-lg hover:shadow-xl hover:scale-[1.02]'
                    : 'bg-gradient-to-r from-primary-500 to-primary-600 text-white shadow-lg hover:shadow-xl hover:scale-[1.02]')
              : 'text-gray-700 dark:text-gray-300 hover:bg-primary-50 dark:hover:bg-gray-800 hover:text-primary-600 dark:hover:text-primary-400'
          ]"
          :active-class="item.highlight ? '' : 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400'"
        >
          <component :is="item.icon" class="w-5 h-5 group-hover:scale-110 transition-transform" />
          <span class="font-medium">{{ item.label }}</span>
              <span v-if="item.badge" :class="[
            'ml-auto px-2 py-0.5 text-xs font-semibold rounded-full',
            item.highlight 
              ? (item.color === 'orange' ? 'bg-white/20 text-white' : 'bg-white/20 text-white')
              : 'bg-primary-500 text-white'
          ]">
            {{ item.badge }}
          </span>
        </NuxtLink>
      </nav>

      <!-- User Section - Fixed at bottom -->
      <div class="flex-shrink-0 p-4 border-t border-gray-200 dark:border-gray-800">
        <div class="flex items-center gap-3 p-3 rounded-xl bg-gray-50 dark:bg-gray-800">
          <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold">
            {{ avatarLetter }}
          </div>
          <div class="flex-1 min-w-0">
            <NuxtLink to="/profile" class="block">
              <p class="text-sm font-semibold text-gray-900 dark:text-white truncate">{{ displayName }}</p>
              <p class="text-xs text-gray-500 dark:text-gray-400 truncate">{{ displayEmail }}</p>
            </NuxtLink>
          </div>
          <div class="flex items-center gap-2">
            <button
              @click="toggleDarkMode"
              class="p-2 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 text-gray-600 dark:text-gray-400 transition-colors"
            >
              <Sun v-if="isDark" class="w-4 h-4" />
              <Moon v-else class="w-4 h-4" />
            </button>
            <button
              @click="handleLogout"
              class="p-2 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/30 text-red-600 dark:text-red-400 transition-colors"
              title="Çıkış Yap"
            >
              <LogOut class="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </aside>

    <!-- Main Content -->
    <div class="md:ml-64 min-h-screen flex flex-col">
      <!-- Top Bar -->
      <header class="sticky top-0 z-30 bg-white/80 dark:bg-gray-900/80 backdrop-blur-md border-b border-gray-200 dark:border-gray-800 shadow-sm">
        <div class="flex items-center justify-between px-6 py-4">
          <div class="flex items-center gap-4">
            <button
              @click="isSidebarOpen = !isSidebarOpen"
              class="md:hidden p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400"
            >
              <Menu class="w-5 h-5" />
            </button>
            <div>
              <h2 class="text-xl font-bold text-gray-900 dark:text-white">{{ pageTitle }}</h2>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ pageSubtitle }}</p>
            </div>
          </div>
          <div class="flex items-center gap-4">
            <!-- Notifications -->
            <NuxtLink
              to="/notifications"
              class="relative p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400 transition-colors"
            >
              <Bell class="w-5 h-5" />
              <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
            </NuxtLink>
            <!-- Add Vehicle Button -->
            <NuxtLink
              to="/vehicles/new"
              class="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg shadow-lg hover:shadow-xl hover:scale-105 transition-all duration-300"
            >
              <Plus class="w-4 h-4" />
              <span class="hidden sm:inline">Yeni Araç</span>
            </NuxtLink>
          </div>
        </div>
      </header>

      <!-- Page Content -->
      <main class="flex-1 p-6">
        <slot />
      </main>
    </div>

    <!-- Sidebar Overlay (Mobile) -->
    <div
      v-if="isSidebarOpen"
      @click="isSidebarOpen = false"
      class="fixed inset-0 bg-black/50 z-30 md:hidden"
    ></div>
  </div>
</template>

<script setup lang="ts">
import { 
  Car, 
  LayoutDashboard, 
  CarFront, 
  Users, 
  MessageSquare, 
  Settings,
  BarChart3,
  Link,
  Bell,
  HelpCircle,
  Heart,
  Activity,
  Image,
  Menu,
  X,
  Sun,
  Moon,
  Plus,
  LogOut,
  Video,
  ShieldCheck
} from 'lucide-vue-next'
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useApi } from '~/composables/useApi'
import { useAuthStore } from '~/stores/auth'

const storageKey = 'otobia-panel-theme'
const isDark = ref(false)

const applyTheme = (dark: boolean) => {
  if (typeof document === 'undefined') return
  const html = document.documentElement
  if (dark) {
    html.classList.add('dark')
  } else {
    html.classList.remove('dark')
  }
  if (typeof window !== 'undefined') {
    localStorage.setItem(storageKey, dark.toString())
  }
}

const toggleDarkMode = () => {
  isDark.value = !isDark.value
  applyTheme(isDark.value)
}

onMounted(() => {
  if (typeof window !== 'undefined') {
    const stored = localStorage.getItem(storageKey)
    const shouldBeDark = stored === 'true'
    isDark.value = shouldBeDark
    applyTheme(shouldBeDark)
  }
})

watch(isDark, (dark) => {
  if (typeof document !== 'undefined') {
    applyTheme(dark)
  }
})

const isSidebarOpen = ref(false)
const route = useRoute()
const api = useApi()
const authStore = useAuthStore()
const userRole = ref<string>('')
const pendingApprovalCount = ref<number>(0)

const displayName = computed(() => {
  return (
    authStore.gallery?.name ||
    authStore.user?.name ||
    [authStore.user?.firstName, authStore.user?.lastName].filter(Boolean).join(' ') ||
    authStore.user?.email ||
    'Galeri'
  )
})

const displayEmail = computed(() => {
  return authStore.gallery?.email || authStore.user?.email || ''
})

const avatarLetter = computed(() => {
  const n = displayName.value || 'G'
  return n.trim().charAt(0).toUpperCase() || 'G'
})

const loadGalleryProfile = async () => {
  try {
    const res = await api.get<{ success: boolean; data?: any }>('/gallery/settings')
    if (res.success && res.data?.profile) {
      authStore.setGallery(res.data.profile)
    } else {
      // fallback: try /gallery/my
      const my = await api.get<{ success: boolean; data?: any }>('/gallery/my')
      if (my.success && my.data) authStore.setGallery(my.data)
    }
  } catch (e) {
    // ignore - keep placeholders
  }
}

// Base nav items for all users
const baseNavItems = [
  { path: '/', label: 'Dashboard', icon: LayoutDashboard },
  { path: '/shorts', label: 'Oto Shorts', icon: Video, highlight: true, color: 'violet' },
  { path: '/marketplace', label: 'Oto Pazarı', icon: Car, highlight: true, color: 'orange' },
  { path: '/vehicles', label: 'Araçlarım', icon: CarFront, badge: null as string | null },
  { path: '/offers', label: 'Teklifler', icon: Users, badge: null as string | null },
  { path: '/chats', label: 'Mesajlar', icon: MessageSquare, badge: null as string | null },
  { path: '/favorites', label: 'Favoriler', icon: Heart },
  { path: '/reports', label: 'Raporlar', icon: BarChart3 },
  { path: '/channels', label: 'Kanallar', icon: Link },
  { path: '/activity', label: 'Aktivite', icon: Activity },
  { path: '/media', label: 'Medya', icon: Image },
  { path: '/notifications', label: 'Bildirimler', icon: Bell, badge: null as string | null },
  { path: '/help', label: 'Yardım', icon: HelpCircle },
  { path: '/settings', label: 'Ayarlar', icon: Settings },
]

// Superadmin only items
const adminNavItems = [
  { path: '/admin/approvals', label: 'Araç Onayları', icon: ShieldCheck, badge: null as string | null, highlight: true, color: 'green' },
]

const navItems = computed(() => {
  if (userRole.value === 'superadmin') {
    // Insert admin items after Dashboard
    const items = [...baseNavItems]
    items.splice(1, 0, ...adminNavItems.map(item => ({
      ...item,
      badge: pendingApprovalCount.value > 0 ? pendingApprovalCount.value.toString() : null
    })))
    return items
  }
  return baseNavItems
})

const loadUserRole = async () => {
  try {
    const response = await api.get<{ success: boolean; data: { role: string } }>('/auth/me')
    if (response.success && response.data) {
      userRole.value = response.data.role || ''
    }
  } catch (e) {
    console.error('User role error:', e)
  }
}

const loadSidebarCounts = async () => {
  try {
    // Load vehicle count
    try {
      const vehiclesRes = await api.get<{ success: boolean; pagination?: { total: number } }>('/vehicles?limit=1')
      if (vehiclesRes.success && vehiclesRes.pagination) {
        const vehicleItem = baseNavItems.find(item => item.path === '/vehicles')
        if (vehicleItem) {
          vehicleItem.badge = vehiclesRes.pagination.total > 0 ? vehiclesRes.pagination.total.toString() : null
        }
      }
    } catch (e) {
      console.error('Vehicle count error:', e)
    }

    // Load offers count
    try {
      const offersRes = await api.get<{ success: boolean; data?: any[] }>('/offers')
      if (offersRes.success && offersRes.data) {
        const pendingOffers = offersRes.data.filter((o: any) => o.status === 'pending').length
        const offerItem = baseNavItems.find(item => item.path === '/offers')
        if (offerItem) {
          offerItem.badge = pendingOffers > 0 ? pendingOffers.toString() : null
        }
      }
    } catch (e) {
      console.error('Offer count error:', e)
    }

    // Load unread messages count
    try {
      const chatsRes = await api.get<{ success: boolean; data?: any[] }>('/chats')
      if (chatsRes.success && chatsRes.data) {
        const unreadCount = chatsRes.data.reduce((sum: number, chat: any) => sum + (chat.unread_count || 0), 0)
        const chatItem = baseNavItems.find(item => item.path === '/chats')
        if (chatItem) {
          chatItem.badge = unreadCount > 0 ? unreadCount.toString() : null
        }
      }
    } catch (e) {
      console.error('Chat count error:', e)
    }

    // Load notifications count
    try {
      const notifRes = await api.get<{ success: boolean; data?: any[] }>('/notifications?unread=true')
      if (notifRes.success && notifRes.data) {
        const notifItem = baseNavItems.find(item => item.path === '/notifications')
        if (notifItem) {
          notifItem.badge = notifRes.data.length > 0 ? notifRes.data.length.toString() : null
        }
      }
    } catch (e) {
      console.error('Notification count error:', e)
    }

    // Load pending approval count for superadmin
    if (userRole.value === 'superadmin') {
      try {
        const approvalRes = await api.get<{ success: boolean; pagination?: { total: number } }>('/vehicles/pending-approval')
        if (approvalRes.success && approvalRes.pagination) {
          pendingApprovalCount.value = approvalRes.pagination.total
        }
      } catch (e) {
        console.error('Pending approval count error:', e)
      }
    }
  } catch (error) {
    console.error('Sidebar counts error:', error)
  }
}

onMounted(async () => {
  await loadUserRole()
  await loadGalleryProfile()
  loadSidebarCounts()
  // Refresh counts every 30 seconds
  setInterval(loadSidebarCounts, 30000)
})

const pageTitle = computed(() => {
  const titles: Record<string, string> = {
    '/': 'Dashboard',
    '/shorts': 'Oto Shorts',
    '/marketplace': 'Oto Pazarı',
    '/vehicles': 'Araçlarım',
    '/offers': 'Teklifler',
    '/chats': 'Mesajlar',
    '/favorites': 'Favoriler',
    '/reports': 'Raporlar',
    '/channels': 'Kanallar',
    '/activity': 'Aktivite Geçmişi',
    '/media': 'Medya Kütüphanesi',
    '/notifications': 'Bildirimler',
    '/help': 'Yardım Merkezi',
    '/settings': 'Ayarlar',
    '/admin/approvals': 'Araç Onayları',
  }
  return titles[route.path] || 'Dashboard'
})

const pageSubtitle = computed(() => {
  const subtitles: Record<string, string> = {
    '/': 'Galeri özeti ve istatistikler',
    '/shorts': 'Kısa videolarla araçları keşfet',
    '/marketplace': 'Tüm bayilerin araçları',
    '/vehicles': 'Araç envanterinizi yönetin',
    '/offers': 'Gelen ve giden teklifler',
    '/chats': 'Mesajlaşma ve iletişim',
    '/favorites': 'Beğendiğiniz araçları yönetin',
    '/reports': 'Detaylı raporlar ve analitik',
    '/channels': 'Pazar yeri entegrasyonları',
    '/activity': 'Tüm işlemlerinizin kaydı',
    '/media': 'Tüm görsellerinizi yönetin',
    '/notifications': 'Tüm bildirimlerinizi yönetin',
    '/help': 'Sık sorulan sorular ve destek kaynakları',
    '/settings': 'Galeri ayarları',
    '/admin/approvals': 'Onay bekleyen araçları yönetin',
  }
  return subtitles[route.path] || 'Galeri yönetim paneli'
})

const handleLogout = async () => {
  if (confirm('Çıkış yapmak istediğinize emin misiniz?')) {
    try {
      const api = useApi()
      await api.post('/auth/logout')
      const authToken = useCookie('auth_token')
      authToken.value = null
      navigateTo('/login')
    } catch (error) {
      const authToken = useCookie('auth_token')
      authToken.value = null
      navigateTo('/login')
    }
  }
}
</script>

<style scoped>
/* Custom scrollbar for navigation */
nav::-webkit-scrollbar {
  width: 4px;
}

nav::-webkit-scrollbar-track {
  background: transparent;
}

nav::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 2px;
}

.dark nav::-webkit-scrollbar-thumb {
  background: #475569;
}

nav::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

.dark nav::-webkit-scrollbar-thumb:hover {
  background: #64748b;
}
</style>
