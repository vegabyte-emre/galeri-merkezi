import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as any,
    gallery: null as any,
    token: null as string | null
  }),
  
  getters: {
    isAuthenticated: (state) => !!state.token,
    galleryId: (state) => state.gallery?.id
  },
  
  actions: {
    setUser(user: any) {
      this.user = user
    },
    
    setGallery(gallery: any) {
      this.gallery = gallery
    },
    
    setToken(token: string) {
      this.token = token
    },
    
    logout() {
      this.user = null
      this.gallery = null
      this.token = null
    }
  }
})
















