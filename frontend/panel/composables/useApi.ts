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
    
    // Only set Content-Type for JSON requests
    if (!(fetchOptions.body instanceof FormData)) {
      headers['Content-Type'] = 'application/json'
    }
    
    if (token.value) {
      headers['Authorization'] = `Bearer ${token.value}`
    }
    
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 30000)
    
    try {
      const response = await fetch(`${apiUrl}${endpoint}`, {
        ...fetchOptions,
        headers,
        signal: controller.signal
      })
      clearTimeout(timeoutId)

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
    } catch (error: any) {
      clearTimeout(timeoutId)
      if (error.name === 'AbortError') {
        throw new Error('Request timeout. Please try again.')
      }
      throw error
    }
  }

  return {
    get: <T>(endpoint: string, params?: Record<string, any>, options?: RequestInit & { responseType?: 'blob' | 'json' }) => {
      let url = endpoint
      if (params && Object.keys(params).length > 0) {
        const queryString = new URLSearchParams(
          Object.entries(params)
            .filter(([_, v]) => v !== null && v !== undefined && v !== '')
            .map(([k, v]) => [k, String(v)])
        ).toString()
        if (queryString) {
          url += `?${queryString}`
        }
      }
      return request<T>(url, { ...options, method: 'GET' })
    },
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
