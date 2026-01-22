export default defineNuxtRouteMiddleware((to, from) => {
  // Skip auth check for login page
  if (to.path === '/login') {
    return
  }

  // Only run on client side
  if (import.meta.server) {
    return
  }

  // Check for auth token
  const token = useCookie('auth_token')
  const user = useCookie('user')
  
  // No token = redirect to login
  if (!token.value) {
    return navigateTo('/login')
  }

  // Token exists but no user data = invalid session
  if (!user.value) {
    token.value = null
    return navigateTo('/login')
  }

  // Validate user data exists
  try {
    const userData = typeof user.value === 'string' ? JSON.parse(user.value) : user.value
    
    // User must have a valid role
    if (!userData || !userData.role) {
      token.value = null
      user.value = null
      return navigateTo('/login')
    }
  } catch (e) {
    // Invalid user data
    token.value = null
    user.value = null
    return navigateTo('/login')
  }
})
