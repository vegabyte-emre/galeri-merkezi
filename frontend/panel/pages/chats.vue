<template>
  <div class="flex flex-col lg:flex-row h-[600px] lg:h-[calc(100vh-180px)] bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden">
    <!-- Mobile Header - Sohbet Secildiginde Geri Butonu -->
    <div v-if="selectedChatId && isMobile" class="lg:hidden flex items-center gap-3 p-4 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
      <button @click="selectedChatId = null" class="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-full transition-colors">
        <ChevronLeft class="w-5 h-5 text-gray-600 dark:text-gray-400" />
      </button>
      <div v-if="selectedChat" class="flex items-center gap-3 flex-1">
        <div class="relative">
          <div class="w-10 h-10 rounded-full bg-gradient-to-br from-emerald-400 to-teal-600 flex items-center justify-center text-white font-bold text-sm">
            {{ getInitials(selectedChat.galleryName || 'G') }}
          </div>
          <div v-if="selectedChat.isOnline" class="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-green-500 border-2 border-white dark:border-gray-800 rounded-full"></div>
        </div>
        <div class="flex-1 min-w-0">
          <h3 class="font-semibold text-gray-900 dark:text-white truncate text-sm">{{ selectedChat.galleryName }}</h3>
          <p class="text-xs text-gray-500 dark:text-gray-400">
            <span v-if="remoteTyping" class="text-emerald-500 animate-pulse">Yazıyor...</span>
            <span v-else-if="selectedChat.isOnline" class="text-green-500">Çevrimiçi</span>
            <span v-else>{{ formatLastSeen(selectedChat.lastSeen) }}</span>
          </p>
        </div>
      </div>
    </div>

    <!-- Chat List Panel -->
    <div 
      class="w-full lg:w-80 xl:w-96 border-r border-gray-200 dark:border-gray-700 flex flex-col flex-shrink-0"
      :class="{ 'hidden lg:flex': selectedChatId && isMobile }"
    >
      <!-- Header -->
      <div class="p-4 lg:p-5 border-b border-gray-100 dark:border-gray-700/50">
        <div class="flex items-center justify-between mb-4">
          <div>
            <h1 class="text-xl lg:text-2xl font-bold text-gray-900 dark:text-white">Mesajlar</h1>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{{ chats.length }} sohbet</p>
          </div>
          <div class="flex items-center gap-2">
            <div v-if="wsConnected" class="flex items-center gap-1.5 px-2.5 py-1 bg-green-100 dark:bg-green-900/30 rounded-full">
              <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
              <span class="text-xs font-medium text-green-700 dark:text-green-400">Çevrimiçi</span>
            </div>
            <div v-else class="flex items-center gap-1.5 px-2.5 py-1 bg-amber-100 dark:bg-amber-900/30 rounded-full">
              <div class="w-2 h-2 bg-amber-500 rounded-full"></div>
              <span class="text-xs font-medium text-amber-700 dark:text-amber-400">Bağlantı Bekleniyor</span>
            </div>
          </div>
        </div>
        
        <!-- Search -->
        <div class="relative">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Sohbet veya mesaj ara..."
            class="w-full pl-10 pr-4 py-2.5 bg-gray-100 dark:bg-gray-700/50 border-0 rounded-xl text-sm text-gray-900 dark:text-white placeholder-gray-500 focus:ring-2 focus:ring-emerald-500 focus:bg-white dark:focus:bg-gray-700 transition-all"
          />
        </div>
      </div>

      <!-- Chat List -->
      <div class="flex-1 overflow-y-auto custom-scrollbar">
        <div v-if="loadingChats" class="flex flex-col items-center justify-center py-12">
          <div class="w-10 h-10 border-3 border-emerald-500 border-t-transparent rounded-full animate-spin mb-3"></div>
          <p class="text-sm text-gray-500 dark:text-gray-400">Yükleniyor...</p>
        </div>
        
        <div v-else-if="filteredChats.length === 0" class="flex flex-col items-center justify-center py-12 px-4">
          <div class="w-16 h-16 bg-gray-100 dark:bg-gray-700 rounded-full flex items-center justify-center mb-4">
            <MessageSquare class="w-8 h-8 text-gray-400" />
          </div>
          <p class="text-gray-500 dark:text-gray-400 font-medium">{{ searchQuery ? 'Sonuç bulunamadı' : 'Henüz sohbet yok' }}</p>
          <p class="text-xs text-gray-400 mt-1">{{ searchQuery ? 'Farklı bir arama deneyin' : 'Oto Pazarı\'ndan mesaj gönderin' }}</p>
        </div>

        <div v-else class="divide-y divide-gray-100 dark:divide-gray-700/50">
          <div
            v-for="chat in filteredChats"
            :key="chat.id"
            @click="() => selectChat(chat.id)"
            class="group flex items-center gap-3 p-4 hover:bg-gray-50 dark:hover:bg-gray-700/30 cursor-pointer transition-all duration-200"
            :class="{ 
              'bg-emerald-50 dark:bg-emerald-900/20 border-l-4 border-emerald-500': selectedChatId === chat.id,
              'border-l-4 border-transparent': selectedChatId !== chat.id
            }"
          >
            <!-- Avatar -->
            <div class="relative flex-shrink-0">
              <div class="w-12 h-12 rounded-full bg-gradient-to-br from-emerald-400 to-teal-600 flex items-center justify-center text-white font-bold shadow-md group-hover:shadow-lg transition-shadow">
                {{ getInitials(chat.galleryName || 'G') }}
              </div>
              <div v-if="chat.isOnline" class="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-green-500 border-2 border-white dark:border-gray-800 rounded-full"></div>
            </div>

            <!-- Content -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center justify-between mb-1">
                <h3 class="font-semibold text-gray-900 dark:text-white truncate text-sm">
                  {{ chat.galleryName }}
                </h3>
                <div class="flex items-center gap-2 flex-shrink-0">
                  <span class="text-xs text-gray-500 dark:text-gray-400 whitespace-nowrap">
                    {{ formatTime(chat.lastMessageTime) }}
                  </span>
                  <button
                    @click.stop="deleteChat(chat.id)"
                    :disabled="deletingChat"
                    class="opacity-0 group-hover:opacity-100 p-1 hover:bg-red-100 dark:hover:bg-red-900/20 rounded transition-all"
                    title="Sohbeti Sil"
                  >
                    <Trash2 class="w-4 h-4 text-red-500" />
                  </button>
                </div>
              </div>
              <div class="flex items-center justify-between">
                <p class="text-sm text-gray-600 dark:text-gray-400 truncate flex-1">
                  <span v-if="chat.typing" class="text-emerald-500 italic">Yazıyor...</span>
                  <span v-else>{{ chat.lastMessage || 'Henüz mesaj yok' }}</span>
                </p>
                <div v-if="chat.unreadCount > 0" class="ml-2 flex-shrink-0 min-w-[20px] h-5 px-1.5 bg-emerald-500 text-white text-xs font-bold rounded-full flex items-center justify-center">
                  {{ chat.unreadCount > 99 ? '99+' : chat.unreadCount }}
                </div>
              </div>
              <div v-if="chat.vehicleTitle" class="mt-1 flex items-center gap-1">
                <Car class="w-3 h-3 text-gray-400" />
                <span class="text-xs text-gray-500 dark:text-gray-400 truncate">{{ chat.vehicleTitle }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Chat Messages Panel -->
    <div 
      class="flex-1 flex flex-col overflow-hidden min-w-0"
      :class="{ 'hidden lg:flex': !selectedChatId && isMobile }"
    >
      <template v-if="selectedChat">
        <!-- Chat Header - Desktop -->
        <div class="hidden lg:flex items-center justify-between p-4 border-b border-gray-100 dark:border-gray-700/50 bg-gradient-to-r from-gray-50 to-white dark:from-gray-800 dark:to-gray-800">
          <div class="flex items-center gap-3">
            <div class="relative">
              <div class="w-11 h-11 rounded-full bg-gradient-to-br from-emerald-400 to-teal-600 flex items-center justify-center text-white font-bold shadow-md">
                {{ getInitials(selectedChat.galleryName || 'G') }}
              </div>
              <div v-if="selectedChat.isOnline" class="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-green-500 border-2 border-white dark:border-gray-800 rounded-full"></div>
            </div>
            <div>
              <h3 class="font-semibold text-gray-900 dark:text-white">{{ selectedChat.galleryName }}</h3>
              <p class="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1.5">
                <span v-if="remoteTyping" class="text-emerald-500 flex items-center gap-1">
                  <span class="flex gap-0.5">
                    <span class="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-bounce" style="animation-delay: 0ms"></span>
                    <span class="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-bounce" style="animation-delay: 150ms"></span>
                    <span class="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-bounce" style="animation-delay: 300ms"></span>
                  </span>
                  Yazıyor
                </span>
                <span v-else-if="selectedChat.isOnline" class="flex items-center gap-1">
                  <span class="w-2 h-2 bg-green-500 rounded-full"></span>
                  Çevrimiçi
                </span>
                <span v-else>Son görülme: {{ formatLastSeen(selectedChat.lastSeen) }}</span>
              </p>
            </div>
          </div>
          <div class="flex items-center gap-2 relative">
            <button 
              @click="showPhoneInfo"
              class="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-full transition-colors" 
              title="Telefon Bilgisi"
            >
              <Phone class="w-5 h-5 text-gray-500 hover:text-emerald-500" />
            </button>
            <button 
              @click="showGalleryInfo = !showGalleryInfo"
              class="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-full transition-colors" 
              title="Galeri Bilgisi"
              :class="{ 'bg-emerald-100 dark:bg-emerald-900/30': showGalleryInfo }"
            >
              <Info class="w-5 h-5" :class="showGalleryInfo ? 'text-emerald-500' : 'text-gray-500'" />
            </button>
            <div class="relative">
              <button 
                @click="showMenu = !showMenu"
                class="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-full transition-colors" 
                title="Daha fazla"
              >
                <MoreVertical class="w-5 h-5 text-gray-500" />
              </button>
              <Transition name="fade">
                <div 
                  v-if="showMenu"
                  class="absolute right-0 top-12 w-48 bg-white dark:bg-gray-800 rounded-xl shadow-lg border border-gray-200 dark:border-gray-700 py-2 z-50"
                >
                  <button
                    @click="deleteChat(selectedChatId!)"
                    :disabled="deletingChat"
                    class="w-full px-4 py-2 text-left text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors flex items-center gap-2 disabled:opacity-50"
                  >
                    <Trash2 class="w-4 h-4" />
                    <span>Sohbeti Sil</span>
                  </button>
                </div>
              </Transition>
            </div>
          </div>
        </div>

        <!-- Vehicle Info Banner -->
        <div v-if="selectedChat.vehicleTitle" class="px-4 py-2 bg-emerald-50 dark:bg-emerald-900/20 border-b border-emerald-100 dark:border-emerald-800/30">
          <div class="flex items-center gap-2">
            <Car class="w-4 h-4 text-emerald-600 dark:text-emerald-400" />
            <span class="text-sm text-emerald-700 dark:text-emerald-300 font-medium">{{ selectedChat.vehicleTitle }}</span>
            <span v-if="selectedChat.vehiclePrice" class="ml-auto text-sm font-bold text-emerald-600 dark:text-emerald-400">
              {{ formatPrice(selectedChat.vehiclePrice) }}
            </span>
          </div>
        </div>

        <!-- Messages Container -->
        <div 
          ref="messagesContainer" 
          class="flex-1 overflow-y-auto p-4 space-y-3 bg-gradient-to-b from-gray-50 to-gray-100/50 dark:from-gray-900/30 dark:to-gray-900/50 custom-scrollbar"
          @scroll="handleScroll"
        >
          <!-- Load More Button -->
          <div v-if="hasMoreMessages" class="text-center py-2">
            <button 
              @click="loadMoreMessages" 
              :disabled="loadingMoreMessages"
              class="px-4 py-1.5 text-xs font-medium text-gray-600 dark:text-gray-400 bg-white dark:bg-gray-700 rounded-full shadow-sm hover:shadow transition-all disabled:opacity-50"
            >
              <Loader2 v-if="loadingMoreMessages" class="w-4 h-4 animate-spin inline mr-1" />
              {{ loadingMoreMessages ? 'Yükleniyor...' : 'Daha eski mesajlar' }}
            </button>
          </div>

          <!-- Loading State -->
          <div v-if="loadingMessages" class="flex flex-col items-center justify-center py-12">
            <div class="w-10 h-10 border-3 border-emerald-500 border-t-transparent rounded-full animate-spin mb-3"></div>
            <p class="text-sm text-gray-500 dark:text-gray-400">Mesajlar yükleniyor...</p>
          </div>

          <!-- Empty State -->
          <div v-else-if="messages.length === 0" class="flex flex-col items-center justify-center py-16">
            <div class="w-20 h-20 bg-emerald-100 dark:bg-emerald-900/30 rounded-full flex items-center justify-center mb-4">
              <MessageCircle class="w-10 h-10 text-emerald-500" />
            </div>
            <p class="text-gray-600 dark:text-gray-400 font-medium mb-1">Sohbete başlayın!</p>
            <p class="text-sm text-gray-500 dark:text-gray-500">İlk mesajı göndererek konuşmayı başlatın</p>
          </div>

          <!-- Messages -->
          <template v-else>
            <!-- Date Separator -->
            <div 
              v-for="(group, dateKey) in groupedMessages" 
              :key="dateKey"
              class="space-y-3"
            >
              <div class="flex items-center justify-center my-4">
                <div class="px-3 py-1 bg-white dark:bg-gray-700 rounded-full shadow-sm">
                  <span class="text-xs font-medium text-gray-500 dark:text-gray-400">{{ dateKey }}</span>
                </div>
              </div>

              <div
                v-for="message in group"
                :key="message.id"
                class="flex"
                :class="isMyMessage(message) ? 'justify-end' : 'justify-start'"
              >
                <div 
                  class="max-w-[85%] lg:max-w-[70%] transition-all duration-200"
                  :class="{ 'animate-slide-in': message.isNew }"
                >
                  <div
                    class="rounded-2xl px-4 py-2.5 shadow-sm relative group"
                    :class="isMyMessage(message) 
                      ? 'bg-gradient-to-br from-green-500 to-green-600 text-white rounded-br-md' 
                      : 'bg-white dark:bg-gray-100 text-gray-900 rounded-bl-md border border-gray-200'"
                  >
                    <p class="text-sm whitespace-pre-wrap break-words leading-relaxed">{{ message.content }}</p>
                    <div 
                      class="flex items-center gap-1 mt-1"
                      :class="isMyMessage(message) ? 'justify-end' : 'justify-start'"
                    >
                      <span class="text-[10px]" :class="isMyMessage(message) ? 'text-white/70' : 'text-gray-500'">
                        {{ formatMessageTime(message.createdAt) }}
                      </span>
                      <template v-if="isMyMessage(message)">
                        <CheckCheck v-if="message.readAt" class="w-3.5 h-3.5 text-white/90" />
                        <Check v-else class="w-3.5 h-3.5 text-white/70" />
                      </template>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </template>

          <!-- Scroll to Bottom Button -->
          <Transition name="fade">
            <button
              v-if="showScrollButton"
              @click="scrollToBottom"
              class="fixed bottom-32 right-8 w-10 h-10 bg-white dark:bg-gray-700 rounded-full shadow-lg flex items-center justify-center hover:scale-110 transition-transform z-10"
            >
              <ChevronDown class="w-5 h-5 text-gray-600 dark:text-gray-400" />
            </button>
          </Transition>
        </div>

        <!-- Typing Indicator -->
        <Transition name="slide-up">
          <div v-if="remoteTyping" class="px-4 py-2 border-t border-gray-100 dark:border-gray-700/50">
            <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
              <div class="flex gap-1">
                <span class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0ms"></span>
                <span class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 150ms"></span>
                <span class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 300ms"></span>
              </div>
              <span>{{ selectedChat.galleryName }} yazıyor...</span>
            </div>
          </div>
        </Transition>

        <!-- Message Input -->
        <div class="p-3 lg:p-4 border-t border-gray-100 dark:border-gray-700/50 bg-white dark:bg-gray-800">
          <!-- Emoji Picker -->
          <Transition name="fade">
            <div v-if="showEmojiPicker" class="mb-3 p-3 bg-gray-50 dark:bg-gray-700 rounded-xl">
              <div class="flex flex-wrap gap-2">
                <button 
                  v-for="emoji in commonEmojis" 
                  :key="emoji"
                  type="button"
                  @click="insertEmoji(emoji)"
                  class="text-2xl hover:scale-125 transition-transform"
                >
                  {{ emoji }}
                </button>
              </div>
            </div>
          </Transition>

          <form @submit.prevent="sendMessage" class="flex items-end gap-2 lg:gap-3">
            <!-- Attachment Button -->
            <button 
              type="button"
              @click="openFileUpload"
              class="hidden lg:flex p-2.5 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-full transition-colors flex-shrink-0"
              title="Dosya Ekle"
            >
              <Paperclip class="w-5 h-5 text-gray-500 hover:text-emerald-500" />
            </button>
            <input 
              ref="fileInput" 
              type="file" 
              class="hidden" 
              accept="image/*,.pdf,.doc,.docx"
              @change="handleFileSelect"
            />

            <!-- Input Container -->
            <div class="flex-1 relative">
              <textarea
                ref="messageInput"
                v-model="newMessage"
                @input="handleTyping"
                @keydown="handleKeyDown"
                rows="1"
                placeholder="Mesajınızı yazın..."
                :disabled="sendingMessage"
                class="w-full px-4 py-3 pr-24 bg-gray-100 dark:bg-gray-700/50 border-0 rounded-2xl text-sm text-gray-900 dark:text-white placeholder-gray-500 focus:ring-2 focus:ring-emerald-500 focus:bg-white dark:focus:bg-gray-700 transition-all resize-none overflow-hidden disabled:opacity-50"
                style="min-height: 44px; max-height: 120px;"
              ></textarea>
              
              <!-- Input Actions -->
              <div class="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-1">
                <!-- Emoji Button -->
                <button 
                  type="button"
                  @click="showEmojiPicker = !showEmojiPicker"
                  class="p-1 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-full transition-colors"
                  :class="{ 'bg-emerald-100 dark:bg-emerald-900/30': showEmojiPicker }"
                  title="Emoji"
                >
                  <Smile class="w-5 h-5" :class="showEmojiPicker ? 'text-emerald-500' : 'text-gray-400'" />
                </button>
              </div>
            </div>

            <!-- Send Button -->
            <button
              type="submit"
              :disabled="!newMessage.trim() || sendingMessage"
              class="p-3 bg-gradient-to-br from-green-500 to-green-600 text-white rounded-full shadow-lg hover:shadow-xl hover:scale-105 active:scale-95 transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100 flex-shrink-0"
            >
              <Loader2 v-if="sendingMessage" class="w-5 h-5 animate-spin" />
              <Send v-else class="w-5 h-5" />
            </button>
          </form>
        </div>
      </template>

      <!-- No Chat Selected -->
      <template v-else>
        <div class="flex-1 flex flex-col items-center justify-center p-8 bg-gradient-to-b from-gray-50 to-white dark:from-gray-900/30 dark:to-gray-800">
          <div class="w-24 h-24 bg-gradient-to-br from-emerald-100 to-teal-100 dark:from-emerald-900/30 dark:to-teal-900/30 rounded-full flex items-center justify-center mb-6">
            <MessageCircle class="w-12 h-12 text-emerald-500" />
          </div>
          <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">Mesajlarınız</h3>
          <p class="text-gray-500 dark:text-gray-400 text-center max-w-sm">
            Soldaki listeden bir sohbet seçin veya Oto Pazarı'ndan bir araç hakkında mesaj gönderin
          </p>
          <NuxtLink to="/marketplace" class="mt-6 px-6 py-2.5 bg-gradient-to-r from-emerald-500 to-teal-600 text-white font-medium rounded-full shadow-lg hover:shadow-xl transition-all inline-flex items-center gap-2">
            <Car class="w-4 h-4" />
            Oto Pazarı'na Git
          </NuxtLink>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { 
  Search, MessageSquare, MessageCircle, Send, Check, CheckCheck, 
  ChevronLeft, ChevronDown, Phone, Info, MoreVertical, Car,
  Paperclip, Smile, Loader2, Trash2
} from 'lucide-vue-next'
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useWebSocket } from '~/composables/useWebSocket'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'
import { useAuthStore } from '~/stores/auth'

