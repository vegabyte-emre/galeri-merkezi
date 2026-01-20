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
            <span class="text-sm font-semibold bg-gradient-to-r from-violet-300 to-fuchsia-300 bg-clip-text text-transparent">Yeni Ozellik</span>
          </div>

          <!-- Heading -->
          <h2 class="text-4xl md:text-5xl lg:text-6xl font-bold mb-6 leading-tight">
            <span class="block text-white">Araclarinizi</span>
            <span class="block bg-gradient-to-r from-violet-400 via-fuchsia-400 to-pink-400 bg-clip-text text-transparent">
              Oto Shorts ile Tanitin
            </span>
          </h2>

          <p class="text-xl text-slate-300 mb-8 leading-relaxed max-w-lg">
            Kisa videolarla araclarinizi sergileyin, daha fazla aliciya ulasin. 
            TikTok ve Instagram Reels tarzinda video icerikler olusturun.
          </p>

          <!-- Features List -->
          <div class="space-y-4 mb-10">
            <div class="flex items-center gap-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center">
                <Video class="w-5 h-5 text-white" />
              </div>
              <div>
                <h4 class="font-semibold text-white">30 Saniye Video</h4>
                <p class="text-sm text-slate-400">Maksimum 30MB, yuksek kalite</p>
              </div>
            </div>

            <div class="flex items-center gap-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-fuchsia-500 to-pink-500 flex items-center justify-center">
                <TrendingUp class="w-5 h-5 text-white" />
              </div>
              <div>
                <h4 class="font-semibold text-white">%300 Daha Fazla Gorus</h4>
                <p class="text-sm text-slate-400">Video iceriklerde etkilesim 3 kat fazla</p>
              </div>
            </div>

            <div class="flex items-center gap-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-pink-500 to-rose-500 flex items-center justify-center">
                <Zap class="w-5 h-5 text-white" />
              </div>
              <div>
                <h4 class="font-semibold text-white">Otomatik Yayinlama</h4>
                <p class="text-sm text-slate-400">Arac eklerken video yukle, hemen yayinla</p>
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
        <div class="relative flex justify-center lg:justify-end">
          <div class="relative">
            <!-- Glow Effect -->
            <div class="absolute -inset-4 bg-gradient-to-r from-violet-500 via-fuchsia-500 to-pink-500 rounded-[3rem] blur-2xl opacity-30 animate-pulse"></div>
            
            <!-- Phone Frame -->
            <div class="relative w-72 h-[580px] bg-slate-900 rounded-[3rem] border-4 border-slate-700 shadow-2xl overflow-hidden">
              <!-- Notch -->
              <div class="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-7 bg-slate-900 rounded-b-2xl z-20"></div>
              
              <!-- Screen Content -->
              <div class="absolute inset-2 rounded-[2.5rem] overflow-hidden bg-gradient-to-b from-slate-800 to-slate-900">
                <!-- Video Placeholder -->
                <div class="h-full w-full relative">
                  <!-- Car Image Placeholder -->
                  <div class="absolute inset-0 bg-gradient-to-b from-violet-900/50 to-slate-900 flex items-center justify-center">
                    <div class="text-center">
                      <Car class="w-20 h-20 text-violet-400 mx-auto mb-4 animate-bounce" />
                      <div class="text-white font-bold text-lg">2024 BMW 320i</div>
                      <div class="text-violet-300 text-sm">850.000 TL</div>
                    </div>
                  </div>

                  <!-- Video Controls Overlay -->
                  <div class="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black/80 to-transparent">
                    <!-- Progress Bar -->
                    <div class="w-full h-1 bg-white/30 rounded-full mb-4 overflow-hidden">
                      <div class="w-3/4 h-full bg-gradient-to-r from-violet-500 to-fuchsia-500 rounded-full animate-progress"></div>
                    </div>
                    
                    <!-- User Info -->
                    <div class="flex items-center gap-3 mb-3">
                      <div class="w-10 h-10 rounded-full bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center text-white font-bold text-sm">
                        GM
                      </div>
                      <div>
                        <div class="text-white font-semibold text-sm">Otobia</div>
                        <div class="text-white/60 text-xs">Istanbul, Turkiye</div>
                      </div>
                    </div>

                    <!-- Description -->
                    <p class="text-white/80 text-sm mb-4">
                      2024 Model BMW 320i 🚗 Sifir arac, full donanimli! #otoshorts #bmw #istanbul
                    </p>

                    <!-- Action Buttons -->
                    <div class="flex items-center justify-between">
                      <div class="flex items-center gap-4">
                        <button class="flex items-center gap-1 text-white">
                          <Heart class="w-6 h-6" />
                          <span class="text-sm">2.4K</span>
                        </button>
                        <button class="flex items-center gap-1 text-white">
                          <MessageCircle class="w-6 h-6" />
                          <span class="text-sm">128</span>
                        </button>
                        <button class="flex items-center gap-1 text-white">
                          <Share2 class="w-6 h-6" />
                        </button>
                      </div>
                      <button class="px-4 py-2 bg-gradient-to-r from-violet-500 to-fuchsia-500 text-white text-sm font-semibold rounded-full">
                        Teklif Ver
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Floating Stats -->
            <div class="absolute -right-8 top-20 bg-white/10 backdrop-blur-md rounded-2xl p-4 border border-white/20 animate-float">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-green-400 to-emerald-500 flex items-center justify-center">
                  <Eye class="w-5 h-5 text-white" />
                </div>
                <div>
                  <div class="text-white font-bold">12.5K</div>
                  <div class="text-white/60 text-xs">Goruntulenme</div>
                </div>
              </div>
            </div>

            <div class="absolute -left-8 bottom-32 bg-white/10 backdrop-blur-md rounded-2xl p-4 border border-white/20 animate-float-delayed">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-rose-400 to-pink-500 flex items-center justify-center">
                  <Heart class="w-5 h-5 text-white fill-white" />
                </div>
                <div>
                  <div class="text-white font-bold">3.2K</div>
                  <div class="text-white/60 text-xs">Begeni</div>
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
  Car, Heart, MessageCircle, Share2, Eye 
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
