import { useAuthStore } from '~/stores/auth'

export default defineNuxtPlugin(() => {
  const authStore = useAuthStore()
  
  // Initialize auth state from cookies
  const token = useCookie('auth_token')
  const user = useCookie<any>('user')
  
  if (token.value) {
    authStore.setToken(token.value)
  }
  
  if (user.value) {
    // Parse user if it's a string
    const userData = typeof user.value === 'string' ? JSON.parse(user.value) : user.value
    authStore.setUser(userData)
  }
  
  // Watch for token changes
  watch(token, (newToken) => {
    if (newToken) {
      authStore.setToken(newToken)
    } else {
      authStore.logout()
    }
  })
  
  // Watch for user changes
  watch(user, (newUser) => {
    if (newUser) {
      authStore.setUser(newUser)
    }
  })
})
