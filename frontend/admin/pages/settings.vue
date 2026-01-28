<template>
  <div class="space-y-6">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Ayarlar</h1>
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Sistem ayarlarını yönetin</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Settings Navigation -->
      <div class="lg:col-span-1">
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-4">
          <nav class="space-y-2">
            <button
              v-for="tab in tabs"
              :key="tab.id"
              @click="activeTab = tab.id"
              class="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-colors"
              :class="activeTab === tab.id 
                ? 'bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 font-semibold' 
                : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'"
            >
              <component :is="tab.icon" class="w-5 h-5" />
              <span>{{ tab.label }}</span>
            </button>
          </nav>
        </div>
      </div>

      <!-- Settings Content -->
      <div class="lg:col-span-2">
        <!-- General Settings -->
        <div v-if="activeTab === 'general'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Genel Ayarlar</h2>
          
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Platform Adı</label>
              <input
                v-model="settings.platformName"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">E-posta</label>
              <input
                v-model="settings.email"
                type="email"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Telefon</label>
              <input
                v-model="settings.phone"
                type="tel"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="settings.maintenanceMode"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Bakım Modu</span>
              </label>
            </div>
          </div>

          <button 
            @click="saveGeneralSettings"
            class="px-6 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Kaydet
          </button>
        </div>

        <!-- Security Settings -->
        <div v-if="activeTab === 'security'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Güvenlik Ayarları</h2>
          
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Minimum Şifre Uzunluğu</label>
              <input
                v-model.number="securitySettings.minPasswordLength"
                type="number"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="securitySettings.requireTwoFactor"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">2FA Zorunlu</span>
              </label>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Oturum Süresi (dakika)</label>
              <input
                v-model.number="securitySettings.sessionTimeout"
                type="number"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
          </div>

          <button 
            @click="saveSecuritySettings"
            class="px-6 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Kaydet
          </button>
        </div>

        <!-- Notification Settings -->
        <div v-if="activeTab === 'notifications'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">Bildirim Ayarları</h2>
          
          <div class="space-y-4">
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="notificationSettings.emailNotifications"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">E-posta Bildirimleri</span>
              </label>
            </div>
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="notificationSettings.smsNotifications"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">SMS Bildirimleri</span>
              </label>
            </div>
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="notificationSettings.pushNotifications"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Push Bildirimleri</span>
              </label>
            </div>
          </div>

          <button 
            @click="saveNotificationSettings"
            class="px-6 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Kaydet
          </button>
        </div>

        <!-- Email Settings -->
        <div v-if="activeTab === 'email'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-xl font-bold text-gray-900 dark:text-white">E-posta Ayarları</h2>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">E-posta gönderim yöntemini yapılandırın</p>
            </div>
          </div>

          <!-- Provider Selection -->
          <div class="space-y-4">
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">E-posta Sağlayıcısı</label>
            <div class="grid grid-cols-2 gap-4">
              <button
                @click="emailSettings.provider = 'smtp'"
                class="flex items-center gap-3 p-4 rounded-xl border-2 transition-all"
                :class="emailSettings.provider === 'smtp' 
                  ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20' 
                  : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'"
              >
                <div class="w-10 h-10 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
                  <Mail class="w-5 h-5 text-blue-600 dark:text-blue-400" />
                </div>
                <div class="text-left">
                  <div class="font-semibold text-gray-900 dark:text-white">SMTP</div>
                  <div class="text-xs text-gray-500 dark:text-gray-400">Özel SMTP sunucusu</div>
                </div>
                <div v-if="emailSettings.provider === 'smtp'" class="ml-auto">
                  <div class="w-5 h-5 rounded-full bg-primary-500 flex items-center justify-center">
                    <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
                  </div>
                </div>
              </button>

              <button
                @click="emailSettings.provider = 'gmail'"
                class="flex items-center gap-3 p-4 rounded-xl border-2 transition-all"
                :class="emailSettings.provider === 'gmail' 
                  ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20' 
                  : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'"
              >
                <div class="w-10 h-10 rounded-lg bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
                  <svg class="w-5 h-5" viewBox="0 0 24 24">
                    <path fill="#EA4335" d="M5.266 9.765A7.077 7.077 0 0 1 12 4.909c1.69 0 3.218.6 4.418 1.582L19.91 3C17.782 1.145 15.055 0 12 0 7.27 0 3.198 2.698 1.24 6.65l4.026 3.115Z"/>
                    <path fill="#34A853" d="M16.04 18.013c-1.09.703-2.474 1.078-4.04 1.078a7.077 7.077 0 0 1-6.723-4.823l-4.04 3.067A11.965 11.965 0 0 0 12 24c2.933 0 5.735-1.043 7.834-3l-3.793-2.987Z"/>
                    <path fill="#4A90E2" d="M19.834 21c2.195-2.048 3.62-5.096 3.62-9 0-.71-.109-1.473-.272-2.182H12v4.637h6.436c-.317 1.559-1.17 2.766-2.395 3.558L19.834 21Z"/>
                    <path fill="#FBBC05" d="M5.277 14.268A7.12 7.12 0 0 1 4.909 12c0-.782.125-1.533.357-2.235L1.24 6.65A11.934 11.934 0 0 0 0 12c0 1.92.445 3.73 1.237 5.335l4.04-3.067Z"/>
                  </svg>
                </div>
                <div class="text-left">
                  <div class="font-semibold text-gray-900 dark:text-white">Gmail</div>
                  <div class="text-xs text-gray-500 dark:text-gray-400">Google OAuth ile</div>
                </div>
                <div v-if="emailSettings.provider === 'gmail'" class="ml-auto">
                  <div class="w-5 h-5 rounded-full bg-primary-500 flex items-center justify-center">
                    <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
                  </div>
                </div>
              </button>
            </div>
          </div>

          <!-- SMTP Settings -->
          <div v-if="emailSettings.provider === 'smtp'" class="space-y-4 border-t border-gray-200 dark:border-gray-700 pt-6">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">SMTP Yapılandırması</h3>
            
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">SMTP Sunucu</label>
                <input
                  v-model="emailSettings.smtp.host"
                  type="text"
                  placeholder="smtp.gmail.com"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Port</label>
                <input
                  v-model.number="emailSettings.smtp.port"
                  type="number"
                  placeholder="587"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Kullanıcı Adı / E-posta</label>
                <input
                  v-model="emailSettings.smtp.user"
                  type="text"
                  placeholder="user@domain.com"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Şifre / App Password</label>
                <div class="relative">
                  <input
                    v-model="emailSettings.smtp.password"
                    :type="showSmtpPassword ? 'text' : 'password'"
                    placeholder="••••••••"
                    class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white pr-10"
                  />
                  <button
                    type="button"
                    @click="showSmtpPassword = !showSmtpPassword"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
                  >
                    <svg v-if="showSmtpPassword" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                    </svg>
                    <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Gönderen E-posta</label>
                <input
                  v-model="emailSettings.smtp.fromEmail"
                  type="email"
                  placeholder="noreply@domain.com"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Gönderen Adı</label>
                <input
                  v-model="emailSettings.smtp.fromName"
                  type="text"
                  placeholder="Otobia"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>

            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="emailSettings.smtp.secure"
                  type="checkbox"
                  class="w-4 h-4 text-primary-600 rounded"
                />
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">SSL/TLS Kullan (Port 465 için)</span>
              </label>
            </div>

            <!-- Gmail App Password Info -->
            <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
              <div class="flex gap-3">
                <div class="flex-shrink-0">
                  <svg class="w-5 h-5 text-blue-600 dark:text-blue-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
                  </svg>
                </div>
                <div class="text-sm text-blue-800 dark:text-blue-200">
                  <strong>Gmail kullanıyorsanız:</strong> Normal şifreniz çalışmaz. 
                  <a href="https://myaccount.google.com/apppasswords" target="_blank" class="underline hover:no-underline">
                    Google App Password
                  </a> oluşturmanız gerekir.
                </div>
              </div>
            </div>
          </div>

          <!-- Gmail OAuth Settings -->
          <div v-if="emailSettings.provider === 'gmail'" class="space-y-4 border-t border-gray-200 dark:border-gray-700 pt-6">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Gmail OAuth Yapılandırması</h3>
            
            <div v-if="emailSettings.gmail.isConfigured" class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-4">
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                  </svg>
                </div>
                <div>
                  <div class="font-semibold text-green-800 dark:text-green-200">Gmail Bağlı</div>
                  <div class="text-sm text-green-600 dark:text-green-400">{{ emailSettings.gmail.fromEmail }}</div>
                </div>
                <button
                  @click="disconnectGmail"
                  class="ml-auto px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"
                >
                  Bağlantıyı Kes
                </button>
              </div>
            </div>

            <div v-else class="space-y-4">
              <div class="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4">
                <div class="flex gap-3">
                  <div class="flex-shrink-0">
                    <svg class="w-5 h-5 text-yellow-600 dark:text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                  </div>
                  <div class="text-sm text-yellow-800 dark:text-yellow-200">
                    Gmail OAuth için Google Cloud Console'dan OAuth 2.0 kimlik bilgileri oluşturmanız gerekir.
                  </div>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Client ID</label>
                <input
                  v-model="emailSettings.gmail.clientId"
                  type="text"
                  placeholder="xxxxx.apps.googleusercontent.com"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Client Secret</label>
                <input
                  v-model="emailSettings.gmail.clientSecret"
                  type="password"
                  placeholder="••••••••"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Gönderen E-posta</label>
                  <input
                    v-model="emailSettings.gmail.fromEmail"
                    type="email"
                    placeholder="your@gmail.com"
                    class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Gönderen Adı</label>
                  <input
                    v-model="emailSettings.gmail.fromName"
                    type="text"
                    placeholder="Otobia"
                    class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  />
                </div>
              </div>

              <button
                @click="authorizeGmail"
                :disabled="!emailSettings.gmail.clientId || !emailSettings.gmail.clientSecret"
                class="w-full flex items-center justify-center gap-2 px-6 py-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <svg class="w-5 h-5" viewBox="0 0 24 24">
                  <path fill="#EA4335" d="M5.266 9.765A7.077 7.077 0 0 1 12 4.909c1.69 0 3.218.6 4.418 1.582L19.91 3C17.782 1.145 15.055 0 12 0 7.27 0 3.198 2.698 1.24 6.65l4.026 3.115Z"/>
                  <path fill="#34A853" d="M16.04 18.013c-1.09.703-2.474 1.078-4.04 1.078a7.077 7.077 0 0 1-6.723-4.823l-4.04 3.067A11.965 11.965 0 0 0 12 24c2.933 0 5.735-1.043 7.834-3l-3.793-2.987Z"/>
                  <path fill="#4A90E2" d="M19.834 21c2.195-2.048 3.62-5.096 3.62-9 0-.71-.109-1.473-.272-2.182H12v4.637h6.436c-.317 1.559-1.17 2.766-2.395 3.558L19.834 21Z"/>
                  <path fill="#FBBC05" d="M5.277 14.268A7.12 7.12 0 0 1 4.909 12c0-.782.125-1.533.357-2.235L1.24 6.65A11.934 11.934 0 0 0 0 12c0 1.92.445 3.73 1.237 5.335l4.04-3.067Z"/>
                </svg>
                <span class="font-medium text-gray-700 dark:text-gray-300">Google ile Yetkilendir</span>
              </button>
            </div>
          </div>

          <!-- Test Email Section -->
          <div class="border-t border-gray-200 dark:border-gray-700 pt-6 space-y-4">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Test E-postası Gönder</h3>
            
            <div class="flex gap-4">
              <input
                v-model="emailTestAddress"
                type="email"
                placeholder="test@example.com"
                class="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
              <button
                @click="sendTestEmail"
                :disabled="emailTesting || !emailTestAddress"
                class="px-6 py-2 bg-gradient-to-r from-blue-500 to-blue-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
              >
                <svg v-if="emailTesting" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <span>{{ emailTesting ? 'Gönderiliyor...' : 'Test Gönder' }}</span>
              </button>
            </div>
          </div>

          <!-- Save Button -->
          <div class="flex justify-end gap-4 pt-4">
            <button 
              @click="saveEmailSettings"
              :disabled="emailSaving"
              class="px-6 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
            >
              <svg v-if="emailSaving" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <span>{{ emailSaving ? 'Kaydediliyor...' : 'Ayarları Kaydet' }}</span>
            </button>
          </div>
        </div>

        <!-- NetGSM Settings -->
        <div v-if="activeTab === 'netgsm'" class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6 space-y-6">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white">NetGSM (SMS) Ayarları</h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            SMS sağlayıcısı olarak NetGSM kullanıyorsanız buradan yapılandırabilirsiniz.
          </p>

          <div v-if="!netgsmLoaded" class="text-sm text-gray-500 dark:text-gray-400">
            NetGSM ayarları yükleniyor...
          </div>

          <div v-else-if="!netgsmId" class="space-y-4">
            <div class="text-sm text-red-600 dark:text-red-400">
              {{ netgsmError || 'NetGSM entegrasyonu bulunamadı.' }}
            </div>
            <p class="text-sm text-gray-500 dark:text-gray-400">
              Aşağıdaki bilgileri girerek NetGSM entegrasyonunu oluşturabilirsiniz:
            </p>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Kullanıcı Adı</label>
                <input
                  v-model="netgsmUsername"
                  type="text"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="NETGSM_USERNAME"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Şifre</label>
                <input
                  v-model="netgsmPassword"
                  type="password"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="NETGSM_PASSWORD"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Mesaj Başlığı (msgHeader)</label>
                <input
                  v-model="netgsmMsgHeader"
                  type="text"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="GALERIPLATFORM"
                />
              </div>
              <button
                @click="createNetgsmIntegration"
                class="px-6 py-2 bg-gradient-to-r from-blue-500 to-blue-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
              >
                NetGSM Entegrasyonu Oluştur
              </button>
            </div>
          </div>

          <div v-else class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Kullanıcı Adı</label>
              <input
                v-model="netgsmUsername"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="NETGSM_USERNAME"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Şifre</label>
              <input
                v-model="netgsmPassword"
                type="password"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="Değiştirmek için yazın (boş bırakılırsa korunur)"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Mesaj Başlığı (msgHeader)</label>
              <input
                v-model="netgsmMsgHeader"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="GALERIPLATFORM"
              />
            </div>

            <button
              @click="saveNetgsmSettings"
              class="px-6 py-2 bg-gradient-to-r from-green-500 to-green-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
            >
              NetGSM Ayarlarını Kaydet
            </button>

            <!-- Test SMS Section -->
            <div class="border-t border-gray-200 dark:border-gray-700 pt-6 mt-6 space-y-4">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Test SMS Gönder</h3>
              <p class="text-sm text-gray-500 dark:text-gray-400">
                SMS ayarlarınızı test etmek için bir telefon numarasına test mesajı gönderin.
              </p>
              
              <div class="flex gap-4">
                <div class="flex-1">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Telefon Numarası</label>
                  <input
                    v-model="smsTestPhone"
                    type="tel"
                    placeholder="5XX XXX XX XX"
                    class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  />
                </div>
                <div class="flex-1">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Test Mesajı</label>
                  <input
                    v-model="smsTestMessage"
                    type="text"
                    placeholder="Otobia test mesajı"
                    class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  />
                </div>
              </div>

              <button
                @click="sendTestSms"
                :disabled="smsTesting || !smsTestPhone"
                class="px-6 py-2 bg-gradient-to-r from-blue-500 to-blue-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
              >
                <svg v-if="smsTesting" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <MessageSquare class="w-4 h-4" v-else />
                <span>{{ smsTesting ? 'Gönderiliyor...' : 'Test SMS Gönder' }}</span>
              </button>

              <!-- Test Result -->
              <div v-if="smsTestResult" class="rounded-lg p-4" :class="smsTestResult.success ? 'bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800' : 'bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800'">
                <div class="flex items-center gap-3">
                  <div v-if="smsTestResult.success" class="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
                  </div>
                  <div v-else class="w-8 h-8 rounded-full bg-red-500 flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                    </svg>
                  </div>
                  <div>
                    <div class="font-semibold" :class="smsTestResult.success ? 'text-green-800 dark:text-green-200' : 'text-red-800 dark:text-red-200'">
                      {{ smsTestResult.success ? 'SMS Başarıyla Gönderildi!' : 'SMS Gönderilemedi' }}
                    </div>
                    <div class="text-sm" :class="smsTestResult.success ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                      {{ smsTestResult.message }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Catalog Settings -->
        <div v-if="activeTab === 'catalog'" class="space-y-6">
          <!-- Stats Cards -->
          <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
            <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                  <Car class="w-5 h-5 text-blue-600 dark:text-blue-400" />
                </div>
                <div>
                  <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ catalogStats.brands }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">Marka</p>
                </div>
              </div>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                  <Layers class="w-5 h-5 text-green-600 dark:text-green-400" />
                </div>
                <div>
                  <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ catalogStats.series }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">Seri</p>
                </div>
              </div>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                  <Grid3x3 class="w-5 h-5 text-purple-600 dark:text-purple-400" />
                </div>
                <div>
                  <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ catalogStats.models }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">Model</p>
                </div>
              </div>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-orange-100 dark:bg-orange-900/30 rounded-lg">
                  <List class="w-5 h-5 text-orange-600 dark:text-orange-400" />
                </div>
                <div>
                  <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ catalogStats.altModels }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">Alt Model</p>
                </div>
              </div>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl p-4 border border-gray-200 dark:border-gray-700 shadow-sm">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-red-100 dark:bg-red-900/30 rounded-lg">
                  <Settings class="w-5 h-5 text-red-600 dark:text-red-400" />
                </div>
                <div>
                  <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ catalogStats.trims }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">Donanım</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Excel/CSV Import Section -->
          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2">
                <FileSpreadsheet class="w-5 h-5 text-green-600" />
                Excel/CSV ile Katalog Güncelleme
              </h2>
              <button 
                @click="loadCatalogStats"
                :disabled="catalogLoading"
                class="flex items-center gap-2 px-3 py-1.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-200 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-sm"
              >
                <RefreshCw class="w-4 h-4" :class="{ 'animate-spin': catalogLoading }" />
                Yenile
              </button>
            </div>
            
            <div class="space-y-4">
              <!-- Instructions -->
              <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
                <h3 class="font-semibold text-blue-800 dark:text-blue-200 mb-2">Desteklenen Formatlar</h3>
                <p class="text-sm text-blue-700 dark:text-blue-300 mb-2">Excel (.xlsx, .xls) ve CSV dosyaları desteklenmektedir. Dosyanız aşağıdaki sütunları içermelidir:</p>
                <div class="grid grid-cols-2 md:grid-cols-4 gap-2 text-xs">
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Ana Kategori</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Alt Kategori</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Marka</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Seri</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Model</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Alt Model</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Donanım</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Kasa Tipi</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Yakıt Tipi</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Vites</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Motor Gücü</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Motor Hacmi</span>
                  <span class="bg-blue-100 dark:bg-blue-800 px-2 py-1 rounded text-blue-800 dark:text-blue-200">Çekiş</span>
                </div>
              </div>

              <!-- Drop Zone -->
              <div
                @dragover.prevent="catalogIsDragging = true"
                @dragleave.prevent="catalogIsDragging = false"
                @drop.prevent="handleCatalogFileDrop"
                class="border-2 border-dashed rounded-xl p-8 text-center transition-colors"
                :class="catalogIsDragging 
                  ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20' 
                  : 'border-gray-300 dark:border-gray-600 hover:border-primary-400'"
              >
                <input
                  ref="catalogFileInput"
                  type="file"
                  accept=".xlsx,.xls,.csv"
                  class="hidden"
                  @change="handleCatalogFileSelect"
                />
                
                <div v-if="!catalogSelectedFile">
                  <Upload class="w-12 h-12 mx-auto text-gray-400 mb-4" />
                  <p class="text-gray-600 dark:text-gray-300 mb-2">
                    Excel veya CSV dosyasını sürükleyip bırakın
                  </p>
                  <button
                    @click="catalogFileInput?.click()"
                    class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
                  >
                    Dosya Seç
                  </button>
                  <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
                    Desteklenen formatlar: .xlsx, .xls, .csv
                  </p>
                </div>

                <div v-else class="space-y-4">
                  <div class="flex items-center justify-center gap-3">
                    <FileSpreadsheet class="w-10 h-10 text-green-600" />
                    <div class="text-left">
                      <p class="font-medium text-gray-900 dark:text-white">{{ catalogSelectedFile.name }}</p>
                      <p class="text-sm text-gray-500">{{ formatCatalogFileSize(catalogSelectedFile.size) }}</p>
                    </div>
                    <button
                      @click="clearCatalogFile"
                      class="p-2 text-gray-400 hover:text-red-500 transition-colors"
                    >
                      <X class="w-5 h-5" />
                    </button>
                  </div>

                  <!-- Preview Section -->
                  <div v-if="catalogPreviewData" class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 text-left">
                    <h4 class="font-semibold text-gray-900 dark:text-white mb-2">Önizleme</h4>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                      <div>
                        <span class="text-gray-500">Toplam Satır:</span>
                        <span class="font-bold text-gray-900 dark:text-white ml-2">{{ catalogPreviewData.totalRows }}</span>
                      </div>
                      <div>
                        <span class="text-gray-500">Markalar:</span>
                        <span class="font-bold text-gray-900 dark:text-white ml-2">{{ catalogPreviewData.brands }}</span>
                      </div>
                      <div>
                        <span class="text-gray-500">Seriler:</span>
                        <span class="font-bold text-gray-900 dark:text-white ml-2">{{ catalogPreviewData.series }}</span>
                      </div>
                      <div>
                        <span class="text-gray-500">Modeller:</span>
                        <span class="font-bold text-gray-900 dark:text-white ml-2">{{ catalogPreviewData.models }}</span>
                      </div>
                    </div>
                  </div>

                  <div class="flex gap-3 justify-center">
                    <button
                      @click="previewCatalogFile"
                      :disabled="catalogPreviewing"
                      class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors disabled:opacity-50 flex items-center gap-2"
                    >
                      <Loader2 v-if="catalogPreviewing" class="w-4 h-4 animate-spin" />
                      {{ catalogPreviewing ? 'Analiz Ediliyor...' : 'Önizle' }}
                    </button>
                    <button
                      @click="importCatalogFile"
                      :disabled="catalogImporting"
                      class="px-6 py-2 bg-gradient-to-r from-green-500 to-green-600 text-white rounded-lg hover:shadow-lg transition-all disabled:opacity-50 flex items-center gap-2"
                    >
                      <Loader2 v-if="catalogImporting" class="w-4 h-4 animate-spin" />
                      {{ catalogImporting ? 'İçe Aktarılıyor...' : 'İçe Aktar' }}
                    </button>
                  </div>
                </div>
              </div>

              <!-- Import Progress -->
              <div v-if="catalogImporting" class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
                <div class="flex items-center gap-3 mb-2">
                  <Loader2 class="w-5 h-5 animate-spin text-primary-600" />
                  <span class="font-medium text-gray-900 dark:text-white">{{ catalogImportStatus }}</span>
                </div>
                <div class="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2">
                  <div 
                    class="bg-primary-600 h-2 rounded-full transition-all duration-300"
                    :style="{ width: `${catalogImportProgress}%` }"
                  ></div>
                </div>
              </div>
            </div>
          </div>

          <!-- Brand List -->
          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2">
                <Car class="w-5 h-5 text-purple-600" />
                Markalar ({{ catalogBrands.length }})
              </h2>
              <input
                v-model="catalogBrandSearch"
                type="text"
                placeholder="Marka ara..."
                class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
              />
            </div>
            
            <div v-if="catalogLoading" class="text-center py-8 text-gray-500">
              <Loader2 class="w-8 h-8 animate-spin mx-auto mb-2" />
              Yükleniyor...
            </div>
            
            <div v-else-if="filteredCatalogBrands.length === 0" class="text-center py-8 text-gray-500">
              Henüz marka bulunmuyor
            </div>
            
            <div v-else class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 max-h-96 overflow-y-auto">
              <div 
                v-for="brand in filteredCatalogBrands" 
                :key="brand.id"
                class="p-3 bg-gray-50 dark:bg-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors"
              >
                <div class="flex items-center gap-2">
                  <img 
                    v-if="brand.logo_url" 
                    :src="brand.logo_url" 
                    class="w-8 h-8 object-contain"
                    :alt="brand.name"
                  />
                  <div v-else class="w-8 h-8 bg-gray-200 dark:bg-gray-600 rounded flex items-center justify-center text-xs font-bold text-gray-500">
                    {{ brand.name.charAt(0) }}
                  </div>
                  <div>
                    <p class="font-medium text-gray-900 dark:text-white text-sm">{{ brand.name }}</p>
                    <p class="text-xs text-gray-500">{{ brand.series_count || 0 }} seri</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Settings, Shield, Bell, MessageSquare, Mail, Car, Upload, X, FileSpreadsheet, Loader2, CheckCircle, XCircle, RefreshCw, Layers, Grid3x3, List } from 'lucide-vue-next'
