export const useApi = () => {
  const config = useRuntimeConfig()
  const baseUrl = config.public.apiUrl || 'https://api.otobia.com/api/v1'
  // Ensure all API calls go through /api/v1 prefix
  const apiUrl = baseUrl.endsWith('/api/v1') ? baseUrl : `${baseUrl}/api/v1`

  const request = async <T>(
    endpoint: string,
    options: RequestInit & { responseType?: 'blob' | 'json' } = {}
  ): Promise<T> => {
    const token = useCookie('auth_token')
    const { responseType, ...fetchOptions } = options
    
    const headers: HeadersInit = {
      ...(fetchOptions.headers || {}),
    }
    
    // Only set Content-Type for JSON requests
    if (!(fetchOptions.body instanceof FormData)) {
      headers['Content-Type'] = 'application/json'
    }
    
    if (token.value) {
      headers['Authorization'] = `Bearer ${token.value}`
    }
    
    // Remove leading /api/v1 from endpoint if present (to avoid duplication)
    const cleanEndpoint = endpoint.startsWith('/api/v1') 
      ? endpoint.replace('/api/v1', '') 
      : endpoint
    
    const response = await fetch(`${apiUrl}${cleanEndpoint}`, {
      ...fetchOptions,
      headers,
    })

    if (!response.ok) {
      let errorMessage = 'Request failed'
      try {
        const error = await response.json()
        // Handle both {message: ''} and {error: {message: ''}} formats
        errorMessage = error.message || error.error?.message || errorMessage
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



