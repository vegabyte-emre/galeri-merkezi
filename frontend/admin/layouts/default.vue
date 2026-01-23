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
            <Shield class="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 class="text-lg font-semibold text-gray-900 dark:text-white" style="font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif;">Otobia</h1>
            <p class="text-xs text-gray-500 dark:text-gray-400">Süperadmin Paneli</p>
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
              ? 'bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow-lg hover:shadow-xl hover:scale-[1.02]'
              : 'text-gray-700 dark:text-gray-300 hover:bg-primary-50 dark:hover:bg-gray-800 hover:text-primary-600 dark:hover:text-primary-400'
          ]"
          :active-class="item.highlight ? '' : 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400'"
        >
          <component :is="item.icon" class="w-5 h-5 group-hover:scale-110 transition-transform" />
          <span class="font-medium">{{ item.label }}</span>
          <span v-if="item.badge" :class="[
            'ml-auto px-2 py-0.5 text-xs font-semibold rounded-full',
            item.highlight ? 'bg-white/20 text-white' : 'bg-primary-500 text-white'
          ]">
            {{ item.badge }}
          </span>
        </NuxtLink>
      </nav>

      <!-- User Section - Fixed at bottom -->
      <div class="flex-shrink-0 p-4 border-t border-gray-200 dark:border-gray-800">
        <div class="flex items-center gap-3 p-3 rounded-xl bg-gray-50 dark:bg-gray-800">
          <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold">
            {{ currentUser?.name?.charAt(0) || 'A' }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold text-gray-900 dark:text-white truncate">{{ currentUser?.name || 'Admin User' }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400 truncate">{{ currentUser?.email || 'admin@otobia.com' }}</p>
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
    <div class="md:ml-64">
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
            <!-- Search -->
            <div class="hidden md:flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-800 rounded-lg">
              <Search class="w-4 h-4 text-gray-400" />
              <input
                type="text"
                placeholder="Ara..."
                class="bg-transparent border-0 outline-0 text-sm text-gray-700 dark:text-gray-300 placeholder-gray-400 w-full"
              />
            </div>
          </div>
        </div>
      </header>

      <!-- Page Content -->
      <main class="p-6">
        <slot />
      </main>
    </div>

    <!-- Sidebar Overlay (Mobile) -->
    <div
      v-if="isSidebarOpen"
      @click="isSidebarOpen = false"
      class="fixed inset-0 bg-black/50 z-30 md:hidden"
    ></div>

    <!-- Toast Container -->
    <ToastContainer />
  </div>
</template>

<script setup lang="ts">
import { 
  Shield, 
  LayoutDashboard, 
  Building2, 
  Users, 
  Settings, 
  BarChart3,
  FileText,
  Mail,
  Bell,
  Search,
  Menu,
  X,
  Sun,
  Moon,
  LogOut,
  CreditCard,
  Video,
  Car,
  CheckCircle,
  Coins
} from 'lucide-vue-next'
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useApi } from '~/composables/useApi'

const storageKey = 'otobia-admin-theme'
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

const handleLogout = async () => {
  if (confirm('Çıkış yapmak istediğinize emin misiniz?')) {
    try {
      const api = useApi()
      await api.post('/auth/logout')
    } catch (error) {
      // Ignore logout API errors
    }
    // Always clear cookies and redirect
    const authToken = useCookie('auth_token')
    const userCookie = useCookie('user')
    authToken.value = null
    userCookie.value = null
    navigateTo('/login')
  }
}

const pendingApprovalCount = ref<number>(0)
const galleryCount = ref<number>(0)
const otoShortsCount = ref<number>(0)
const currentUser = ref<{ name: string; email: string; role: string } | null>(null)

// Load current user from cookie
const loadCurrentUser = () => {
  try {
    const userCookie = useCookie('user')
    if (userCookie.value) {
      const userData = typeof userCookie.value === 'string' 
        ? JSON.parse(userCookie.value) 
        : userCookie.value
      currentUser.value = userData
    }
  } catch (e) {
    console.error('Load user error:', e)
  }
}

// Load pending approval count
const loadPendingCount = async () => {
  try {
    const api = useApi()
    const response = await api.get<{ success: boolean; pagination?: { total: number } }>('/vehicles/pending-approval')
    if (response.success && response.pagination) {
      pendingApprovalCount.value = response.pagination.total
    }
  } catch (e) {
    console.error('Pending approval count error:', e)
  }
}

// Load gallery count
const loadGalleryCount = async () => {
  try {
    const api = useApi()
    const response = await api.get<any>('/admin/galleries?limit=1')
    if (response.success && response.pagination) {
      galleryCount.value = response.pagination.total || 0
    } else if (response.galleries && Array.isArray(response.galleries)) {
      galleryCount.value = response.galleries.length
    }
  } catch (e) {
    console.error('Gallery count error:', e)
  }
}

