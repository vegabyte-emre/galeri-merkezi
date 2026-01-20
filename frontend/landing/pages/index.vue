<template>
  <div>
    <!-- Hero Section -->
    <HeroSection />
    
    <!-- Features Section -->
    <FeaturesSection />
    
    <!-- How It Works Section -->
    <HowItWorksSection />
    
    <!-- Stats Section -->
    <StatsSection />
    
    <!-- Oto Shorts Section -->
    <OtoShortsSection />
    
    <!-- Integrations Section -->
    <IntegrationsSection />
    
    <!-- Testimonials Section -->
    <TestimonialsSection />
    
    <!-- FAQ Section -->
    <FAQSection />
    
    <!-- CTA Section -->
    <CTASection />
  </div>
</template>

<script setup lang="ts">
import HeroSection from '~/components/HeroSection.vue'
import FeaturesSection from '~/components/FeaturesSection.vue'
import HowItWorksSection from '~/components/HowItWorksSection.vue'
import StatsSection from '~/components/StatsSection.vue'
import OtoShortsSection from '~/components/OtoShortsSection.vue'
import IntegrationsSection from '~/components/IntegrationsSection.vue'
import TestimonialsSection from '~/components/TestimonialsSection.vue'
import FAQSection from '~/components/FAQSection.vue'
import CTASection from '~/components/CTASection.vue'

useHead({
  title: 'Otobia - Oto Galerilerini Birlestiren Platform',
  meta: [
    { name: 'description', content: 'Stok yonetimi, galeriler arasi teklif/pazarlik ve pazar yerlerine otomatik ilan aktarimi ile isinizi buyutun. Oto Shorts ile araclarinizi video ile tanitin.' },
    { property: 'og:title', content: 'Otobia - Oto Galerilerini Birlestiren Platform' },
    { property: 'og:description', content: 'Stok yonetimi, galeriler arasi teklif/pazarlik ve pazar yerlerine otomatik ilan aktarimi.' },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' }
  ]
})
</script>
















