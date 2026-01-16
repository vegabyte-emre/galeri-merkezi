<template>
  <div class="py-12">
    <div class="container-custom max-w-4xl">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
          Çerez Politikası
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-400">
          Son güncelleme: {{ lastUpdated }}
        </p>
      </div>

      <!-- Content -->
      <div class="prose prose-lg dark:prose-invert max-w-none">
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-8 space-y-6">
          <section>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">1. Çerezler Nedir?</h2>
            <p class="text-gray-700 dark:text-gray-300 leading-relaxed">
              Çerezler, web sitelerini ziyaret ettiğinizde cihazınıza (bilgisayar, tablet veya mobil cihaz) kaydedilen küçük metin dosyalarıdır. Bu dosyalar, web sitesinin düzgün çalışmasını sağlar ve kullanıcı deneyimini iyileştirir.
            </p>
          </section>

          <section>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">2. Hangi Çerezleri Kullanıyoruz?</h2>
            <div class="space-y-4">
              <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
                <h3 class="font-semibold text-gray-900 dark:text-white mb-2">Zorunlu Çerezler</h3>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Web sitesinin temel işlevlerini yerine getirmesi için gerekli çerezlerdir. Bu çerezler olmadan site düzgün çalışmaz.
                </p>
              </div>
              <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
                <h3 class="font-semibold text-gray-900 dark:text-white mb-2">Performans Çerezleri</h3>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Site performansını analiz etmek ve kullanıcı deneyimini iyileştirmek için kullanılır.
                </p>
              </div>
              <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
                <h3 class="font-semibold text-gray-900 dark:text-white mb-2">İşlevsellik Çerezleri</h3>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Tercihlerinizi hatırlamak ve kişiselleştirilmiş bir deneyim sunmak için kullanılır.
                </p>
              </div>
              <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
                <h3 class="font-semibold text-gray-900 dark:text-white mb-2">Hedefleme Çerezleri</h3>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  İlgi alanlarınıza göre reklamlar göstermek için kullanılır.
                </p>
              </div>
            </div>
          </section>

          <section>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">3. Çerezleri Nasıl Yönetebilirsiniz?</h2>
            <p class="text-gray-700 dark:text-gray-300 leading-relaxed mb-4">
              Tarayıcı ayarlarınızdan çerezleri yönetebilir, silebilir veya engelleyebilirsiniz. Ancak bazı çerezleri engellemek, web sitesinin bazı özelliklerinin çalışmamasına neden olabilir.
            </p>
            <div class="p-4 bg-primary-50 dark:bg-primary-900/20 rounded-lg border border-primary-200 dark:border-primary-800">
              <p class="text-sm text-primary-800 dark:text-primary-200">
                <strong>Not:</strong> Çerez tercihlerinizi değiştirmek için tarayıcınızın ayarlar menüsünü kullanabilirsiniz.
              </p>
            </div>
          </section>

          <section>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">4. Üçüncü Taraf Çerezler</h2>
            <p class="text-gray-700 dark:text-gray-300 leading-relaxed">
              Web sitemizde, analitik ve reklam hizmetleri sağlayan üçüncü taraf hizmetlerin çerezleri de kullanılabilir. Bu çerezlerin kullanımı, ilgili üçüncü tarafın gizlilik politikasına tabidir.
            </p>
          </section>

          <section>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">5. İletişim</h2>
            <p class="text-gray-700 dark:text-gray-300 leading-relaxed">
              Çerez politikamız hakkında sorularınız için lütfen bizimle <NuxtLink to="/contact" class="text-primary-600 dark:text-primary-400 hover:underline">iletişime geçin</NuxtLink>.
            </p>
          </section>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
useHead({
  title: 'Çerez Politikası - Galeri Merkezi'
})

const lastUpdated = '1 Ocak 2024'
</script>














