export const useAuth = () => {
  const token = useCookie('auth_token')
  const user = useState('user', () => null)

  const login = async (phone: string, password: string) => {
    const api = useApi()
    const response = await api.post('/auth/login', { phone, password })
    
    if (response.success) {
      token.value = response.accessToken
      user.value = response.user
      return response
    }
    
    throw new Error('Login failed')
  }

  const logout = () => {
    token.value = null
    user.value = null
    navigateTo('/')
  }

  const isAuthenticated = computed(() => !!token.value)

  return {
    user: readonly(user),
    login,
    logout,
    isAuthenticated,
  }
}
















