<template>
  <section class="py-24 bg-gradient-to-br from-slate-900 via-violet-950 to-slate-900 relative overflow-hidden">
    <!-- Animated Background -->
    <div class="absolute inset-0">
      <div class="absolute top-1/4 left-1/4 w-[500px] h-[500px] bg-violet-600/30 rounded-full blur-[120px] animate-pulse"></div>
      <div class="absolute bottom-1/4 right-1/4 w-[400px] h-[400px] bg-fuchsia-600/20 rounded-full blur-[100px] animate-pulse" style="animation-delay: 1s;"></div>
    </div>

    <!-- Floating Elements -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute top-20 left-[10%] w-3 h-3 bg-violet-400 rounded-full animate-float opacity-60"></div>
      <div class="absolute top-40 right-[15%] w-2 h-2 bg-fuchsia-400 rounded-full animate-float-delayed opacity-60"></div>
      <div class="absolute bottom-32 left-[20%] w-4 h-4 bg-pink-400 rounded-full animate-float opacity-40"></div>
      <div class="absolute bottom-48 right-[25%] w-2 h-2 bg-violet-300 rounded-full animate-float-delayed opacity-50"></div>
    </div>

    <div class="container-custom relative z-10">
      <div class="grid lg:grid-cols-2 gap-16 items-center">
        <!-- Content -->
        <div class="text-white">
          <!-- Badge -->
          <div class="inline-flex items-center gap-2 px-4 py-2 mb-6 bg-gradient-to-r from-violet-500/20 to-fuchsia-500/20 backdrop-blur-md rounded-full border border-violet-400/30">
            <Sparkles class="w-4 h-4 text-violet-400" />
            <span class="text-sm font-semibold bg-gradient-to-r from-violet-300 to-fuchsia-300 bg-clip-text text-transparent">Yeni Özellik</span>
          </div>

          <!-- Heading -->
          <h2 class="text-4xl md:text-5xl lg:text-6xl font-bold mb-6 leading-tight">
            <span class="block text-white">Araçlarınızı</span>
            <span class="block bg-gradient-to-r from-violet-400 via-fuchsia-400 to-pink-400 bg-clip-text text-transparent">
              Oto Shorts ile Tanıtın
            </span>
          </h2>

          <p class="text-xl text-slate-300 mb-8 leading-relaxed max-w-lg">
            Kısa videolarla araçlarınızı sergileyin, daha fazla alıcıya ulaşın. 
            TikTok ve Instagram Reels tarzında video içerikler oluşturun.
          </p>

          <!-- Features List -->
          <div class="space-y-4 mb-10">
            <div class="flex items-center gap-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center">
                <Video class="w-5 h-5 text-white" />
              </div>
              <div>
                <h4 class="font-semibold text-white">30 Saniye Video</h4>
                <p class="text-sm text-slate-400">Maksimum 30MB, yüksek kalite</p>
              </div>
            </div>

            <div class="flex items-center gap-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-fuchsia-500 to-pink-500 flex items-center justify-center">
                <TrendingUp class="w-5 h-5 text-white" />
              </div>
              <div>
                <h4 class="font-semibold text-white">%300 Daha Fazla Görüş</h4>
                <p class="text-sm text-slate-400">Video içeriklerde etkileşim 3 kat fazla</p>
              </div>
            </div>

            <div class="flex items-center gap-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-pink-500 to-rose-500 flex items-center justify-center">
                <Zap class="w-5 h-5 text-white" />
              </div>
              <div>
                <h4 class="font-semibold text-white">Otomatik Yayınlama</h4>
                <p class="text-sm text-slate-400">Araç eklerken video yükle, hemen yayınla</p>
              </div>
            </div>
          </div>

          <!-- CTA -->
          <NuxtLink 
            to="/register" 
            class="inline-flex items-center gap-3 px-8 py-4 bg-gradient-to-r from-violet-500 to-fuchsia-500 text-white font-bold rounded-xl shadow-2xl shadow-violet-500/30 hover:shadow-violet-500/50 transition-all duration-300 hover:scale-105 group"
          >
            <Play class="w-5 h-5" />
            Hemen Deneyin
            <ArrowRight class="w-5 h-5 group-hover:translate-x-1 transition-transform" />
          </NuxtLink>
        </div>

        <!-- Phone Mockup -->
        <div class="relative flex justify-center lg:justify-end mt-12 lg:mt-0">
          <div class="relative">
            <!-- Glow Effect -->
            <div class="absolute -inset-4 bg-gradient-to-r from-violet-500 via-fuchsia-500 to-pink-500 rounded-[3rem] blur-2xl opacity-30 animate-pulse"></div>
            
            <!-- Phone Frame -->
            <div class="relative w-64 sm:w-72 md:w-80 h-[520px] sm:h-[580px] md:h-[640px] bg-slate-900 rounded-[2.5rem] sm:rounded-[3rem] border-4 border-slate-700 shadow-2xl overflow-hidden">
              <!-- Notch -->
              <div class="absolute top-0 left-1/2 -translate-x-1/2 w-24 sm:w-32 h-6 sm:h-7 bg-slate-900 rounded-b-2xl z-20"></div>
              
              <!-- Screen Content -->
              <div class="absolute inset-2 rounded-[2rem] sm:rounded-[2.5rem] overflow-hidden bg-gradient-to-b from-slate-800 to-slate-900">
                <!-- Video Placeholder -->
                <div class="h-full w-full relative flex flex-col">
                  <!-- Car Image Area - Takes most of the space -->
                  <div class="flex-1 bg-gradient-to-b from-violet-900/50 to-slate-900 flex items-center justify-center">
                    <div class="text-center px-4">
                      <Car class="w-16 sm:w-20 h-16 sm:h-20 text-violet-400 mx-auto mb-3 sm:mb-4 animate-bounce" />
                      <div class="text-white font-bold text-base sm:text-lg">2024 BMW 320i</div>
                      <div class="text-violet-300 text-sm">850.000 ₺</div>
                    </div>
                  </div>

                  <!-- Video Controls Overlay - Fixed at bottom -->
                  <div class="bg-gradient-to-t from-black/90 via-black/70 to-transparent p-3 sm:p-4">
                    <!-- Progress Bar -->
                    <div class="w-full h-1 bg-white/30 rounded-full mb-3 overflow-hidden">
                      <div class="w-3/4 h-full bg-gradient-to-r from-violet-500 to-fuchsia-500 rounded-full animate-progress"></div>
                    </div>
                    
                    <!-- User Info -->
                    <div class="flex items-center gap-2 sm:gap-3 mb-2">
                      <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center text-white font-bold text-xs sm:text-sm flex-shrink-0">
                        OT
                      </div>
                      <div class="min-w-0">
                        <div class="text-white font-semibold text-xs sm:text-sm truncate">Otobia</div>
                        <div class="text-white/60 text-[10px] sm:text-xs truncate">İstanbul, Türkiye</div>
                      </div>
                    </div>

                    <!-- Description -->
                    <p class="text-white/80 text-xs sm:text-sm mb-3 line-clamp-2">
                      2024 Model BMW 320i 🚗 Sıfır araç, full donanımlı! #otoshorts #bmw #istanbul
                    </p>

                    <!-- Action Buttons Row -->
                    <div class="flex items-center gap-3 sm:gap-4 mb-3">
                      <button class="flex items-center gap-1 text-white hover:text-pink-400 transition-colors">
                        <Heart class="w-5 h-5 sm:w-6 sm:h-6" />
                        <span class="text-xs sm:text-sm">2.4K</span>
                      </button>
                      <button class="flex items-center gap-1 text-white hover:text-blue-400 transition-colors">
                        <MessageCircle class="w-5 h-5 sm:w-6 sm:h-6" />
                        <span class="text-xs sm:text-sm">128</span>
                      </button>
                      <button class="flex items-center gap-1 text-white hover:text-green-400 transition-colors">
                        <Share2 class="w-5 h-5 sm:w-6 sm:h-6" />
                      </button>
                    </div>

                    <!-- Teklif Ver Button - Full Width, Prominent -->
                    <button class="w-full py-2.5 sm:py-3 bg-gradient-to-r from-violet-500 via-fuchsia-500 to-pink-500 text-white text-sm sm:text-base font-bold rounded-xl shadow-lg shadow-fuchsia-500/30 hover:shadow-fuchsia-500/50 hover:scale-[1.02] transition-all duration-300 flex items-center justify-center gap-2">
                      <Send class="w-4 h-4 sm:w-5 sm:h-5" />
                      Teklif Ver
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Floating Stats - Responsive positioning -->
            <div class="absolute -right-2 sm:-right-6 md:-right-10 top-16 sm:top-20 bg-white/10 backdrop-blur-md rounded-xl sm:rounded-2xl p-2.5 sm:p-4 border border-white/20 animate-float">
              <div class="flex items-center gap-2 sm:gap-3">
                <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-lg sm:rounded-xl bg-gradient-to-br from-green-400 to-emerald-500 flex items-center justify-center">
                  <Eye class="w-4 h-4 sm:w-5 sm:h-5 text-white" />
                </div>
                <div>
                  <div class="text-white font-bold text-sm sm:text-base">12.5K</div>
                  <div class="text-white/60 text-[10px] sm:text-xs">Görüntülenme</div>
                </div>
              </div>
            </div>

            <div class="absolute -left-2 sm:-left-6 md:-left-10 bottom-24 sm:bottom-32 bg-white/10 backdrop-blur-md rounded-xl sm:rounded-2xl p-2.5 sm:p-4 border border-white/20 animate-float-delayed">
              <div class="flex items-center gap-2 sm:gap-3">
                <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-lg sm:rounded-xl bg-gradient-to-br from-rose-400 to-pink-500 flex items-center justify-center">
                  <Heart class="w-4 h-4 sm:w-5 sm:h-5 text-white fill-white" />
                </div>
                <div>
                  <div class="text-white font-bold text-sm sm:text-base">3.2K</div>
                  <div class="text-white/60 text-[10px] sm:text-xs">Beğeni</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { 
  Sparkles, Video, TrendingUp, Zap, Play, ArrowRight, 
  Car, Heart, MessageCircle, Share2, Eye, Send 
} from 'lucide-vue-next'
</script>

<style scoped>
@keyframes float {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-20px);
  }
}

@keyframes float-delayed {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-15px);
  }
}

@keyframes progress {
  0% {
    width: 0%;
  }
  100% {
    width: 75%;
  }
}

.animate-float {
  animation: float 4s ease-in-out infinite;
}

.animate-float-delayed {
  animation: float-delayed 5s ease-in-out infinite;
  animation-delay: 1s;
}

.animate-progress {
  animation: progress 3s ease-out infinite;
}
</style>
