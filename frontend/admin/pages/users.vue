<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Kullanıcılar</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Tüm kullanıcıları görüntüleyin ve yönetin</p>
      </div>
      <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
        <div class="flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-800 rounded-lg">
          <Search class="w-4 h-4 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Kullanıcı ara..."
            class="bg-transparent border-0 outline-0 text-sm text-gray-700 dark:text-gray-300 placeholder-gray-400 w-full sm:w-64"
          />
        </div>
        <button 
          @click="openCreateModal"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all flex items-center justify-center gap-2"
        >
          <Plus class="w-4 h-4" />
          Yeni Kullanıcı
        </button>
      </div>
    </div>

    <!-- Users Table -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Kullanıcı</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider hidden md:table-cell">Telefon</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Rol</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider hidden lg:table-cell">Galeri</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Durum</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">İşlemler</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="user in filteredUsers"
              :key="user.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold flex-shrink-0">
                    {{ user.name?.charAt(0) || '?' }}
                  </div>
                  <div class="min-w-0">
                    <div class="font-medium text-gray-900 dark:text-white truncate">{{ user.name }}</div>
                    <div class="text-sm text-gray-500 dark:text-gray-400 truncate">{{ user.email }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300 hidden md:table-cell">
                {{ user.phone || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="getRoleBadgeClass(user.role)"
                >
                  {{ roleLabels[user.role] || user.role }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white hidden lg:table-cell">
                {{ user.gallery || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': user.status === 'active',
                    'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400': user.status === 'suspended',
                    'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400': user.status === 'inactive'
                  }"
                >
                  {{ statusLabels[user.status] || user.status }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex items-center justify-end gap-2">
                  <button
                    @click="openEditModal(user)"
                    class="px-3 py-1.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-xs font-semibold"
                  >
                    Düzenle
                  </button>
                  <button
                    @click="deleteUser(user.id)"
                    class="px-3 py-1.5 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors text-xs font-semibold"
                  >
                    Sil
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="filteredUsers.length === 0">
              <td colspan="6" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">
                {{ loading ? 'Yükleniyor...' : 'Kullanıcı bulunamadı' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Create User Modal -->
    <Teleport to="body">
      <div
        v-if="showCreateModal"
        class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 overflow-y-auto"
        @click.self="closeCreateModal"
      >
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl w-full max-w-3xl my-8">
          <!-- Modal Header -->
          <div class="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
            <div>
              <h3 class="text-xl font-bold text-gray-900 dark:text-white">Yeni Kullanıcı Ekle</h3>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Sisteme yeni bir kullanıcı ekleyin</p>
            </div>
            <button @click="closeCreateModal" class="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors">
              <X class="w-5 h-5 text-gray-500" />
            </button>
          </div>

          <!-- Modal Body -->
          <div class="p-6">
            <!-- Temel Bilgiler -->
            <div class="mb-6">
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <User class="w-4 h-4" />
                Temel Bilgiler
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Ad Soyad <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="formData.name"
                    type="text"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="Örn: Ahmet Yılmaz"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    E-posta <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="formData.email"
                    type="email"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="ornek@email.com"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Telefon <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="formData.phone"
                    type="tel"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="05XX XXX XX XX"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Şifre <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="formData.password"
                    type="password"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="En az 8 karakter"
                  />
                  <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">En az 8 karakter, 1 büyük ve 1 küçük harf içermeli</p>
                </div>
              </div>
            </div>

            <!-- Rol Seçimi -->
            <div class="mb-6">
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <Shield class="w-4 h-4" />
                Rol ve Yetki
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Kullanıcı Rolü <span class="text-red-500">*</span>
                  </label>
                  <select
                    v-model="formData.role"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                  >
                    <option value="superadmin">Süper Admin</option>
                    <option value="admin">Admin</option>
                    <option value="compliance_officer">Uyum Sorumlusu</option>
                    <option value="support_agent">Destek Temsilcisi</option>
                    <option value="gallery_owner">Galeri Sahibi</option>
                    <option value="gallery_manager">Galeri Yöneticisi</option>
                    <option value="inventory_manager">Envanter Yöneticisi</option>
                  </select>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Durum
                  </label>
                  <select
                    v-model="formData.status"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                  >
                    <option value="active">Aktif</option>
                    <option value="suspended">Askıya Alınmış</option>
                  </select>
                </div>
              </div>
            </div>

            <!-- Galeri Bilgileri - Sadece Galeri Sahibi için -->
            <div v-if="formData.role === 'gallery_owner'" class="border-t border-gray-200 dark:border-gray-700 pt-6">
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <Building class="w-4 h-4" />
                Galeri Bilgileri
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="md:col-span-2">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Galeri Adı <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="formData.galleryName"
                    type="text"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="Örn: ABC Otomotiv"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Vergi Türü <span class="text-red-500">*</span>
                  </label>
                  <select
                    v-model="formData.taxType"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                  >
                    <option value="VKN">VKN (Vergi Kimlik No - Şirket)</option>
                    <option value="TCKN">TCKN (TC Kimlik No - Şahıs)</option>
                  </select>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    {{ formData.taxType === 'TCKN' ? 'TC Kimlik No' : 'Vergi Kimlik No' }} <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="formData.taxNumber"
                    type="text"
                    :maxlength="formData.taxType === 'TCKN' ? 11 : 10"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    :placeholder="formData.taxType === 'TCKN' ? '11 haneli TC Kimlik No' : '10 haneli Vergi Kimlik No'"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    İl <span class="text-red-500">*</span>
                  </label>
                  <select
                    v-model="formData.city"
                    @change="loadDistricts"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                  >
                    <option value="">İl Seçin</option>
                    <option v-for="city in cities" :key="city.id" :value="city.name">{{ city.name }}</option>
                  </select>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    İlçe <span class="text-red-500">*</span>
                  </label>
                  <select
                    v-model="formData.district"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    :disabled="!formData.city"
                  >
                    <option value="">İlçe Seçin</option>
                    <option v-for="district in districts" :key="district.id" :value="district.name">{{ district.name }}</option>
                  </select>
                </div>
                <div class="md:col-span-2">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Açık Adres <span class="text-red-500">*</span>
                  </label>
                  <textarea
                    v-model="formData.address"
                    rows="2"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="Mahalle, Sokak, Bina No..."
                  ></textarea>
                </div>
              </div>
            </div>
          </div>

          <!-- Modal Footer -->
          <div class="flex items-center justify-end gap-3 p-6 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800/50 rounded-b-2xl">
            <button
              @click="closeCreateModal"
              class="px-5 py-2.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-medium"
            >
              İptal
            </button>
            <button
              @click="createUser"
              :disabled="formLoading"
              class="px-5 py-2.5 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
            >
              <Loader2 v-if="formLoading" class="w-4 h-4 animate-spin" />
              {{ formLoading ? 'Oluşturuluyor...' : 'Kullanıcı Oluştur' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Edit User Modal -->
    <Teleport to="body">
      <div
        v-if="showEditModal"
        class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 overflow-y-auto"
        @click.self="closeEditModal"
      >
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl w-full max-w-3xl my-8">
          <!-- Modal Header -->
          <div class="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
            <div>
              <h3 class="text-xl font-bold text-gray-900 dark:text-white">Kullanıcı Düzenle</h3>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Kullanıcı bilgilerini güncelleyin</p>
            </div>
            <button @click="closeEditModal" class="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors">
              <X class="w-5 h-5 text-gray-500" />
            </button>
          </div>

          <!-- Modal Body -->
          <div class="p-6">
            <!-- Temel Bilgiler -->
            <div class="mb-6">
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <User class="w-4 h-4" />
                Temel Bilgiler
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Ad Soyad <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="editFormData.name"
                    type="text"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="Örn: Ahmet Yılmaz"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    E-posta <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="editFormData.email"
                    type="email"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="ornek@email.com"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Telefon <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="editFormData.phone"
                    type="tel"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="05XX XXX XX XX"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Yeni Şifre <span class="text-gray-400 text-xs">(opsiyonel)</span>
                  </label>
                  <input
                    v-model="editFormData.password"
                    type="password"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="Değiştirmek için doldurun"
                  />
                </div>
              </div>
            </div>

            <!-- Rol ve Durum -->
            <div class="mb-6">
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <Shield class="w-4 h-4" />
                Rol ve Durum
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Kullanıcı Rolü
                  </label>
                  <select
                    v-model="editFormData.role"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                  >
                    <option value="superadmin">Süper Admin</option>
                    <option value="admin">Admin</option>
                    <option value="compliance_officer">Uyum Sorumlusu</option>
                    <option value="support_agent">Destek Temsilcisi</option>
                    <option value="gallery_owner">Galeri Sahibi</option>
                    <option value="gallery_manager">Galeri Yöneticisi</option>
                    <option value="inventory_manager">Envanter Yöneticisi</option>
                  </select>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Durum
                  </label>
                  <select
                    v-model="editFormData.status"
                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                  >
                    <option value="active">Aktif</option>
                    <option value="suspended">Askıya Alınmış</option>
                  </select>
                </div>
              </div>
            </div>

            <!-- Galeri Bilgisi -->
            <div v-if="editFormData.gallery" class="border-t border-gray-200 dark:border-gray-700 pt-6">
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <Building class="w-4 h-4" />
                Bağlı Galeri
              </h4>
              <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
                <p class="text-sm text-gray-700 dark:text-gray-300">
                  <span class="font-medium">{{ editFormData.gallery }}</span>
                </p>
              </div>
            </div>
          </div>

          <!-- Modal Footer -->
          <div class="flex items-center justify-end gap-3 p-6 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800/50 rounded-b-2xl">
            <button
              @click="closeEditModal"
              class="px-5 py-2.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors font-medium"
            >
              İptal
            </button>
            <button
              @click="saveEditUser"
              :disabled="formLoading"
              class="px-5 py-2.5 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
            >
              <Loader2 v-if="formLoading" class="w-4 h-4 animate-spin" />
              {{ formLoading ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { Search, Plus, X, User, Shield, Building, Loader2 } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()

// State
const loading = ref(false)
const formLoading = ref(false)
const searchQuery = ref('')
const showCreateModal = ref(false)
const showEditModal = ref(false)
const users = ref<any[]>([])

// Form data for create
const formData = ref({
  name: '',
  email: '',
  phone: '',
  password: '',
  role: 'gallery_owner',
  status: 'active',
  galleryName: '',
  taxType: 'VKN',
  taxNumber: '',
  city: '',
  district: '',
  address: ''
})

// Cities and districts
const cities = ref<any[]>([])
const districts = ref<any[]>([])

// Form data for edit
const editFormData = ref({
  id: '',
  name: '',
  email: '',
  phone: '',
  password: '',
  role: '',
  status: '',
  gallery: ''
})

// Labels
const roleLabels: Record<string, string> = {
  superadmin: 'Süper Admin',
  admin: 'Admin',
  compliance_officer: 'Uyum Sorumlusu',
  support_agent: 'Destek Temsilcisi',
  gallery_owner: 'Galeri Sahibi',
  gallery_manager: 'Galeri Yöneticisi',
  inventory_manager: 'Envanter Yöneticisi',
  sales_rep: 'Satış Temsilcisi',
  viewer: 'İzleyici'
}

const statusLabels: Record<string, string> = {
  active: 'Aktif',
  suspended: 'Askıda',
  inactive: 'Pasif',
  deleted: 'Silindi'
}

// Computed
const filteredUsers = computed(() => {
  if (!searchQuery.value) return users.value
  const query = searchQuery.value.toLowerCase()
  return users.value.filter(u => 
    u.name?.toLowerCase().includes(query) ||
    u.email?.toLowerCase().includes(query) ||
    u.phone?.includes(query) ||
    (u.gallery && u.gallery.toLowerCase().includes(query))
  )
})

// Methods
const getRoleBadgeClass = (role: string) => {
  const classes: Record<string, string> = {
    superadmin: 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400',
    admin: 'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400',
    compliance_officer: 'bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-400',
    support_agent: 'bg-cyan-100 dark:bg-cyan-900/30 text-cyan-700 dark:text-cyan-400',
    gallery_owner: 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400',
    gallery_manager: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    inventory_manager: 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400'
  }
  return classes[role] || 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400'
}

const loadUsers = async () => {
  loading.value = true
  try {
    const data = await api.get<any>('/admin/users')
    users.value = data.users || data || []
  } catch (error: any) {
    console.error('Kullanıcılar yüklenemedi:', error)
    toast.error('Kullanıcılar yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const resetFormData = () => {
  formData.value = {
    name: '',
    email: '',
    phone: '',
    password: '',
    role: 'gallery_owner',
    status: 'active',
    galleryName: '',
    taxType: 'VKN',
    taxNumber: '',
    city: '',
    district: '',
    address: ''
  }
  districts.value = []
}

const openCreateModal = () => {
  resetFormData()
  showCreateModal.value = true
}

const closeCreateModal = () => {
  showCreateModal.value = false
  resetFormData()
}

const openEditModal = (user: any) => {
  editFormData.value = {
    id: user.id,
    name: user.name || '',
    email: user.email || '',
    phone: user.phone || '',
    password: '',
    role: user.role || 'gallery_owner',
    status: user.status || 'active',
    gallery: user.gallery || ''
  }
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
}

const createUser = async () => {
  // Validation
  if (!formData.value.name || !formData.value.email || !formData.value.phone || !formData.value.password) {
    toast.warning('Lütfen tüm zorunlu alanları doldurun')
    return
  }

  // Galeri sahibi için ek validasyon
  if (formData.value.role === 'gallery_owner') {
    if (!formData.value.galleryName) {
      toast.warning('Galeri adı zorunludur')
      return
    }
    if (!formData.value.taxNumber) {
      toast.warning('Vergi/TC Kimlik numarası zorunludur')
      return
    }
    if (formData.value.taxType === 'TCKN' && formData.value.taxNumber.length !== 11) {
      toast.warning('TC Kimlik No 11 haneli olmalıdır')
      return
    }
    if (formData.value.taxType === 'VKN' && formData.value.taxNumber.length !== 10) {
      toast.warning('Vergi Kimlik No 10 haneli olmalıdır')
      return
    }
    if (!formData.value.city) {
      toast.warning('İl seçimi zorunludur')
      return
    }
    if (!formData.value.district) {
      toast.warning('İlçe seçimi zorunludur')
      return
    }
    if (!formData.value.address) {
      toast.warning('Açık adres zorunludur')
      return
    }
  }

  formLoading.value = true
  try {
    const response = await api.post('/admin/users', formData.value)
    users.value.push(response)
    closeCreateModal()
    toast.success('Kullanıcı başarıyla oluşturuldu!')
  } catch (error: any) {
    console.error('Create user error:', error)
    toast.error('Hata: ' + error.message)
  } finally {
    formLoading.value = false
  }
}

const saveEditUser = async () => {
  if (!editFormData.value.name || !editFormData.value.email) {
    toast.warning('Ad ve e-posta zorunludur')
    return
  }

  formLoading.value = true
  try {
    const payload: any = {
      name: editFormData.value.name,
      email: editFormData.value.email,
      phone: editFormData.value.phone,
      role: editFormData.value.role,
      status: editFormData.value.status
    }
    
    // Şifre varsa ekle
    if (editFormData.value.password) {
      payload.password = editFormData.value.password
    }

    const updated = await api.put(`/admin/users/${editFormData.value.id}`, payload)
    
    const index = users.value.findIndex(u => u.id === editFormData.value.id)
    if (index > -1) {
      users.value[index] = { ...users.value[index], ...updated }
    }
    
    closeEditModal()
    toast.success('Kullanıcı güncellendi!')
    await loadUsers() // Reload to get fresh data
  } catch (error: any) {
    console.error('Update user error:', error)
    toast.error('Hata: ' + error.message)
  } finally {
    formLoading.value = false
  }
}

const deleteUser = async (id: string) => {
  if (!confirm('Bu kullanıcıyı silmek istediğinize emin misiniz?')) return

  try {
    await api.delete(`/admin/users/${id}`)
    users.value = users.value.filter(u => u.id !== id)
    toast.success('Kullanıcı silindi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

// Load Turkish cities
const loadCities = async () => {
  try {
    const response = await fetch('https://api.turkiyeapi.dev/api/v1/provinces')
    const data = await response.json()
    cities.value = data.data || []
  } catch (error) {
    console.error('Cities could not be loaded:', error)
  }
}

// Load districts for selected city
const loadDistricts = async () => {
  if (!formData.value.city) {
    districts.value = []
    formData.value.district = ''
    return
  }
  
  try {
    const city = cities.value.find(c => c.name === formData.value.city)
    if (city) {
      const response = await fetch(`https://api.turkiyeapi.dev/api/v1/provinces/${city.id}?fields=districts`)
      const data = await response.json()
      districts.value = data.data?.districts || []
    }
  } catch (error) {
    console.error('Districts could not be loaded:', error)
  }
}

onMounted(() => {
  loadUsers()
  loadCities()
})
</script>

