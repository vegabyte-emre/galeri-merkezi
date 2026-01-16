export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss',
    '@vueuse/nuxt',
    '@pinia/nuxt'
  ],
  css: ['~/assets/styles/main.css'],
  app: {
    head: {
      title: 'Galeri Paneli - Galeri Merkezi',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' }
      ]
    }
  },
  runtimeConfig: {
    public: {
      apiUrl: process.env.NUXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1',
      wsUrl: process.env.NUXT_PUBLIC_WS_URL || 'http://localhost:3005'
    }
  },
  ssr: false
})
