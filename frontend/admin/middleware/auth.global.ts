export default defineNuxtRouteMiddleware((to, from) => {
  // Skip auth check for login page
  if (to.path === '/login') {
    return
  }

  // Check for auth token
  const token = useCookie('auth_token')
  
  if (!token.value) {
    // No token, redirect to login
    return navigateTo('/login')
  }

  // Optional: Check if user is superadmin
  const user = useCookie('user')
  if (user.value) {
    try {
      const userData = typeof user.value === 'string' ? JSON.parse(user.value) : user.value
      if (userData.role !== 'superadmin' && userData.role !== 'admin') {
        // Not admin, clear cookies and redirect to login
        token.value = null
        user.value = null
        return navigateTo('/login')
      }
    } catch (e) {
      // Invalid user data, clear and redirect
      token.value = null
      user.value = null
      return navigateTo('/login')
    }
  }
})
