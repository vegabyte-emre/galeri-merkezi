export default defineNuxtRouteMiddleware((to, from) => {
  const { isAuthenticated } = useAuth()
  
  if (!isAuthenticated.value && to.path.startsWith('/panel')) {
    return navigateTo('/login')
  }
})
