import { ref, onMounted, computed, watch } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const activeTab = ref('general')

const tabs = [
  { id: 'general', label: 'Genel', icon: Settings },
  { id: 'security', label: 'Güvenlik', icon: Shield },
  { id: 'notifications', label: 'Bildirimler', icon: Bell },
  { id: 'email', label: 'E-posta', icon: Mail },
  { id: 'netgsm', label: 'NetGSM', icon: MessageSquare },
  { id: 'catalog', label: 'Araç Kataloğu', icon: Car }
]

const settings = ref({
  platformName: 'Otobia',
  email: 'info@Otobia.com',
  phone: '+90 212 555 0000',
  maintenanceMode: false
})

const securitySettings = ref({
  minPasswordLength: 8,
  requireTwoFactor: false,
  sessionTimeout: 60
})

const notificationSettings = ref({
  emailNotifications: true,
  smsNotifications: false,
  pushNotifications: true
})

// Email Settings
const emailSettings = ref({
  provider: 'smtp' as 'smtp' | 'gmail',
  smtp: {
    host: 'smtp.gmail.com',
    port: 587,
    secure: false,
    user: '',
    password: '',
    fromEmail: '',
    fromName: 'Otobia'
  },
  gmail: {
    clientId: '',
    clientSecret: '',
    refreshToken: '',
    accessToken: '',
    fromEmail: '',
    fromName: 'Otobia',
    isConfigured: false
  }
})

