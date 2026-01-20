export const useApi = () => {
  const config = useRuntimeConfig()
  const apiUrl = config.public.apiUrl as string

  const request = async <T>(
    endpoint: string,
    options: RequestInit & { responseType?: 'blob' | 'json' } = {}
  ): Promise<T> => {
    const token = useCookie('auth_token')
    const { responseType, ...fetchOptions } = options
    
    const headers: HeadersInit = {
      ...(fetchOptions.headers || {}),
    }
    
    if (!(fetchOptions.body instanceof FormData)) {
      headers['Content-Type'] = 'application/json'
    }
    
    if (token.value) {
      headers['Authorization'] = `Bearer ${token.value}`
    }
    
    const response = await fetch(`${apiUrl}${endpoint}`, {
      ...fetchOptions,
      headers,
    })

    if (!response.ok) {
      let errorMessage = 'Request failed'
      try {
        const error = await response.json()
        errorMessage = error.message || errorMessage
      } catch {
        errorMessage = `HTTP ${response.status}: ${response.statusText}`
      }
      throw new Error(errorMessage)
    }

    if (responseType === 'blob') {
      return response.blob() as Promise<T>
    }
    
    return response.json()
  }

  return {
    get: <T>(endpoint: string, options?: RequestInit & { responseType?: 'blob' | 'json' }) => 
      request<T>(endpoint, { ...options, method: 'GET' }),
    post: <T>(endpoint: string, data?: any, options?: RequestInit & { responseType?: 'blob' | 'json' }) =>
      request<T>(endpoint, {
        ...options,
        method: 'POST',
        body: data instanceof FormData ? data : JSON.stringify(data),
      }),
    put: <T>(endpoint: string, data?: any, options?: RequestInit & { responseType?: 'blob' | 'json' }) =>
      request<T>(endpoint, {
        ...options,
        method: 'PUT',
        body: data instanceof FormData ? data : JSON.stringify(data),
      }),
    delete: <T>(endpoint: string, options?: RequestInit & { responseType?: 'blob' | 'json' }) =>
      request<T>(endpoint, { ...options, method: 'DELETE' }),
  }
}
