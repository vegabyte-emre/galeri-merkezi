<template>
  <section class="py-12 md:py-24 bg-gradient-to-br from-slate-900 via-violet-950 to-slate-900 relative overflow-hidden">
    <!-- Animated Background -->
    <div class="absolute inset-0">
      <div class="absolute top-1/4 left-1/4 w-[250px] md:w-[500px] h-[250px] md:h-[500px] bg-violet-600/30 rounded-full blur-[80px] md:blur-[120px] animate-pulse"></div>
      <div class="absolute bottom-1/4 right-1/4 w-[200px] md:w-[400px] h-[200px] md:h-[400px] bg-fuchsia-600/20 rounded-full blur-[60px] md:blur-[100px] animate-pulse" style="animation-delay: 1s;"></div>
    </div>

    <!-- Floating Elements - Hidden on mobile -->
    <div class="hidden md:block absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute top-20 left-[10%] w-3 h-3 bg-violet-400 rounded-full animate-float opacity-60"></div>
      <div class="absolute top-40 right-[15%] w-2 h-2 bg-fuchsia-400 rounded-full animate-float-delayed opacity-60"></div>
      <div class="absolute bottom-32 left-[20%] w-4 h-4 bg-pink-400 rounded-full animate-float opacity-40"></div>
      <div class="absolute bottom-48 right-[25%] w-2 h-2 bg-violet-300 rounded-full animate-float-delayed opacity-50"></div>
    </div>

    <div class="container-custom relative z-10 px-4">
      <div class="grid lg:grid-cols-2 gap-8 lg:gap-16 items-center">
        <!-- Content -->
        <div class="text-white text-center lg:text-left">
          <!-- Badge -->
          <div class="inline-flex items-center gap-2 px-3 py-1.5 md:px-4 md:py-2 mb-4 md:mb-6 bg-gradient-to-r from-violet-500/20 to-fuchsia-500/20 backdrop-blur-md rounded-full border border-violet-400/30">
            <Sparkles class="w-3 h-3 md:w-4 md:h-4 text-violet-400" />
            <span class="text-xs md:text-sm font-semibold bg-gradient-to-r from-violet-300 to-fuchsia-300 bg-clip-text text-transparent">Yeni Özellik</span>
          </div>

          <!-- Heading -->
          <h2 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl xl:text-6xl font-bold mb-4 md:mb-6 leading-tight">
            <span class="block text-white">Araçlarınızı</span>
            <span class="block bg-gradient-to-r from-violet-400 via-fuchsia-400 to-pink-400 bg-clip-text text-transparent">
              Oto Shorts ile Tanıtın
            </span>
          </h2>

          <p class="text-sm md:text-lg lg:text-xl text-slate-300 mb-6 md:mb-8 leading-relaxed max-w-lg mx-auto lg:mx-0">
            Kısa videolarla araçlarınızı sergileyin, daha fazla alıcıya ulaşın. 
            TikTok ve Instagram Reels tarzında video içerikler oluşturun.
          </p>

          <!-- Features List -->
          <div class="space-y-3 md:space-y-4 mb-6 md:mb-10">
            <div class="flex items-center gap-3 md:gap-4 justify-center lg:justify-start">
              <div class="w-8 h-8 md:w-10 md:h-10 rounded-lg md:rounded-xl bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center flex-shrink-0">
                <Video class="w-4 h-4 md:w-5 md:h-5 text-white" />
              </div>
              <div class="text-left">
                <h4 class="font-semibold text-white text-sm md:text-base">30 Saniye Video</h4>
                <p class="text-xs md:text-sm text-slate-400">Maksimum 30MB, yüksek kalite</p>
              </div>
            </div>

            <div class="flex items-center gap-3 md:gap-4 justify-center lg:justify-start">
              <div class="w-8 h-8 md:w-10 md:h-10 rounded-lg md:rounded-xl bg-gradient-to-br from-fuchsia-500 to-pink-500 flex items-center justify-center flex-shrink-0">
                <TrendingUp class="w-4 h-4 md:w-5 md:h-5 text-white" />
              </div>
              <div class="text-left">
                <h4 class="font-semibold text-white text-sm md:text-base">%300 Daha Fazla Görüş</h4>
                <p class="text-xs md:text-sm text-slate-400">Video içeriklerde etkileşim 3 kat fazla</p>
              </div>
            </div>

            <div class="flex items-center gap-3 md:gap-4 justify-center lg:justify-start">
              <div class="w-8 h-8 md:w-10 md:h-10 rounded-lg md:rounded-xl bg-gradient-to-br from-pink-500 to-rose-500 flex items-center justify-center flex-shrink-0">
                <Zap class="w-4 h-4 md:w-5 md:h-5 text-white" />
              </div>
              <div class="text-left">
                <h4 class="font-semibold text-white text-sm md:text-base">Otomatik Yayınlama</h4>
                <p class="text-xs md:text-sm text-slate-400">Araç eklerken video yükle, hemen yayınla</p>
              </div>
            </div>
          </div>

          <!-- CTA -->
          <NuxtLink 
            to="/register" 
            class="inline-flex items-center gap-2 md:gap-3 px-5 py-3 md:px-8 md:py-4 bg-gradient-to-r from-violet-500 to-fuchsia-500 text-white text-sm md:text-base font-bold rounded-xl shadow-2xl shadow-violet-500/30 hover:shadow-violet-500/50 transition-all duration-300 hover:scale-105 group"
          >
            <Play class="w-4 h-4 md:w-5 md:h-5" />
            Hemen Deneyin
            <ArrowRight class="w-4 h-4 md:w-5 md:h-5 group-hover:translate-x-1 transition-transform" />
          </NuxtLink>
        </div>

        <!-- Phone Mockup - Smaller on mobile -->
        <div class="relative flex justify-center lg:justify-end mt-8 lg:mt-0">
          <div class="relative scale-[0.85] sm:scale-100">
            <!-- Glow Effect -->
            <div class="absolute -inset-4 bg-gradient-to-r from-violet-500 via-fuchsia-500 to-pink-500 rounded-[2.5rem] md:rounded-[3rem] blur-xl md:blur-2xl opacity-30 animate-pulse"></div>
            
            <!-- Phone Frame -->
            <div class="relative w-52 sm:w-60 md:w-72 h-[420px] sm:h-[480px] md:h-[560px] bg-slate-900 rounded-[2rem] sm:rounded-[2.5rem] md:rounded-[3rem] border-4 border-slate-700 shadow-2xl overflow-hidden">
              <!-- Notch -->
              <div class="absolute top-0 left-1/2 -translate-x-1/2 w-20 sm:w-24 md:w-28 h-5 sm:h-6 bg-slate-900 rounded-b-xl z-20"></div>
              
              <!-- Screen Content -->
              <div class="absolute inset-1.5 sm:inset-2 rounded-[1.5rem] sm:rounded-[2rem] overflow-hidden bg-gradient-to-b from-slate-800 to-slate-900">
                <!-- Video Placeholder -->
                <div class="h-full w-full relative flex flex-col">
                  <!-- Car Image Area - Takes most of the space -->
                  <div class="flex-1 bg-gradient-to-b from-violet-900/50 to-slate-900 flex items-center justify-center">
                    <div class="text-center px-3">
                      <Car class="w-12 sm:w-16 md:w-20 h-12 sm:h-16 md:h-20 text-violet-400 mx-auto mb-2 sm:mb-3 animate-bounce" />
                      <div class="text-white font-bold text-sm sm:text-base md:text-lg">2024 BMW 320i</div>
                      <div class="text-violet-300 text-xs sm:text-sm">850.000 ₺</div>
                    </div>
                  </div>

                  <!-- Video Controls Overlay - Fixed at bottom -->
                  <div class="bg-gradient-to-t from-black/90 via-black/70 to-transparent p-2.5 sm:p-3 md:p-4">
                    <!-- Progress Bar -->
                    <div class="w-full h-0.5 sm:h-1 bg-white/30 rounded-full mb-2 sm:mb-3 overflow-hidden">
                      <div class="w-3/4 h-full bg-gradient-to-r from-violet-500 to-fuchsia-500 rounded-full animate-progress"></div>
                    </div>
                    
                    <!-- User Info -->
                    <div class="flex items-center gap-2 mb-1.5 sm:mb-2">
                      <div class="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 rounded-full bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center text-white font-bold text-[10px] sm:text-xs flex-shrink-0">
                        OT
                      </div>
                      <div class="min-w-0">
                        <div class="text-white font-semibold text-[10px] sm:text-xs truncate">Otobia</div>
                        <div class="text-white/60 text-[8px] sm:text-[10px] truncate">İstanbul, Türkiye</div>
                      </div>
                    </div>

                    <!-- Description -->
                    <p class="text-white/80 text-[10px] sm:text-xs mb-2 sm:mb-3 line-clamp-2">
                      2024 Model BMW 320i 🚗 Full donanımlı! #otoshorts
                    </p>

                    <!-- Action Buttons Row -->
                    <div class="flex items-center gap-2 sm:gap-3 mb-2 sm:mb-3">
                      <button class="flex items-center gap-0.5 sm:gap-1 text-white hover:text-pink-400 transition-colors">
                        <Heart class="w-4 h-4 sm:w-5 sm:h-5" />
                        <span class="text-[10px] sm:text-xs">2.4K</span>
                      </button>
                      <button class="flex items-center gap-0.5 sm:gap-1 text-white hover:text-blue-400 transition-colors">
                        <MessageCircle class="w-4 h-4 sm:w-5 sm:h-5" />
                        <span class="text-[10px] sm:text-xs">128</span>
                      </button>
                      <button class="flex items-center gap-0.5 text-white hover:text-green-400 transition-colors">
                        <Share2 class="w-4 h-4 sm:w-5 sm:h-5" />
                      </button>
                    </div>

                    <!-- Teklif Ver Button - Full Width, Prominent -->
                    <button class="w-full py-2 sm:py-2.5 bg-gradient-to-r from-violet-500 via-fuchsia-500 to-pink-500 text-white text-xs sm:text-sm font-bold rounded-lg sm:rounded-xl shadow-lg shadow-fuchsia-500/30 hover:shadow-fuchsia-500/50 hover:scale-[1.02] transition-all duration-300 flex items-center justify-center gap-1.5 sm:gap-2">
                      <Send class="w-3 h-3 sm:w-4 sm:h-4" />
                      Teklif Ver
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Floating Stats - Hidden on very small screens -->
            <div class="hidden sm:block absolute -right-4 sm:-right-6 md:-right-8 top-12 sm:top-16 bg-white/10 backdrop-blur-md rounded-lg sm:rounded-xl p-2 sm:p-3 border border-white/20 animate-float">
              <div class="flex items-center gap-2">
                <div class="w-6 h-6 sm:w-8 sm:h-8 rounded-lg bg-gradient-to-br from-green-400 to-emerald-500 flex items-center justify-center">
                  <Eye class="w-3 h-3 sm:w-4 sm:h-4 text-white" />
                </div>
                <div>
                  <div class="text-white font-bold text-xs sm:text-sm">12.5K</div>
                  <div class="text-white/60 text-[8px] sm:text-[10px]">Görüntülenme</div>
                </div>
              </div>
            </div>

            <div class="hidden sm:block absolute -left-4 sm:-left-6 md:-left-8 bottom-20 sm:bottom-24 bg-white/10 backdrop-blur-md rounded-lg sm:rounded-xl p-2 sm:p-3 border border-white/20 animate-float-delayed">
              <div class="flex items-center gap-2">
                <div class="w-6 h-6 sm:w-8 sm:h-8 rounded-lg bg-gradient-to-br from-rose-400 to-pink-500 flex items-center justify-center">
                  <Heart class="w-3 h-3 sm:w-4 sm:h-4 text-white fill-white" />
                </div>
                <div>
                  <div class="text-white font-bold text-xs sm:text-sm">3.2K</div>
                  <div class="text-white/60 text-[8px] sm:text-[10px]">Beğeni</div>
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