definePageMeta({
  layout: 'default'
})

useHead({
  title: 'Mesajlar - Otobia'
})

interface Chat {
  id: string
  galleryName: string
  galleryId: string
  vehicleId?: string
  vehicleTitle?: string
  vehiclePrice?: number
  lastMessage: string
  lastMessageTime: string
  unreadCount: number
  isOnline: boolean
  lastSeen?: string
  typing?: boolean
}

interface Message {
  id: string
  content: string
  senderId: string
  createdAt: string
  readAt?: string
  isNew?: boolean
}

// Responsive
const isMobile = ref(false)

// State
const searchQuery = ref('')
const selectedChatId = ref<string | null>(null)
const newMessage = ref('')
const loadingChats = ref(false)
const loadingMessages = ref(false)
const loadingMoreMessages = ref(false)
const sendingMessage = ref(false)
const remoteTyping = ref(false)
const showScrollButton = ref(false)
const hasMoreMessages = ref(false)
const currentPage = ref(1)
const showMenu = ref(false)
const deletingChat = ref(false)
const showGalleryInfo = ref(false)

// Refs
const messagesContainer = ref<HTMLElement | null>(null)
const messageInput = ref<HTMLTextAreaElement | null>(null)
const fileInput = ref<HTMLInputElement | null>(null)