const emailTestAddress = ref('')
const emailTesting = ref(false)
const emailSaving = ref(false)
const showSmtpPassword = ref(false)
const gmailAuthUrl = ref('')

const isGmailSelected = computed(() => emailSettings.value.provider === 'gmail')

const netgsmLoaded = ref(false)
const netgsmId = ref<string | null>(null)
const netgsmUsername = ref('')
const netgsmPassword = ref('')
const netgsmMsgHeader = ref('GALERIPLATFORM')

// ==================== CATALOG SETTINGS ====================
interface CatalogStats {
  brands: number
  series: number
  models: number
  altModels: number
  trims: number
}

interface CatalogBrand {
  id: number
  name: string
  logo_url: string | null
  series_count?: number
}

const catalogStats = ref<CatalogStats>({ brands: 0, series: 0, models: 0, altModels: 0, trims: 0 })
const catalogBrands = ref<CatalogBrand[]>([])
const catalogLoading = ref(false)
const catalogBrandSearch = ref('')

// File upload for catalog
const catalogFileInput = ref<HTMLInputElement | null>(null)
const catalogSelectedFile = ref<File | null>(null)
const catalogIsDragging = ref(false)
const catalogPreviewing = ref(false)
const catalogImporting = ref(false)
const catalogImportProgress = ref(0)
const catalogImportStatus = ref('')
const catalogPreviewData = ref<{ totalRows: number; brands: number; series: number; models: number } | null>(null)

