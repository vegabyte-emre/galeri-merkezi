import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as any,
    token: null as string | null
  }),
  
  getters: {
    isAuthenticated: (state) => !!state.token,
    userRole: (state) => state.user?.role
  },
  
  actions: {
    setUser(user: any) {
      this.user = user
    },
    
    setToken(token: string) {
      this.token = token
    },
    
    logout() {
      this.user = null
      this.token = null
    }
  }
})
















