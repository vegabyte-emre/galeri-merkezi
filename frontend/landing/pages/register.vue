<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-indigo-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 py-12 px-4">
    <div class="max-w-4xl w-full mx-auto">
      <!-- Header -->
      <div class="text-center mb-8">
        <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center mx-auto mb-4 shadow-xl transform hover:scale-105 transition-transform">
          <Car class="w-10 h-10 text-white" />
        </div>
        <h1 class="text-4xl font-bold text-gray-900 dark:text-white mb-3">
          Galeri Kaydı
        </h1>
        <p class="text-lg text-gray-600 dark:text-gray-400">
          Platforma katılmak için bilgilerinizi doldurun
        </p>
      </div>

      <!-- Main Card -->
      <div class="bg-white dark:bg-gray-800 rounded-3xl shadow-2xl border border-gray-200 dark:border-gray-700 overflow-hidden">
        <!-- Progress Steps -->
        <div class="bg-gradient-to-r from-primary-500 to-primary-600 px-8 py-6">
          <div class="flex items-center justify-between">
            <div
              v-for="(step, index) in steps"
              :key="index"
              class="flex items-center flex-1"
            >
              <div class="flex flex-col items-center flex-1">
                <div
                  class="w-12 h-12 rounded-full flex items-center justify-center font-bold text-sm transition-all shadow-lg"
                  :class="currentStep > index 
                    ? 'bg-white text-primary-600 scale-110' 
                    : currentStep === index 
                    ? 'bg-white text-primary-600 border-4 border-white/50 scale-110' 
                    : 'bg-white/20 text-white border-2 border-white/30'"
                >
                  <Check v-if="currentStep > index" class="w-6 h-6" />
                  <span v-else>{{ index + 1 }}</span>
                </div>
                <span class="mt-3 text-sm font-semibold text-white text-center">{{ step }}</span>
              </div>
              <div
                v-if="index < steps.length - 1"
                class="flex-1 h-1 mx-3 rounded-full transition-all"
                :class="currentStep > index ? 'bg-white' : 'bg-white/30'"
              ></div>
            </div>
          </div>
        </div>

        <!-- Form Content -->
        <div class="p-8">
          <form @submit.prevent="handleSubmit" class="space-y-6">
            <!-- Step 1: Gallery Info -->
            <Transition name="fade" mode="out-in">
              <div v-if="currentStep === 0" key="step1" class="space-y-6">
                <div class="text-center mb-6">
                  <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Galeri Bilgileri</h3>
                  <p class="text-sm text-gray-500 dark:text-gray-400">Galerinizin temel bilgilerini girin</p>
                </div>
                
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Galeri Adı <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="form.galleryName"
                    type="text"
                    placeholder="Örn: ABC Oto Galeri"
                    class="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    :class="errors.galleryName ? 'border-red-500' : ''"
                    required
                    @blur="validateField('galleryName')"
                  />
                  <p v-if="errors.galleryName" class="mt-1 text-sm text-red-500">{{ errors.galleryName }}</p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                      İl <span class="text-red-500">*</span>
                    </label>
                    <select
                      v-model="form.city"
                      class="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                      :class="errors.city ? 'border-red-500' : ''"
                      required
                      :disabled="loadingCities"
                      @change="onCityChange"
                    >
                      <option value="">{{ loadingCities ? 'Yükleniyor...' : 'Seçiniz' }}</option>
                      <option v-for="city in cities" :key="city.id" :value="city.id">
                        {{ city.name }}
                      </option>
                    </select>
                    <p v-if="errors.city" class="mt-1 text-sm text-red-500">{{ errors.city }}</p>
                  </div>
                  <div>
                    <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                      İlçe <span class="text-red-500">*</span>
                    </label>
                    <select
                      v-model="form.district"
                      class="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                      :class="errors.district ? 'border-red-500' : ''"
                      required
                      :disabled="!form.city || loadingDistricts"
                      @change="onDistrictChange"
                    >
                      <option value="">{{ !form.city ? 'Önce il seçin' : loadingDistricts ? 'Yükleniyor...' : 'Seçiniz' }}</option>
                      <option v-for="district in districts" :key="district.id" :value="district.id">
                        {{ district.name }}
                      </option>
                    </select>
                    <p v-if="errors.district" class="mt-1 text-sm text-red-500">{{ errors.district }}</p>
                  </div>
                </div>

                <div v-if="form.district && neighborhoods.length > 0">
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Mahalle (Opsiyonel)
                  </label>
                  <select
                    v-model="form.neighborhood"
                    class="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    :disabled="loadingNeighborhoods"
                  >
                    <option value="">{{ loadingNeighborhoods ? 'Yükleniyor...' : 'Seçiniz (Opsiyonel)' }}</option>
                    <option v-for="neighborhood in neighborhoods" :key="neighborhood.id" :value="neighborhood.id">
                      {{ neighborhood.name }}
                    </option>
                  </select>
                </div>

                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Adres
                  </label>
                  <textarea
                    v-model="form.address"
                    rows="3"
                    placeholder="Galeri adresiniz (opsiyonel)"
                    class="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all resize-none"
                  ></textarea>
                </div>
              </div>
            </Transition>

            <!-- Step 2: Contact Info -->
            <Transition name="fade" mode="out-in">
              <div v-if="currentStep === 1" key="step2" class="space-y-6">
                <div class="text-center mb-6">
                  <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">İletişim Bilgileri</h3>
                  <p class="text-sm text-gray-500 dark:text-gray-400">Size ulaşabileceğimiz bilgileri girin</p>
                </div>
                
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    E-posta Adresi <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="form.email"
                    type="email"
                    placeholder="ornek@email.com"
                    class="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    :class="errors.email ? 'border-red-500' : ''"
                    required
                    @blur="validateField('email')"
                  />
                  <p v-if="errors.email" class="mt-1 text-sm text-red-500">{{ errors.email }}</p>
                </div>

                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Telefon Numarası <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="form.phone"
                    type="tel"
                    placeholder="+90 5XX XXX XX XX"
                    class="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    :class="errors.phone ? 'border-red-500' : ''"
                    required
                    @blur="validateField('phone')"
                    @input="formatPhone"
                  />
                  <p v-if="errors.phone" class="mt-1 text-sm text-red-500">{{ errors.phone }}</p>
                  <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">Başında 0 olmadan girin (örn: 5551234567)</p>
                </div>
              </div>
            </Transition>

            <!-- Step 3: Account Info -->
            <Transition name="fade" mode="out-in">
              <div v-if="currentStep === 2" key="step3" class="space-y-6">
                <div class="text-center mb-6">
                  <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Hesap Bilgileri</h3>
                  <p class="text-sm text-gray-500 dark:text-gray-400">Güvenli bir şifre oluşturun</p>
                </div>
                
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Şifre <span class="text-red-500">*</span>
                  </label>
                  <div class="relative">
                    <input
                      v-model="form.password"
                      :type="showPassword ? 'text' : 'password'"
                      placeholder="En az 8 karakter"
                      class="w-full px-4 py-3 pr-12 border-2 border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                      :class="errors.password ? 'border-red-500' : ''"
                      required
                      minlength="8"
                      @blur="validateField('password')"
                      @input="validatePasswordStrength"
                    />
                    <button
                      type="button"
                      @click="showPassword = !showPassword"
                      class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
                    >
                      <Eye v-if="!showPassword" class="w-5 h-5" />
                      <EyeOff v-else class="w-5 h-5" />
                    </button>
                  </div>
                  <p v-if="errors.password" class="mt-1 text-sm text-red-500">{{ errors.password }}</p>
                  <div v-if="form.password" class="mt-2">
                    <div class="flex gap-1">
                      <div
                        v-for="(strength, index) in passwordStrength"
                        :key="index"
                        class="h-1 flex-1 rounded-full"
                        :class="strength"
                      ></div>
                    </div>
                    <p class="mt-1 text-xs" :class="passwordStrengthText.color">
                      {{ passwordStrengthText.text }}
                    </p>
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Şifre Tekrar <span class="text-red-500">*</span>
                  </label>
                  <div class="relative">
                    <input
                      v-model="form.passwordConfirm"
                      :type="showPasswordConfirm ? 'text' : 'password'"
                      placeholder="Şifrenizi tekrar girin"
                      class="w-full px-4 py-3 pr-12 border-2 border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                      :class="errors.passwordConfirm ? 'border-red-500' : ''"
                      required
                      @blur="validateField('passwordConfirm')"
                    />
                    <button
                      type="button"
                      @click="showPasswordConfirm = !showPasswordConfirm"
                      class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
                    >
                      <Eye v-if="!showPasswordConfirm" class="w-5 h-5" />
                      <EyeOff v-else class="w-5 h-5" />
                    </button>
                  </div>
                  <p v-if="errors.passwordConfirm" class="mt-1 text-sm text-red-500">{{ errors.passwordConfirm }}</p>
                </div>

                <div class="bg-blue-50 dark:bg-blue-900/20 border-2 border-blue-200 dark:border-blue-800 rounded-xl p-4">
                  <label class="flex items-start gap-3 cursor-pointer">
                    <input
                      v-model="form.terms"
                      type="checkbox"
                      class="mt-1 w-5 h-5 text-primary-600 rounded focus:ring-2 focus:ring-primary-500"
                      required
                    />
                    <span class="text-sm text-gray-700 dark:text-gray-300">
                      <NuxtLink to="/terms" class="text-primary-600 dark:text-primary-400 hover:underline font-semibold">
                        Kullanım koşullarını
                      </NuxtLink>
                      ve
                      <NuxtLink to="/privacy" class="text-primary-600 dark:text-primary-400 hover:underline font-semibold">
                        gizlilik politikasını
                      </NuxtLink>
                      okudum ve kabul ediyorum <span class="text-red-500">*</span>
                    </span>
                  </label>
                  <p v-if="errors.terms" class="mt-2 text-sm text-red-500">{{ errors.terms }}</p>
                </div>
              </div>
            </Transition>

            <!-- Navigation Buttons -->
            <div class="flex items-center justify-between pt-6 border-t border-gray-200 dark:border-gray-700">
              <button
                v-if="currentStep > 0"
                type="button"
                @click="currentStep--"
                class="px-8 py-3 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 font-semibold rounded-xl hover:bg-gray-200 dark:hover:bg-gray-600 transition-all flex items-center gap-2"
              >
                <ArrowLeft class="w-5 h-5" />
                Geri
              </button>
              <div v-else></div>
              
              <button
                v-if="currentStep < steps.length - 1"
                type="button"
                @click="nextStep"
                class="px-8 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-xl hover:shadow-lg hover:scale-105 transition-all flex items-center gap-2"
              >
                İleri
                <ArrowRight class="w-5 h-5" />
              </button>
              <button
                v-else
                type="submit"
                :disabled="loading || !form.terms"
                class="px-8 py-3 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-xl hover:shadow-lg hover:scale-105 transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100 flex items-center gap-2"
              >
                <Loader2 v-if="loading" class="w-5 h-5 animate-spin" />
                <span v-else>Kayıt Ol</span>
              </button>
            </div>
          </form>

          <!-- Login Link -->
          <div class="mt-8 text-center pt-6 border-t border-gray-200 dark:border-gray-700">
            <p class="text-sm text-gray-600 dark:text-gray-400">
              Zaten hesabınız var mı?
              <NuxtLink
                to="/login"
                class="font-semibold text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 transition-colors"
              >
                Giriş Yapın
              </NuxtLink>
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Car, Check, Eye, EyeOff, ArrowLeft, ArrowRight, Loader2 } from 'lucide-vue-next'
import { reactive, ref, computed, onMounted } from 'vue'
import { useTurkiyeAPI, type City, type District, type Neighborhood } from '~/composables/useTurkiyeAPI'

