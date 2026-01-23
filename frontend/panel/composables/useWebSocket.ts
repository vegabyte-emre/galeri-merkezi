import { io, Socket } from 'socket.io-client'
import { ref, computed } from 'vue'

// Singleton socket instance for the entire app
let globalSocket: Socket | null = null
const globalIsConnected = ref(false)
const globalMessageHandlers = new Map<string, ((data: any) => void)[]>()

export const useWebSocket = () => {
  const config = useRuntimeConfig()
  // Socket.IO uses HTTP/HTTPS, not ws://
  const wsUrl = config.public.wsUrl || 'https://chat.otobia.com'
  const token = useCookie('auth_token')

  const connect = () => {
    // Return existing connected socket
    if (globalSocket?.connected) {
      globalIsConnected.value = true
      console.log('[WS] Already connected, reusing socket')
      return globalSocket
    }

    // If socket exists but not connected, disconnect and recreate
    if (globalSocket) {
      console.log('[WS] Socket exists but not connected, recreating...')
      globalSocket.disconnect()
      globalSocket = null
    }

    console.log('[WS] Connecting to:', wsUrl)
    console.log('[WS] Token available:', !!token.value)

    globalSocket = io(wsUrl, {
      auth: {
        token: token.value
      },
      transports: ['websocket', 'polling'],
      // Reconnection settings
      reconnection: true,
      reconnectionAttempts: Infinity,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      randomizationFactor: 0.5,
      timeout: 20000,
      // Force new connection
      forceNew: false,
      // Upgrade from polling to websocket
      upgrade: true
    })

    globalSocket.on('connect', () => {
      console.log('[WS] Connected! Socket ID:', globalSocket?.id)
      globalIsConnected.value = true
    })

    globalSocket.on('disconnect', (reason) => {
      console.log('[WS] Disconnected. Reason:', reason)
      globalIsConnected.value = false
    })

    globalSocket.on('connect_error', (error) => {
      console.error('[WS] Connection error:', error.message)
      globalIsConnected.value = false
    })

    globalSocket.on('reconnect', (attemptNumber) => {
      console.log('[WS] Reconnected after', attemptNumber, 'attempts')
      globalIsConnected.value = true
    })

    globalSocket.on('reconnect_attempt', (attemptNumber) => {
      console.log('[WS] Reconnection attempt:', attemptNumber)
    })

    globalSocket.on('reconnect_error', (error) => {
      console.error('[WS] Reconnection error:', error.message)
    })

    // Generic message handler
    globalSocket.onAny((event, data) => {
      console.log('[WS] Event received:', event, data)
      const handlers = globalMessageHandlers.get(event)
      if (handlers) {
        handlers.forEach(handler => handler(data))
      }
    })

    return globalSocket
  }

  const disconnect = () => {
    // Don't disconnect global socket - other components might be using it
    // Just mark as disconnected for this component
    console.log('[WS] Disconnect requested (not actually disconnecting singleton)')
  }

  const forceDisconnect = () => {
    if (globalSocket) {
      console.log('[WS] Force disconnecting...')
      globalSocket.disconnect()
      globalSocket = null
      globalIsConnected.value = false
    }
  }

  const joinRoom = (roomId: string | number) => {
    if (globalSocket && globalIsConnected.value) {
      console.log('[WS] Joining room:', roomId)
      globalSocket.emit('join_room', String(roomId))
    } else {
      console.warn('[WS] Cannot join room - not connected')
    }
  }

  const leaveRoom = (roomId: string | number) => {
    if (globalSocket && globalIsConnected.value) {
      console.log('[WS] Leaving room:', roomId)
      globalSocket.emit('leave_room', String(roomId))
    }
  }

  const send = (event: string, data: any) => {
    if (globalSocket && globalIsConnected.value) {
      console.log('[WS] Sending event:', event, data)
      globalSocket.emit(event, data)
    } else {
      console.warn('[WS] Cannot send - not connected. Event:', event)
    }
  }

  const on = (event: string, handler: (data: any) => void) => {
    if (!globalMessageHandlers.has(event)) {
      globalMessageHandlers.set(event, [])
    }
    globalMessageHandlers.get(event)!.push(handler)

    if (globalSocket) {
      globalSocket.on(event, handler)
    }

    // Return unsubscribe function
    return () => {
      const handlers = globalMessageHandlers.get(event)
      if (handlers) {
        const index = handlers.indexOf(handler)
        if (index > -1) {
          handlers.splice(index, 1)
        }
      }
      if (globalSocket) {
        globalSocket.off(event, handler)
      }
    }
  }

  const off = (event: string, handler?: (data: any) => void) => {
    if (globalSocket) {
      if (handler) {
        globalSocket.off(event, handler)
        const handlers = globalMessageHandlers.get(event)
        if (handlers) {
          const index = handlers.indexOf(handler)
          if (index > -1) {
            handlers.splice(index, 1)
          }
        }
      } else {
        globalSocket.off(event)
        globalMessageHandlers.delete(event)
      }
    }
  }

  // Don't disconnect on unmount - keep connection alive
  // onUnmounted(() => {
  //   disconnect()
  // })

  return {
    connect,
    disconnect,
    forceDisconnect,
    joinRoom,
    leaveRoom,
    send,
    on,
    off,
    socket: computed(() => globalSocket),
    isConnected: computed(() => globalIsConnected.value)
  }
}




