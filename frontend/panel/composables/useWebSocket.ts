import { io, Socket } from 'socket.io-client'
import { ref, computed, watch } from 'vue'

// Singleton socket instance for the entire app
let globalSocket: Socket | null = null
const globalIsConnected = ref(false)
const globalConnectionError = ref<string | null>(null)

// Event emitter pattern - handlers are stored here and called when events arrive
const eventHandlers = new Map<string, Set<(data: any) => void>>()

// Emit to all handlers for an event
function emitToHandlers(event: string, data: any) {
  const handlers = eventHandlers.get(event)
  if (handlers && handlers.size > 0) {
    handlers.forEach(handler => {
      try {
        handler(data)
      } catch (e) {
        console.error('[WS] Handler error for event:', event, e)
      }
    })
  }
}

export const useWebSocket = () => {
  const config = useRuntimeConfig()
  // Use API URL for Socket.IO (proxied through API Gateway)
  const apiUrl = config.public.apiUrl || 'https://api.otobia.com/api/v1'
  // Extract base URL without path
  const wsUrl = apiUrl.replace(/\/api\/v1$/, '').replace(/\/api$/, '') || 'https://api.otobia.com'
  const token = useCookie('auth_token')

  const connect = () => {
    // Return existing connected socket
    if (globalSocket?.connected) {
      globalIsConnected.value = true
      return globalSocket
    }

    // If socket exists but not connected, disconnect and recreate
    if (globalSocket) {
      console.log('[WS] Reconnecting...')
      globalSocket.removeAllListeners()
      globalSocket.disconnect()
      globalSocket = null
    }

    console.log('[WS] Connecting to:', wsUrl)
    globalConnectionError.value = null

    globalSocket = io(wsUrl, {
      auth: {
        token: token.value
      },
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionAttempts: Infinity,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      timeout: 20000,
      upgrade: true
    })

    globalSocket.on('connect', () => {
      console.log('[WS] Connected! Socket ID:', globalSocket?.id)
      globalIsConnected.value = true
      globalConnectionError.value = null
    })

    globalSocket.on('disconnect', (reason) => {
      console.log('[WS] Disconnected:', reason)
      globalIsConnected.value = false
    })

    globalSocket.on('connect_error', (error) => {
      console.error('[WS] Connection error:', error.message)
      globalIsConnected.value = false
      globalConnectionError.value = error.message
    })

    globalSocket.on('reconnect', (attemptNumber) => {
      console.log('[WS] Reconnected after', attemptNumber, 'attempts')
      globalIsConnected.value = true
    })

    // Room join confirmation
    globalSocket.on('room_joined', (data) => {
      console.log('[WS] Room join result:', data)
      emitToHandlers('room_joined', data)
    })

    // Chat events - forward to handlers
    globalSocket.on('new_message', (data) => {
      console.log('[WS] New message received:', data)
      emitToHandlers('new_message', data)
    })

    globalSocket.on('user_typing', (data) => {
      emitToHandlers('user_typing', data)
    })

    globalSocket.on('user_stopped_typing', (data) => {
      emitToHandlers('user_stopped_typing', data)
    })

    return globalSocket
  }

  const disconnect = () => {
    // Don't actually disconnect - keep connection alive for other components
  }

  const forceDisconnect = () => {
    if (globalSocket) {
      globalSocket.removeAllListeners()
      globalSocket.disconnect()
      globalSocket = null
      globalIsConnected.value = false
    }
  }

  const joinRoom = (roomId: string | number) => {
    const rid = String(roomId)
    if (globalSocket) {
      console.log('[WS] Joining room:', rid, 'Connected:', globalSocket.connected)
      globalSocket.emit('join_room', rid)
    } else {
      console.warn('[WS] Cannot join room - no socket')
    }
  }

  const leaveRoom = (roomId: string | number) => {
    if (globalSocket) {
      console.log('[WS] Leaving room:', roomId)
      globalSocket.emit('leave_room', String(roomId))
    }
  }

  const send = (event: string, data: any) => {
    if (globalSocket?.connected) {
      globalSocket.emit(event, data)
    } else {
      console.warn('[WS] Cannot send - not connected')
    }
  }

  // Subscribe to an event - works even before connection
  const on = (event: string, handler: (data: any) => void) => {
    if (!eventHandlers.has(event)) {
      eventHandlers.set(event, new Set())
    }
    eventHandlers.get(event)!.add(handler)

    // Return unsubscribe function
    return () => {
      const handlers = eventHandlers.get(event)
      if (handlers) {
        handlers.delete(handler)
      }
    }
  }

  const off = (event: string, handler?: (data: any) => void) => {
    if (handler) {
      eventHandlers.get(event)?.delete(handler)
    } else {
      eventHandlers.delete(event)
    }
  }

  // Clear all handlers for an event
  const clearHandlers = (event: string) => {
    eventHandlers.delete(event)
  }

  return {
    connect,
    disconnect,
    forceDisconnect,
    joinRoom,
    leaveRoom,
    send,
    on,
    off,
    clearHandlers,
    socket: computed(() => globalSocket),
    isConnected: computed(() => globalIsConnected.value),
    connectionError: computed(() => globalConnectionError.value)
  }
}