// Emoji picker
const showEmojiPicker = ref(false)
const commonEmojis = ['😀', '😂', '😍', '🥰', '😊', '👍', '👏', '🙏', '❤️', '💯', '🔥', '✅', '🚗', '💰', '📞', '📍', '⏰', '📝']

// Composables
const api = useApi()
const toast = useToast()
const authStore = useAuthStore()
const { connect, disconnect, joinRoom, leaveRoom, send: wsSend, on: wsOn, isConnected: wsConnected } = useWebSocket()

// Get user from cookie
const userCookie = useCookie<any>('user')
const currentUserId = computed(() => {
  const user = userCookie.value
  if (!user) return null
  // Parse if string
  const userData = typeof user === 'string' ? JSON.parse(user) : user
  return userData?.id
})

// Data
const chats = ref<Chat[]>([])
const messages = ref<Message[]>([])

// Typing debounce
let typingTimeout: NodeJS.Timeout | null = null

// Computed
const filteredChats = computed(() => {
  if (!searchQuery.value) return chats.value
  const query = searchQuery.value.toLowerCase()
  return chats.value.filter(c => 
    c.galleryName.toLowerCase().includes(query) ||
    c.lastMessage?.toLowerCase().includes(query) ||
    c.vehicleTitle?.toLowerCase().includes(query)
  )
})