const filteredCatalogBrands = computed(() => {
  if (!catalogBrandSearch.value) return catalogBrands.value
  const search = catalogBrandSearch.value.toLowerCase()
  return catalogBrands.value.filter(b => b.name.toLowerCase().includes(search))
})

const formatCatalogFileSize = (bytes: number): string => {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}

const loadCatalogStats = async () => {
  catalogLoading.value = true
  try {
    const statsResponse = await api.get<any>('/catalog/admin/stats')
    if (statsResponse.data) {
      catalogStats.value = statsResponse.data
    }
    
    const brandsResponse = await api.get<any>('/catalog/admin/brands')
    if (brandsResponse.data) {
      catalogBrands.value = brandsResponse.data
    }
  } catch (error: any) {
    console.error('Failed to load catalog stats:', error)
  } finally {
    catalogLoading.value = false
  }
}

const handleCatalogFileDrop = (event: DragEvent) => {
  catalogIsDragging.value = false
  const files = event.dataTransfer?.files
  if (files && files.length > 0) {
    catalogSelectedFile.value = files[0]
    catalogPreviewData.value = null
  }
}

const handleCatalogFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    catalogSelectedFile.value = target.files[0]
    catalogPreviewData.value = null
  }
}

const clearCatalogFile = () => {
  catalogSelectedFile.value = null
  catalogPreviewData.value = null
  if (catalogFileInput.value) {
    catalogFileInput.value.value = ''
  }
}