// Load Oto Shorts count
const loadOtoShortsCount = async () => {
  try {
    const api = useApi()
    const response = await api.get<any>('/admin/oto-shorts?limit=1')
    if (response.success && response.pagination) {
      otoShortsCount.value = response.pagination.total || 0
    } else if (response.data && Array.isArray(response.data)) {
      otoShortsCount.value = response.data.length
    }
  } catch (e) {
    console.error('Oto Shorts count error:', e)
  }
}

onMounted(() => {
  loadCurrentUser()
  loadPendingCount()
  loadGalleryCount()
  loadOtoShortsCount()
  // Refresh every 30 seconds
  setInterval(() => {
    loadPendingCount()
    loadGalleryCount()
    loadOtoShortsCount()
  }, 30000)
})

const navItems = computed(() => [
  { path: '/', label: 'Dashboard', icon: LayoutDashboard },
  { path: '/vehicle-approvals', label: 'Araç Onayları', icon: Car, badge: pendingApprovalCount.value > 0 ? pendingApprovalCount.value.toString() : null, highlight: true },
  { path: '/galleries', label: 'Galeriler', icon: Building2, badge: galleryCount.value > 0 ? galleryCount.value.toString() : null },
  { path: '/users', label: 'Kullanıcılar', icon: Users },
  { path: '/oto-shorts', label: 'Oto Shorts', icon: Video, badge: otoShortsCount.value > 0 ? otoShortsCount.value.toString() : null },
  { path: '/subscriptions', label: 'Abonelikler', icon: CreditCard },
  { path: '/pricing', label: 'Fiyat Planları', icon: Coins },
  { path: '/roles', label: 'Roller & İzinler', icon: Shield },
  { path: '/reports', label: 'Raporlar', icon: BarChart3 },
  { path: '/analytics', label: 'Analitik', icon: BarChart3 },
  { path: '/logs', label: 'Sistem Logları', icon: FileText },
  { path: '/system', label: 'Sistem Durumu', icon: Shield },
  { path: '/backup', label: 'Yedekleme', icon: FileText },
  { path: '/integrations', label: 'Entegrasyonlar', icon: Settings },
  { path: '/email-templates', label: 'E-posta Şablonları', icon: Mail },
  { path: '/api-docs', label: 'API Dokümantasyonu', icon: FileText },
  { path: '/splash-config', label: 'Splash Ayarları', icon: Settings },
  { path: '/settings', label: 'Ayarlar', icon: Settings },
])

const pageTitle = computed(() => {
  const titles: Record<string, string> = {
    '/': 'Dashboard',
    '/vehicle-approvals': 'Araç Onayları',
    '/galleries': 'Galeriler',
    '/users': 'Kullanıcılar',
    '/pricing': 'Fiyat Planları',
    '/oto-shorts': 'Oto Shorts',
    '/subscriptions': 'Abonelik Yönetimi',
    '/roles': 'Roller & İzinler',
    '/reports': 'Raporlar',
    '/analytics': 'Analitik',
    '/logs': 'Sistem Logları',
    '/system': 'Sistem Durumu',
    '/backup': 'Yedekleme',
    '/integrations': 'Entegrasyonlar',
    '/email-templates': 'E-posta Şablonları',
    '/api-docs': 'API Dokümantasyonu',
    '/splash-config': 'Splash Ayarları',
    '/settings': 'Ayarlar',
  }
  return titles[route.path] || 'Dashboard'
})

const pageSubtitle = computed(() => {
  const subtitles: Record<string, string> = {
    '/': 'Genel bakış ve istatistikler',
    '/vehicle-approvals': 'Galerilerden gelen araç onay taleplerini yönetin',
    '/galleries': 'Tüm galerileri yönetin',
    '/users': 'Kullanıcı hesaplarını yönetin',
    '/oto-shorts': 'Video içeriklerini yönetin ve moderasyon yapın',
    '/subscriptions': 'Galeri aboneliklerini yönetin ve ödemeleri takip edin',
    '/roles': 'Kullanıcı rollerini ve izinlerini yönetin',
    '/reports': 'Detaylı raporlar ve analitik',
    '/analytics': 'Platform performansı ve kullanıcı davranışları',
    '/logs': 'Sistem aktivitelerini takip edin',
    '/system': 'Platform sağlığı ve performans metrikleri',
    '/backup': 'Veritabanı yedeklemelerini yönetin',
    '/integrations': 'Üçüncü parti servislerle entegrasyonlar',
    '/email-templates': 'Sistem e-postalarının şablonlarını yönetin',
    '/api-docs': 'Platform API\'sini kullanarak entegrasyonlar geliştirin',
    '/splash-config': 'Mobil uygulama açılış ekranını özelleştirin',
    '/settings': 'Sistem ayarları',
  }
  return subtitles[route.path] || 'Yönetim paneli'
})
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