const selectedChat = computed(() => {
  return chats.value.find(c => c.id === selectedChatId.value) || null
})

const groupedMessages = computed(() => {
  const groups: Record<string, Message[]> = {}
  
  messages.value.forEach(msg => {
    const date = new Date(msg.createdAt)
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)
    
    let dateKey: string
    if (date.toDateString() === today.toDateString()) {
      dateKey = 'Bugün'
    } else if (date.toDateString() === yesterday.toDateString()) {
      dateKey = 'Dün'
    } else {
      dateKey = date.toLocaleDateString('tr-TR', { day: 'numeric', month: 'long', year: 'numeric' })
    }
    
    if (!groups[dateKey]) {
      groups[dateKey] = []
    }
    groups[dateKey].push(msg)
  })
  
  return groups
})

// Methods
const isMyMessage = (message: Message) => {
  return message.senderId === currentUserId.value
}

const getInitials = (name: string) => {
  if (!name) return 'G'
  const parts = name.trim().split(' ')
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}

const formatTime = (time: string | undefined) => {
  if (!time) return ''
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / (1000 * 60))
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  
  if (minutes < 1) return 'Şimdi'
  if (minutes < 60) return `${minutes}dk`
  if (hours < 24) return `${hours}sa`
  if (days < 7) return `${days}g`
  return date.toLocaleDateString('tr-TR', { day: 'numeric', month: 'short' })
}