const previewCatalogFile = async () => {
  if (!catalogSelectedFile.value) return
  
  catalogPreviewing.value = true
  try {
    const formData = new FormData()
    formData.append('file', catalogSelectedFile.value)
    formData.append('preview', 'true')
    
    const response = await api.post<any>('/catalog/admin/import', formData)
    catalogPreviewData.value = response.data
    toast.success('Dosya analizi tamamlandı')
  } catch (error: any) {
    toast.error('Dosya analizi başarısız: ' + error.message)
  } finally {
    catalogPreviewing.value = false
  }
}

const importCatalogFile = async () => {
  if (!catalogSelectedFile.value) return
  
  catalogImporting.value = true
  catalogImportProgress.value = 0
  catalogImportStatus.value = 'Dosya yükleniyor...'
  
  try {
    const formData = new FormData()
    formData.append('file', catalogSelectedFile.value)
    
    // Simulate progress
    const progressInterval = setInterval(() => {
      if (catalogImportProgress.value < 90) {
        catalogImportProgress.value += 10
        if (catalogImportProgress.value === 30) catalogImportStatus.value = 'Veriler işleniyor...'
        if (catalogImportProgress.value === 60) catalogImportStatus.value = 'Veritabanı güncelleniyor...'
        if (catalogImportProgress.value === 80) catalogImportStatus.value = 'Tamamlanıyor...'
      }
    }, 500)
    
    const response = await api.post<any>('/catalog/admin/import', formData)
    
    clearInterval(progressInterval)
    catalogImportProgress.value = 100
    catalogImportStatus.value = 'Tamamlandı!'
    
    toast.success('Katalog başarıyla içe aktarıldı: ' + (response.data?.totalRecords || 0) + ' kayıt')
    
    // Refresh stats
    await loadCatalogStats()
    
    setTimeout(() => {
      clearCatalogFile()
      catalogImporting.value = false
    }, 1500)
  } catch (error: any) {
    catalogImportStatus.value = 'İçe aktarma başarısız!'
    toast.error('İçe aktarma hatası: ' + error.message)
    
    setTimeout(() => {
      catalogImporting.value = false
    }, 2000)
  }
}