useHead({
  title: 'Kayıt Ol - Otobia',
  meta: [
    { name: 'description', content: 'Otobia platformuna kayıt olun ve oto galeri işinizi büyütün' }
  ]
})

const currentStep = ref(0)
const loading = ref(false)
const showPassword = ref(false)
const showPasswordConfirm = ref(false)

const steps = ['Galeri Bilgileri', 'İletişim', 'Hesap']

// TurkiyeAPI
const turkiyeAPI = useTurkiyeAPI()
const cities = ref<City[]>([])
const districts = ref<District[]>([])
const neighborhoods = ref<Neighborhood[]>([])
const loadingCities = ref(false)
const loadingDistricts = ref(false)
const loadingNeighborhoods = ref(false)

const form = reactive({
  galleryName: '',
  city: '',
  district: '',
  neighborhood: '',
  address: '',
  email: '',
  phone: '',
  password: '',
  passwordConfirm: '',
  terms: false
})

const errors = reactive({
  galleryName: '',
  city: '',
  district: '',
  email: '',
  phone: '',
  password: '',
  passwordConfirm: '',
  terms: ''
})

const passwordStrength = computed(() => {
  if (!form.password) return ['bg-gray-200', 'bg-gray-200', 'bg-gray-200', 'bg-gray-200']
  
  const length = form.password.length >= 8
  const hasUpper = /[A-Z]/.test(form.password)
  const hasLower = /[a-z]/.test(form.password)
  const hasNumber = /[0-9]/.test(form.password)
  const hasSpecial = /[^A-Za-z0-9]/.test(form.password)
  
  const strength = [length, hasUpper || hasLower, hasNumber, hasSpecial].filter(Boolean).length
  
  if (strength <= 1) return ['bg-red-500', 'bg-gray-200', 'bg-gray-200', 'bg-gray-200']
  if (strength === 2) return ['bg-yellow-500', 'bg-yellow-500', 'bg-gray-200', 'bg-gray-200']
  if (strength === 3) return ['bg-blue-500', 'bg-blue-500', 'bg-blue-500', 'bg-gray-200']
  return ['bg-green-500', 'bg-green-500', 'bg-green-500', 'bg-green-500']
})