const formatMessageTime = (time: string) => {
  if (!time) return ''
  return new Date(time).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })
}

const formatLastSeen = (time: string | undefined) => {
  if (!time) return 'Bilinmiyor'
  return formatTime(time)
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(price)
}

const loadChats = async () => {
  loadingChats.value = true
  try {
    const response = await api.get<{ success: boolean; data: any[] }>('/chats')
    const chatData = response.data || response || []
    
    // Galeri isimlerini almak için ek sorgu yapabiliriz
    chats.value = chatData.map((room: any) => {
      const isGalleryA = room.gallery_a_id === authStore.user?.gallery_id
      const otherGalleryName = isGalleryA 
        ? (room.gallery_b_name || room.gallery_b?.name || `Galeri`)
        : (room.gallery_a_name || room.gallery_a?.name || `Galeri`)
      return {
        id: room.id,
        galleryName: otherGalleryName,
        galleryId: isGalleryA ? room.gallery_b_id : room.gallery_a_id,
        vehicleId: room.vehicle_id,
        vehicleTitle: room.vehicle_title || (room.vehicle_id ? 'Araç Sorgusu' : undefined),
        vehiclePrice: room.vehicle_price,
        lastMessage: room.last_message_preview || '',
        lastMessageTime: room.last_message_at || room.updated_at,
        unreadCount: room.unread_count || 0,
        isOnline: room.is_online || false,
        lastSeen: room.last_seen || room.updated_at
      }
    })
    
    // URL'den roomId varsa seç
    const route = useRoute()
    if (route.query.roomId && typeof route.query.roomId === 'string') {
      selectedChatId.value = route.query.roomId
      await loadMessages()
    } else if (chats.value.length > 0 && !selectedChatId.value && !isMobile.value) {
      selectedChatId.value = chats.value[0].id
      await loadMessages()
    }
  } catch (error: any) {
    console.error('Sohbetler yüklenemedi:', error)
    toast.error('Sohbetler yüklenemedi')
  } finally {
    loadingChats.value = false
  }
}

