<template>
  <div class="min-h-screen bg-white dark:bg-gray-900 transition-colors duration-300">
    <!-- Navigation -->
    <header class="sticky top-0 z-50 bg-white/80 dark:bg-gray-900/80 backdrop-blur-md border-b border-gray-200 dark:border-gray-800 shadow-sm">
      <nav class="container-custom py-4">
        <div class="flex items-center justify-between">
          <!-- Logo -->
          <NuxtLink to="/" class="flex items-center gap-2 group">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300">
              <Car class="w-6 h-6 text-white" />
            </div>
            <span class="text-2xl font-bold bg-gradient-to-r from-primary-600 to-primary-800 bg-clip-text text-transparent">
              Galeri Merkezi
            </span>
          </NuxtLink>

          <!-- Desktop Navigation -->
          <div class="hidden md:flex items-center gap-6">
            <NuxtLink 
              to="/" 
              class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors relative group"
            >
              Anasayfa
              <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-primary-600 group-hover:w-full transition-all duration-300"></span>
            </NuxtLink>
            
<NuxtLink 
              to="/about" 
              class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors relative group"
            >
              Kurumsal
              <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-primary-600 group-hover:w-full transition-all duration-300"></span>
            </NuxtLink>
            <NuxtLink 
              to="/integrations" 
              class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors relative group"
            >
              Entegrasyonlar
              <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-primary-600 group-hover:w-full transition-all duration-300"></span>
            </NuxtLink>
            <NuxtLink 
              to="/pricing" 
              class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors relative group"
            >
              Fiyatlar
              <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-primary-600 group-hover:w-full transition-all duration-300"></span>
            </NuxtLink>
            <NuxtLink 
              to="/contact" 
              class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors relative group"
            >
              İletişim
              <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-primary-600 group-hover:w-full transition-all duration-300"></span>
            </NuxtLink>
          </div>

          <!-- Auth Buttons -->
          <div class="flex items-center gap-4">
            <button
              @click="toggleDarkMode"
              class="p-2 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
              aria-label="Toggle dark mode"
            >
              <Sun v-if="isDark" class="w-5 h-5" />
              <Moon v-else class="w-5 h-5" />
            </button>
            <NuxtLink 
              to="/register" 
              class="hidden sm:inline-flex px-4 py-2 text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 font-medium transition-colors"
            >
              Kayıt Ol
            </NuxtLink>
            <NuxtLink 
              to="/login" 
              class="px-6 py-2.5 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg shadow-lg hover:shadow-xl hover:scale-105 transition-all duration-300"
            >
              Giriş Yap
            </NuxtLink>
          </div>
        </div>
      </nav>
    </header>

    <!-- Main Content -->
    <main class="relative">
      <slot />
    </main>

    <!-- Footer -->
    <footer class="bg-gray-900 text-white py-16 mt-20 relative overflow-hidden">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle at 2px 2px, white 1px, transparent 0); background-size: 40px 40px;"></div>
      
      <div class="container-custom relative z-10">
        <div class="grid md:grid-cols-4 gap-12 mb-12">
          <div class="md:col-span-1">
            <div class="flex items-center gap-2 mb-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center">
                <Car class="w-6 h-6 text-white" />
              </div>
              <span class="text-xl font-bold">Galeri Merkezi</span>
            </div>
            <p class="text-gray-400 mb-6 leading-relaxed">
              Oto galerilerini birleştiren B2B platform. İşinizi büyütün, verimliliğinizi artırın.
            </p>
            <div class="flex gap-4">
              <a href="#" class="w-10 h-10 rounded-lg bg-white/10 hover:bg-primary-500 flex items-center justify-center transition-colors">
                <span class="sr-only">Twitter</span>
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84"></path></svg>
              </a>
              <a href="#" class="w-10 h-10 rounded-lg bg-white/10 hover:bg-primary-500 flex items-center justify-center transition-colors">
                <span class="sr-only">LinkedIn</span>
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/></svg>
              </a>
              <a href="#" class="w-10 h-10 rounded-lg bg-white/10 hover:bg-primary-500 flex items-center justify-center transition-colors">
                <span class="sr-only">Instagram</span>
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/></svg>
              </a>
            </div>
          </div>

          <div>
            <h4 class="font-bold mb-4 text-lg">Hızlı Linkler</h4>
            <ul class="space-y-3 text-gray-400">
              <li><NuxtLink to="/" class="hover:text-white transition-colors">Anasayfa</NuxtLink></li>
              <li><NuxtLink to="/about" class="hover:text-white transition-colors">Kurumsal</NuxtLink></li>
              <li><NuxtLink to="/pricing" class="hover:text-white transition-colors">Fiyatlar</NuxtLink></li>
              <li><NuxtLink to="/contact" class="hover:text-white transition-colors">İletişim</NuxtLink></li>
            </ul>
          </div>

          <div>
            <h4 class="font-bold mb-4 text-lg">Yasal</h4>
            <ul class="space-y-3 text-gray-400">
              <li><NuxtLink to="/privacy" class="hover:text-white transition-colors">Gizlilik Politikası</NuxtLink></li>
              <li><NuxtLink to="/terms" class="hover:text-white transition-colors">Kullanım Koşulları</NuxtLink></li>
              <li><NuxtLink to="/cookies" class="hover:text-white transition-colors">Çerez Politikası</NuxtLink></li>
              <li><NuxtLink to="/faq" class="hover:text-white transition-colors">SSS</NuxtLink></li>
            </ul>
          </div>

          <div>
            <h4 class="font-bold mb-4 text-lg">Destek</h4>
            <ul class="space-y-3 text-gray-400">
              <li><NuxtLink to="/faq" class="hover:text-white transition-colors">Yardım Merkezi</NuxtLink></li>
              <li><NuxtLink to="/contact" class="hover:text-white transition-colors">İletişim</NuxtLink></li>
            </ul>
          </div>
        </div>

        <div class="pt-8 border-t border-gray-800 flex flex-col md:flex-row justify-between items-center gap-4">
          <p class="text-gray-400 text-sm">
            © {{ new Date().getFullYear() }} Galeri Merkezi. Tüm hakları saklıdır.
          </p>
          <div class="flex gap-6 text-sm text-gray-400">
            <button @click="setLanguage('tr')" class="hover:text-white transition-colors" :class="{ 'text-white font-semibold': currentLang === 'tr' }">Türkçe</button>
            <button @click="setLanguage('en')" class="hover:text-white transition-colors" :class="{ 'text-white font-semibold': currentLang === 'en' }">English</button>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { Car, Store, Sun, Moon } from 'lucide-vue-next'
import { ref, watch, onMounted } from 'vue'

const storageKey = 'galeri-landing-theme'
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

const currentLang = ref('tr')
const setLanguage = (lang: string) => {
  currentLang.value = lang
}
</script>