const passwordStrengthText = computed(() => {
  if (!form.password) return { text: '', color: '' }
  
  const strength = passwordStrength.value.filter(c => !c.includes('gray')).length
  
  if (strength <= 1) return { text: 'Zayıf şifre', color: 'text-red-500' }
  if (strength === 2) return { text: 'Orta şifre', color: 'text-yellow-500' }
  if (strength === 3) return { text: 'İyi şifre', color: 'text-blue-500' }
  return { text: 'Güçlü şifre', color: 'text-green-500' }
})

const formatPhone = (event: Event) => {
  const input = event.target as HTMLInputElement
  let value = input.value.replace(/\D/g, '')
  
  if (value.startsWith('90')) {
    value = value.substring(2)
  }
  
  if (value.length > 10) {
    value = value.substring(0, 10)
  }
  
  form.phone = value
}

// İlleri yükle
const loadCities = async () => {
  loadingCities.value = true
  try {
    const data = await turkiyeAPI.getCities()
    cities.value = data.sort((a, b) => a.name.localeCompare(b.name, 'tr'))
  } catch (error) {
    console.error('Error loading cities:', error)
    const toast = useToast()
    toast.error('İller yüklenemedi. Lütfen sayfayı yenileyin.')
  } finally {
    loadingCities.value = false
  }
}