const loadMessages = async () => {
  if (!selectedChatId.value) return
  
  loadingMessages.value = true
  currentPage.value = 1
  
  try {
    const response = await api.get<{ success: boolean; data: any[]; pagination?: any }>(`/chats/${selectedChatId.value}/messages`)
    const msgData = response.data || response || []
    
    messages.value = msgData.map((msg: any) => ({
      id: msg.id,
      content: msg.content,
      senderId: msg.sender_id,
      createdAt: msg.created_at,
      readAt: msg.read_at
    }))
    
    hasMoreMessages.value = response.pagination?.totalPages > 1
    
    await nextTick()
    scrollToBottom()
    
    // Okundu işaretle
    markAsRead()
  } catch (error: any) {
    console.error('Mesajlar yüklenemedi:', error)
    toast.error('Mesajlar yüklenemedi')
  } finally {
    loadingMessages.value = false
  }
}

const loadMoreMessages = async () => {
  if (!selectedChatId.value || loadingMoreMessages.value) return
  
  loadingMoreMessages.value = true
  currentPage.value++
  
  try {
    const response = await api.get<{ success: boolean; data: any[]; pagination?: any }>(`/chats/${selectedChatId.value}/messages?page=${currentPage.value}`)
    const msgData = response.data || []
    
    const olderMessages = msgData.map((msg: any) => ({
      id: msg.id,
      content: msg.content,
      senderId: msg.sender_id,
      createdAt: msg.created_at,
      readAt: msg.read_at
    }))
    
    messages.value = [...olderMessages, ...messages.value]
    hasMoreMessages.value = response.pagination?.page < response.pagination?.totalPages
  } catch (error) {
    console.error('Eski mesajlar yüklenemedi:', error)
  } finally {
    loadingMoreMessages.value = false
  }
}

