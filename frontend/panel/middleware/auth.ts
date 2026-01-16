export default defineNuxtRouteMiddleware((to, from) => {
  // Skip middleware on client side for login page (SSR: false)
  if (process.client && to.path === '/login') {
    return
  }
  
  const token = useCookie('auth_token')
  
  // Allow access to login page without auth
  if (to.path === '/login') {
    // If already logged in, redirect to dashboard
    if (token.value) {
      return navigateTo('/')
    }
    return
  }
  
  // Require auth for all other pages
  if (!token.value) {
    return navigateTo('/login')
  }
})