// İl değiştiğinde ilçeleri yükle
const onCityChange = async () => {
  form.district = ''
  form.neighborhood = ''
  districts.value = []
  neighborhoods.value = []
  validateField('city')
  
  if (form.city) {
    loadingDistricts.value = true
    try {
      const cityId = Number(form.city)
      console.log('Loading districts for city ID:', cityId)
      
      const data = await turkiyeAPI.getDistricts(cityId)
      console.log('Loaded districts:', data)
      
      if (data.length === 0) {
        console.warn('No districts found for city ID:', cityId)
        const toast = useToast()
        toast.warning('Bu ile ait ilçe bulunamadı.')
      } else {
        districts.value = data.sort((a, b) => a.name.localeCompare(b.name, 'tr'))
      }
    } catch (error: any) {
      console.error('Error loading districts:', error)
      const toast = useToast()
      toast.error('İlçeler yüklenemedi: ' + (error.message || 'Bilinmeyen hata'))
    } finally {
      loadingDistricts.value = false
    }
  }
}

// İlçe değiştiğinde mahalleleri yükle
const onDistrictChange = async () => {
  form.neighborhood = ''
  neighborhoods.value = []
  validateField('district')
  
  if (form.district) {
    loadingNeighborhoods.value = true
    try {
      const data = await turkiyeAPI.getNeighborhoods(Number(form.district))
      neighborhoods.value = data.sort((a, b) => a.name.localeCompare(b.name, 'tr'))
    } catch (error) {
      console.error('Error loading neighborhoods:', error)
      // Mahalleler opsiyonel olduğu için hata göstermiyoruz
    } finally {
      loadingNeighborhoods.value = false
    }
  }
}