const markAsRead = async () => {
  if (!selectedChatId.value) return
  try {
    await api.post(`/chats/${selectedChatId.value}/read`)
    const chat = chats.value.find(c => c.id === selectedChatId.value)
    if (chat) chat.unreadCount = 0
  } catch (error) {
    // Sessizce geç
  }
}

const selectChat = async (id: string) => {
  if (selectedChatId.value === id) return
  
  if (selectedChatId.value) {
    leaveRoom(selectedChatId.value)
  }
  
  selectedChatId.value = id
  messages.value = []
  remoteTyping.value = false
  
  if (wsConnected.value) {
    joinRoom(id)
  }
  
  await loadMessages()
}

const sendMessage = async () => {
  if (!newMessage.value.trim() || !selectedChatId.value || sendingMessage.value) return
  
  const content = newMessage.value.trim()
  newMessage.value = ''
  sendingMessage.value = true
  
  // Optimistic update
  const tempId = `temp-${Date.now()}`
  const tempMessage: Message = {
    id: tempId,
    content,
    senderId: authStore.user?.id || '',
    createdAt: new Date().toISOString(),
    isNew: true
  }
  messages.value.push(tempMessage)
  
  await nextTick()
  scrollToBottom()
  autoResizeInput()
  
  try {
    const response = await api.post<{ success: boolean; data: any }>(`/chats/${selectedChatId.value}/messages`, { content })
    const sentMessage = response.data || response
    
    // Replace temp message
    const index = messages.value.findIndex(m => m.id === tempId)
    if (index > -1) {
      messages.value[index] = {
        id: sentMessage.id,
        content: sentMessage.content,
        senderId: sentMessage.sender_id,
        createdAt: sentMessage.created_at,
        readAt: sentMessage.read_at
      }
    }
    
    // Update chat list
    const chat = chats.value.find(c => c.id === selectedChatId.value)
    if (chat) {
      chat.lastMessage = content
      chat.lastMessageTime = new Date().toISOString()
    }
  } catch (error: any) {
    // Remove temp message
    const index = messages.value.findIndex(m => m.id === tempId)
    if (index > -1) messages.value.splice(index, 1)
    
    newMessage.value = content
    toast.error('Mesaj gönderilemedi: ' + (error.message || 'Bir hata oluştu'))
  } finally {
    sendingMessage.value = false
    messageInput.value?.focus()
  }
}

const handleTyping = () => {
  autoResizeInput()
  
  if (!selectedChatId.value || !wsConnected.value) return
  
  wsSend('typing_start', { roomId: selectedChatId.value })
  
  if (typingTimeout) clearTimeout(typingTimeout)
  
  typingTimeout = setTimeout(() => {
    wsSend('typing_stop', { roomId: selectedChatId.value })
  }, 2000)
}

const handleKeyDown = (e: KeyboardEvent) => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    sendMessage()
  }
}

const autoResizeInput = () => {
  if (messageInput.value) {
    messageInput.value.style.height = 'auto'
    messageInput.value.style.height = Math.min(messageInput.value.scrollHeight, 120) + 'px'
  }
}

const insertEmoji = (emoji: string) => {
  newMessage.value += emoji
  showEmojiPicker.value = false
  messageInput.value?.focus()
}

const openFileUpload = () => {
  fileInput.value?.click()
}

const handleFileSelect = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return
  
  // Dosya boyutu kontrolü (max 10MB)
  if (file.size > 10 * 1024 * 1024) {
    toast.error('Dosya boyutu 10MB\'dan küçük olmalıdır')
    return
  }
  
  toast.info(`${file.name} dosyası seçildi. Dosya gönderme özelliği yakında aktif olacak.`)
  target.value = '' // Reset input
}

const showPhoneInfo = () => {
  if (selectedChat.value) {
    toast.info(`Telefon bilgisi için galeri detaylarına bakın.`)
  }
}

const scrollToBottom = () => {
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
  showScrollButton.value = false
}

const handleScroll = () => {
  if (!messagesContainer.value) return
  const { scrollTop, scrollHeight, clientHeight } = messagesContainer.value
  showScrollButton.value = scrollHeight - scrollTop - clientHeight > 200
}

const checkMobile = () => {
  isMobile.value = window.innerWidth < 1024
}

const deleteChat = async (chatId: string) => {
  if (!confirm('Bu sohbeti silmek istediğinize emin misiniz? Bu işlem geri alınamaz.')) {
    return
  }

  deletingChat.value = true
  try {
    await api.delete(`/chats/${chatId}`)
    toast.success('Sohbet silindi')
    
    // Remove from list
    chats.value = chats.value.filter(c => c.id !== chatId)
    
    // If deleted chat was selected, clear selection
    if (selectedChatId.value === chatId) {
      selectedChatId.value = null
      messages.value = []
      if (chats.value.length > 0) {
        selectedChatId.value = chats.value[0].id
        await loadMessages()
      }
    }
  } catch (error: any) {
    toast.error('Sohbet silinemedi: ' + (error.message || 'Bir hata oluştu'))
  } finally {
    deletingChat.value = false
    showMenu.value = false
  }
}