// SMS Test
const smsTestPhone = ref('')
const smsTestMessage = ref('Otobia test mesajı - SMS entegrasyonu başarılı!')
const smsTesting = ref(false)
const smsTestResult = ref<{ success: boolean; message: string } | null>(null)

const loadSettings = async () => {
  loading.value = true
  try {
    const data = await api.get<any>('/admin/settings')
    if (data.general) {
      settings.value = { ...settings.value, ...data.general }
    }
    if (data.security) {
      securitySettings.value = { ...securitySettings.value, ...data.security }
    }
    if (data.notifications) {
      notificationSettings.value = { ...notificationSettings.value, ...data.notifications }
    }
  } catch (error: any) {
    console.error('Ayarlar yüklenemedi:', error)
    // Use default values on error
  } finally {
    loading.value = false
  }
}

const saveGeneralSettings = async () => {
  try {
    await api.put('/admin/settings/general', settings.value)
    toast.success('Genel ayarlar kaydedildi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const saveSecuritySettings = async () => {
  try {
    await api.put('/admin/settings/security', securitySettings.value)
    toast.success('Güvenlik ayarları kaydedildi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const saveNotificationSettings = async () => {
  try {
    await api.put('/admin/settings/notifications', notificationSettings.value)
    toast.success('Bildirim ayarları kaydedildi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

// Email Settings Functions
const loadEmailSettings = async () => {
  try {
    const data = await api.get<any>('/admin/settings/email')
    if (data) {
      emailSettings.value = {
        ...emailSettings.value,
        provider: data.provider || 'smtp',
        smtp: { ...emailSettings.value.smtp, ...data.smtp },
        gmail: { ...emailSettings.value.gmail, ...data.gmail }
      }
    }
  } catch (error: any) {
    console.error('Email ayarları yüklenemedi:', error)
    // Use defaults
  }
}

const saveEmailSettings = async () => {
  emailSaving.value = true
  try {
    await api.put('/admin/settings/email', {
      provider: emailSettings.value.provider,
      smtp: emailSettings.value.provider === 'smtp' ? emailSettings.value.smtp : undefined,
      gmail: emailSettings.value.provider === 'gmail' ? {
        clientId: emailSettings.value.gmail.clientId,
        clientSecret: emailSettings.value.gmail.clientSecret,
        fromEmail: emailSettings.value.gmail.fromEmail,
        fromName: emailSettings.value.gmail.fromName
      } : undefined
    })
    toast.success('E-posta ayarları kaydedildi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  } finally {
    emailSaving.value = false
  }
}

const sendTestEmail = async () => {
  if (!emailTestAddress.value) {
    toast.error('Lütfen test e-posta adresi girin')
    return
  }
  emailTesting.value = true
  try {
    await api.post('/admin/settings/email/test', {
      to: emailTestAddress.value,
      provider: emailSettings.value.provider
    })
    toast.success('Test e-postası gönderildi!')
  } catch (error: any) {
    toast.error('Test başarısız: ' + (error.message || 'Bilinmeyen hata'))
  } finally {
    emailTesting.value = false
  }
}

const authorizeGmail = async () => {
  if (!emailSettings.value.gmail.clientId || !emailSettings.value.gmail.clientSecret) {
    toast.error('Client ID ve Client Secret gerekli')
    return
  }
  try {
    // First save the credentials
    await api.put('/admin/settings/email', {
      provider: 'gmail',
      gmail: {
        clientId: emailSettings.value.gmail.clientId,
        clientSecret: emailSettings.value.gmail.clientSecret,
        fromEmail: emailSettings.value.gmail.fromEmail,
        fromName: emailSettings.value.gmail.fromName
      }
    })
    
    // Get OAuth URL
    const response = await api.get<any>('/admin/settings/email/gmail/auth-url')
    if (response.authUrl) {
      // Open in new window
      window.open(response.authUrl, '_blank', 'width=600,height=700')
      toast.info('Google yetkilendirme penceresi açıldı. Yetkilendirme sonrası bu sayfayı yenileyin.')
    }
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const disconnectGmail = async () => {
  if (!confirm('Gmail bağlantısını kesmek istediğinizden emin misiniz?')) return
  try {
    await api.post('/admin/settings/email/gmail/disconnect')
    emailSettings.value.gmail.isConfigured = false
    emailSettings.value.gmail.refreshToken = ''
    emailSettings.value.gmail.accessToken = ''
    toast.success('Gmail bağlantısı kesildi')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const netgsmError = ref<string | null>(null)

const loadNetgsmSettings = async () => {
  netgsmError.value = null
  try {
    console.log('Loading NetGSM settings...')
    const data = await api.get<any>('/admin/integrations')
    console.log('Integrations response:', data)
    const list = data.integrations || data.data?.integrations || []
    console.log('Integrations list:', list)
    const netgsm = list.find((i: any) => String(i.name || '').toLowerCase().includes('netgsm'))
    console.log('Found NetGSM:', netgsm)
    if (netgsm) {
      netgsmId.value = netgsm.id
      netgsmUsername.value = netgsm.config?.username || ''
      netgsmMsgHeader.value = netgsm.config?.msgHeader || 'GALERIPLATFORM'
    } else {
      netgsmId.value = null
      netgsmError.value = 'NetGSM entegrasyonu bulunamadı. Veritabanı migration çalıştırılmalı.'
    }
  } catch (error: any) {
    console.error('NetGSM settings load error:', error)
    netgsmId.value = null
    netgsmError.value = error.message || 'Entegrasyonlar yüklenemedi'
  } finally {
    netgsmLoaded.value = true
  }
}

const createNetgsmIntegration = async () => {
  if (!netgsmUsername.value || !netgsmPassword.value) {
    toast.error('Kullanıcı adı ve şifre gerekli')
    return
  }
  try {
    await api.post('/admin/integrations', {
      name: 'NetGSM',
      type: 'sms',
      status: 'active',
      config: {
        enabled: true,
        username: netgsmUsername.value,
        password: netgsmPassword.value,
        msgHeader: netgsmMsgHeader.value || 'GALERIPLATFORM'
      }
    })
    netgsmPassword.value = ''
    toast.success('NetGSM entegrasyonu oluşturuldu!')
    await loadNetgsmSettings()
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const saveNetgsmSettings = async () => {
  if (!netgsmId.value) {
    toast.error('NetGSM entegrasyonu bulunamadı')
    return
  }
  try {
    const cfg: any = {
      enabled: true,
      username: netgsmUsername.value,
      msgHeader: netgsmMsgHeader.value || 'GALERIPLATFORM'
    }
    if (netgsmPassword.value && netgsmPassword.value.trim()) {
      cfg.password = netgsmPassword.value.trim()
    }
    await api.put(`/admin/integrations/${netgsmId.value}`, {
      status: 'active',
      config: cfg
    })
    netgsmPassword.value = ''
    toast.success('NetGSM ayarları kaydedildi!')
    await loadNetgsmSettings()
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const sendTestSms = async () => {
  if (!smsTestPhone.value) {
    toast.error('Lütfen telefon numarası girin')
    return
  }
  
  // Format phone number
  let phone = smsTestPhone.value.replace(/\s/g, '').replace(/[^0-9]/g, '')
  if (phone.startsWith('0')) {
    phone = '90' + phone.substring(1)
  } else if (!phone.startsWith('90')) {
    phone = '90' + phone
  }

  smsTesting.value = true
  smsTestResult.value = null

  try {
    const response = await api.post<any>('/admin/integrations/netgsm/test', {
      phone: phone,
      message: smsTestMessage.value || 'Otobia test mesajı'
    })
    
    smsTestResult.value = {
      success: true,
      message: response.message || `SMS ${phone} numarasına gönderildi`
    }
    toast.success('Test SMS gönderildi!')
  } catch (error: any) {
    smsTestResult.value = {
      success: false,
      message: error.message || 'SMS gönderilemedi'
    }
    toast.error('SMS gönderilemedi: ' + error.message)
  } finally {
    smsTesting.value = false
  }
}

// Watch for catalog tab activation
watch(activeTab, (newTab) => {
  if (newTab === 'catalog' && catalogStats.value.brands === 0) {
    loadCatalogStats()
  }
})

onMounted(() => {
  loadSettings()
  loadEmailSettings()
  loadNetgsmSettings()
})
</script>