const validateField = (field: string) => {
  errors[field as keyof typeof errors] = ''
  
  switch (field) {
    case 'galleryName':
      if (!form.galleryName.trim()) {
        errors.galleryName = 'Galeri adı gereklidir'
      } else if (form.galleryName.length < 3) {
        errors.galleryName = 'Galeri adı en az 3 karakter olmalıdır'
      }
      break
    case 'city':
      if (!form.city) {
        errors.city = 'İl seçimi gereklidir'
      }
      break
    case 'district':
      if (!form.district) {
        errors.district = 'İlçe seçimi gereklidir'
      }
      break
    case 'email':
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!form.email) {
        errors.email = 'E-posta gereklidir'
      } else if (!emailRegex.test(form.email)) {
        errors.email = 'Geçerli bir e-posta adresi girin'
      }
      break
    case 'phone':
      if (!form.phone) {
        errors.phone = 'Telefon numarası gereklidir'
      } else if (form.phone.length !== 10) {
        errors.phone = 'Telefon numarası 10 haneli olmalıdır'
      }
      break
    case 'password':
      if (!form.password) {
        errors.password = 'Şifre gereklidir'
      } else if (form.password.length < 8) {
        errors.password = 'Şifre en az 8 karakter olmalıdır'
      }
      break
    case 'passwordConfirm':
      if (!form.passwordConfirm) {
        errors.passwordConfirm = 'Şifre tekrarı gereklidir'
      } else if (form.password !== form.passwordConfirm) {
        errors.passwordConfirm = 'Şifreler eşleşmiyor'
      }
      break
  }
}

const validatePasswordStrength = () => {
  validateField('password')
}

const validateStep = (step: number): boolean => {
  let isValid = true
  
  if (step === 0) {
    validateField('galleryName')
    validateField('city')
    validateField('district')
    if (errors.galleryName || errors.city || errors.district) isValid = false
  } else if (step === 1) {
    validateField('email')
    validateField('phone')
    if (errors.email || errors.phone) isValid = false
  }
  
  return isValid
}

const nextStep = () => {
  if (validateStep(currentStep.value)) {
    if (currentStep.value < steps.length - 1) {
      currentStep.value++
    }
  }
}

const handleSubmit = async () => {
  // Validate all fields
  validateField('password')
  validateField('passwordConfirm')
  
  if (!form.terms) {
    errors.terms = 'Kullanım koşullarını kabul etmelisiniz'
    return
  }
  
  if (form.password !== form.passwordConfirm) {
    errors.passwordConfirm = 'Şifreler eşleşmiyor'
    return
  }
  
  // Check for any errors
  if (Object.values(errors).some(error => error)) {
    const toast = useToast()
    toast.error('Lütfen tüm hataları düzeltin')
    return
  }

  loading.value = true
  
  try {
    const api = useApi()
    
    // İl ve ilçe isimlerini bul
    const selectedCity = cities.value.find(c => c.id === Number(form.city))
    const selectedDistrict = districts.value.find(d => d.id === Number(form.district))
    const selectedNeighborhood = neighborhoods.value.find(n => n.id === Number(form.neighborhood))
    
    const response = await api.post('/auth/register', {
      galleryName: form.galleryName,
      city: selectedCity?.name || form.city,
      cityId: form.city,
      district: selectedDistrict?.name || form.district,
      districtId: form.district,
      neighborhood: selectedNeighborhood?.name || form.neighborhood || '',
      neighborhoodId: form.neighborhood || null,
      address: form.address,
      email: form.email,
      phone: form.phone,
      password: form.password,
      passwordConfirm: form.passwordConfirm
    })
    
    const toast = useToast()
    toast.success('Kayıt başarılı! E-posta doğrulama linki gönderildi.')
    
    navigateTo('/verify-email?email=' + encodeURIComponent(form.email))
  } catch (error: any) {
    const toast = useToast()
    const errorMessage = error.message || 'Kayıt başarısız. Lütfen tekrar deneyin.'
    
    // Set specific field errors
    if (errorMessage.toLowerCase().includes('email')) {
      errors.email = errorMessage
    } else if (errorMessage.toLowerCase().includes('phone')) {
      errors.phone = errorMessage
    } else if (errorMessage.toLowerCase().includes('gallery')) {
      errors.galleryName = errorMessage
    } else {
      toast.error(errorMessage)
    }
  } finally {
    loading.value = false
  }
}

// Sayfa yüklendiğinde illeri çek
onMounted(() => {
  loadCities()
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
