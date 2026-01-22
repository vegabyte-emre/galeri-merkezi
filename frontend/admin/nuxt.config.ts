export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss',
    '@vueuse/nuxt',
    '@pinia/nuxt'
  ],
  css: ['~/assets/styles/main.css'],
  alias: {
    '~/shared': '../shared'
  },
  app: {
    head: {
      title: 'Süperadmin Paneli - Otobia',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' }
      ]
    }
  },
  runtimeConfig: {
    public: {
      apiUrl: process.env.NUXT_PUBLIC_API_URL || 'https://api.otobia.com/api/v1',
      wsUrl: process.env.NUXT_PUBLIC_WS_URL || 'wss://chat.otobia.com'
    }
  },
  ssr: false
})