// WebSocket listeners - stored for cleanup
let messageUnsubscribe: (() => void) | null = null
let typingUnsubscribe: (() => void) | null = null
let typingStopUnsubscribe: (() => void) | null = null
let listenersSetup = false

const setupWebSocketListeners = () => {
  // Prevent duplicate listeners
  if (listenersSetup) {
    console.log('[Chat] Listeners already setup, skipping')
    return
  }
  listenersSetup = true
  console.log('[Chat] Setting up WebSocket listeners')
  
  messageUnsubscribe = wsOn('new_message', (data: any) => {
    console.log('[Chat] new_message event received:', data)
    
    if (data.roomId === selectedChatId.value) {
      const newMsg: Message = {
        id: data.message.id,
        content: data.message.content,
        senderId: data.message.sender_id,
        createdAt: data.message.created_at,
        isNew: true
      }
      
      // Kendi mesajımızı eklemeyelim (zaten optimistic olarak eklendi)
      if (newMsg.senderId !== authStore.user?.id) {
        console.log('[Chat] Adding message to list:', newMsg)
        messages.value.push(newMsg)
        nextTick(() => scrollToBottom())
        markAsRead()
      }
    }
    
    // Chat listesini güncelle
    const chat = chats.value.find(c => c.id === data.roomId)
    if (chat) {
      chat.lastMessage = data.message.content
      chat.lastMessageTime = data.message.created_at
      if (data.roomId !== selectedChatId.value) {
        chat.unreadCount++
      }
    }
  })
  
  typingUnsubscribe = wsOn('user_typing', (data: any) => {
    if (data.roomId === selectedChatId.value) {
      remoteTyping.value = true
      setTimeout(() => { remoteTyping.value = false }, 3000)
    }
  })
  
  typingStopUnsubscribe = wsOn('user_stopped_typing', (data: any) => {
    if (data.roomId === selectedChatId.value) {
      remoteTyping.value = false
    }
  })
}

const cleanupWebSocketListeners = () => {
  console.log('[Chat] Cleaning up WebSocket listeners')
  if (messageUnsubscribe) messageUnsubscribe()
  if (typingUnsubscribe) typingUnsubscribe()
  if (typingStopUnsubscribe) typingStopUnsubscribe()
  messageUnsubscribe = null
  typingUnsubscribe = null
  typingStopUnsubscribe = null
  listenersSetup = false
}

// Click outside handler for dropdown
const handleClickOutside = (event: MouseEvent) => {
  const target = event.target as HTMLElement
  if (!target.closest('.relative')) {
    showMenu.value = false
  }
}

// Lifecycle
onMounted(async () => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
  document.addEventListener('click', handleClickOutside)
  
  // Connect to WebSocket first
  console.log('[Chat] Mounting, connecting WebSocket...')
  connect()
  
  // Setup listeners (will work even before connection is established)
  setupWebSocketListeners()
  
  // Watch for connection changes to rejoin room
  watch(wsConnected, (connected) => {
    console.log('[Chat] WebSocket connected:', connected)
    if (connected && selectedChatId.value) {
      console.log('[Chat] Rejoining room after connect:', selectedChatId.value)
      joinRoom(selectedChatId.value)
    }
  })
  
  await loadChats()
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
  document.removeEventListener('click', handleClickOutside)
  
  if (selectedChatId.value) {
    leaveRoom(selectedChatId.value)
  }
  
  cleanupWebSocketListeners()
  if (typingTimeout) clearTimeout(typingTimeout)
  
  disconnect()
})

// Watch selectedChatId to load messages and join room
watch(selectedChatId, async (newId, oldId) => {
  // Leave old room first
  if (oldId) {
    console.log('[Chat] Leaving old room:', oldId)
    leaveRoom(oldId)
  }
  
  if (newId) {
    console.log('[Chat] Selected chat changed to:', newId)
    await loadMessages()
    // Always try to join room - WebSocket will handle it when connected
    console.log('[Chat] Joining room:', newId, 'WS connected:', wsConnected.value)
    joinRoom(newId)
  } else {
    messages.value = []
  }
})

// Watch messages for auto-scroll
watch(messages, () => {
  nextTick(() => {
    if (!showScrollButton.value) {
      scrollToBottom()
    }
  })
}, { deep: true })
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(156, 163, 175, 0.5);
  border-radius: 3px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(156, 163, 175, 0.7);
}

.animate-slide-in {
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: all 0.2s ease;
}
.slide-up-enter-from,
.slide-up-leave-to {
  opacity: 0;
  transform: translateY(10px);
}
</style>
