import { io, Socket } from 'socket.io-client'
import { ref, computed } from 'vue'

export const useWebSocket = () => {
  const config = useRuntimeConfig()
  // Socket.IO uses HTTP/HTTPS, not ws://
  const wsUrl = config.public.wsUrl || 'http://localhost:3005'
  const token = useCookie('auth_token')
  
  let socket: Socket | null = null
  const isConnected = ref(false)
  const messageHandlers = new Map<string, ((data: any) => void)[]>()

  const connect = () => {
    if (socket?.connected) {
      isConnected.value = true
      return socket
    }

    socket = io(wsUrl, {
      auth: {
        token: token.value
      },
      transports: ['websocket', 'polling']
    })

    socket.on('connect', () => {
      console.log('WebSocket connected')
      isConnected.value = true
    })

    socket.on('disconnect', () => {
      console.log('WebSocket disconnected')
      isConnected.value = false
    })

    socket.on('connect_error', (error) => {
      console.error('WebSocket connection error:', error)
      isConnected.value = false
    })

    // Generic message handler
    socket.onAny((event, data) => {
      const handlers = messageHandlers.get(event)
      if (handlers) {
        handlers.forEach(handler => handler(data))
      }
    })

    return socket
  }

  const disconnect = () => {
    if (socket) {
      socket.disconnect()
      socket = null
      isConnected.value = false
    }
  }

  const joinRoom = (roomId: string | number) => {
    if (socket && isConnected.value) {
      socket.emit('join_room', String(roomId))
    }
  }

  const leaveRoom = (roomId: string | number) => {
    if (socket && isConnected.value) {
      socket.emit('leave_room', String(roomId))
    }
  }

  const send = (event: string, data: any) => {
    if (socket && isConnected.value) {
      socket.emit(event, data)
    } else {
      throw new Error('WebSocket is not connected')
    }
  }

  const on = (event: string, handler: (data: any) => void) => {
    if (!messageHandlers.has(event)) {
      messageHandlers.set(event, [])
    }
    messageHandlers.get(event)!.push(handler)

    if (socket) {
      socket.on(event, handler)
    }

    // Return unsubscribe function
    return () => {
      const handlers = messageHandlers.get(event)
      if (handlers) {
        const index = handlers.indexOf(handler)
        if (index > -1) {
          handlers.splice(index, 1)
        }
      }
      if (socket) {
        socket.off(event, handler)
      }
    }
  }

  const off = (event: string, handler?: (data: any) => void) => {
    if (socket) {
      if (handler) {
        socket.off(event, handler)
        const handlers = messageHandlers.get(event)
        if (handlers) {
          const index = handlers.indexOf(handler)
          if (index > -1) {
            handlers.splice(index, 1)
          }
        }
      } else {
        socket.off(event)
        messageHandlers.delete(event)
      }
    }
  }

  onUnmounted(() => {
    disconnect()
  })

  return {
    connect,
    disconnect,
    joinRoom,
    leaveRoom,
    send,
    on,
    off,
    socket: computed(() => socket),
    isConnected: computed(() => isConnected.value)
  }
}




