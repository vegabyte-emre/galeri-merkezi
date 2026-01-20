export default defineNuxtPlugin(() => {
  // Client-side only - dark mode initialization
  if (typeof window !== 'undefined' && typeof document !== 'undefined') {
    const storageKey = 'otobia-panel-theme'
    const stored = localStorage.getItem(storageKey)
    
    // Eğer localStorage'da değer varsa uygula
    if (stored === 'true') {
      document.documentElement.classList.add('dark')
    } else if (stored === 'false') {
      document.documentElement.classList.remove('dark')
    } else {
      // Varsayılan olarak light mode (dark class'ı yok)
      document.documentElement.classList.remove('dark')
    }
  }
})

