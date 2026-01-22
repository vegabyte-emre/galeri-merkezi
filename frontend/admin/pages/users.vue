<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Kullanıcılar</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Tüm kullanıcıları görüntüleyin ve yönetin</p>
      </div>
      <div class="flex items-center gap-3">
        <div class="flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-800 rounded-lg">
          <Search class="w-4 h-4 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Kullanıcı ara..."
            class="bg-transparent border-0 outline-0 text-sm text-gray-700 dark:text-gray-300 placeholder-gray-400 w-64"
          />
        </div>
        <button 
          @click="showCreateModal = true"
          class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
        >
          <Plus class="w-4 h-4 inline mr-2" />
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
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Rol</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Galeri</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Durum</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Son Giriş</th>
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
                  <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold">
                    {{ user.name.charAt(0) }}
                  </div>
                  <div>
                    <div class="font-medium text-gray-900 dark:text-white">{{ user.name }}</div>
                    <div class="text-sm text-gray-500 dark:text-gray-400">{{ user.email }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400': user.role === 'admin',
                    'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400': user.role === 'gallery_owner',
                    'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400': user.role === 'user'
                  }"
                >
                  {{ roleLabels[user.role] }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                {{ user.gallery || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="px-2 py-1 text-xs font-semibold rounded-full"
                  :class="{
                    'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400': user.status === 'active',
                    'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-400': user.status === 'inactive'
                  }"
                >
                  {{ user.status === 'active' ? 'Aktif' : 'Pasif' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatDate(user.lastLogin) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex items-center justify-end gap-2">
                  <button
                    @click="editUser(user.id)"
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
          </tbody>
        </table>
      </div>
    </div>

    <!-- Create User Modal -->
    <div
      v-if="showCreateModal"
      class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      @click.self="showCreateModal = false"
    >
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-md w-full p-6">
        <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">
          Yeni Kullanıcı Ekle
        </h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Ad Soyad
            </label>
            <input
              v-model="newUser.name"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="Ad Soyad"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              E-posta
            </label>
            <input
              v-model="newUser.email"
              type="email"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="email@example.com"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Şifre
            </label>
            <input
              v-model="newUser.password"
              type="password"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="Şifre"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Rol
            </label>
            <select
              v-model="newUser.role"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
              <option value="superadmin">Süper Admin</option>
              <option value="admin">Admin</option>
              <option value="gallery_owner">Galeri Sahibi</option>
              <option value="gallery_manager">Galeri Yöneticisi</option>
              <option value="inventory_manager">Envanter Yöneticisi</option>
            </select>
          </div>

          <!-- Galeri Bilgileri - Sadece Galeri Sahibi için -->
          <div v-if="newUser.role === 'gallery_owner'" class="border-t border-gray-200 dark:border-gray-700 pt-4 mt-4">
            <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3">Galeri Bilgileri</h4>
            
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Galeri Adı
                </label>
                <input
                  v-model="newUser.galleryName"
                  type="text"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="Örn: ABC Otomotiv"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Vergi Türü
                </label>
                <select
                  v-model="newUser.taxType"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                >
                  <option value="VKN">VKN (Vergi Kimlik No - Şirket)</option>
                  <option value="TCKN">TCKN (TC Kimlik No - Şahıs)</option>
                </select>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  {{ newUser.taxType === 'TCKN' ? 'TC Kimlik No' : 'Vergi Kimlik No' }}
                </label>
                <input
                  v-model="newUser.taxNumber"
                  type="text"
                  :maxlength="newUser.taxType === 'TCKN' ? 11 : 10"
                  class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  :placeholder="newUser.taxType === 'TCKN' ? '11 haneli TC Kimlik No' : '10 haneli Vergi Kimlik No'"
                />
              </div>
            </div>
          </div>
        </div>
        <div class="flex items-center justify-end gap-3 mt-6">
          <button
            @click="showCreateModal = false; newUser = { name: '', email: '', password: '', role: 'gallery_owner', galleryId: null, galleryName: '', taxType: 'VKN', taxNumber: '' }"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          >
            İptal
          </button>
          <button
            @click="createUser"
            :disabled="createLoading"
            class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ createLoading ? 'Oluşturuluyor...' : 'Oluştur' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Edit User Modal -->
    <div
      v-if="showEditModal"
      class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      @click.self="showEditModal = false"
    >
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-md w-full p-6">
        <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">
          Kullanıcı Düzenle
        </h3>
        <div class="space-y-4" v-if="editingUser">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Ad Soyad
            </label>
            <input
              v-model="editingUser.name"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="Ad Soyad"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              E-posta
            </label>
            <input
              v-model="editingUser.email"
              type="email"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="email@example.com"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Rol
            </label>
            <select
              v-model="editingUser.role"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
              <option value="superadmin">Süper Admin</option>
              <option value="admin">Admin</option>
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
              v-model="editingUser.status"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
              <option value="active">Aktif</option>
              <option value="inactive">Pasif</option>
            </select>
          </div>
        </div>
        <div class="flex items-center justify-end gap-3 mt-6">
          <button
            @click="showEditModal = false; editingUser = null"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          >
            İptal
          </button>
          <button
            @click="saveEditUser"
            class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
          >
            Kaydet
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Search, Plus } from 'lucide-vue-next'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const loading = ref(false)
const searchQuery = ref('')
const showCreateModal = ref(false)
const showEditModal = ref(false)
const editingUser = ref<any>(null)
const newUser = ref({
  name: '',
  email: '',
  password: '',
  role: 'gallery_owner',
  galleryId: null as number | null,
  // Galeri bilgileri (gallery_owner için)
  galleryName: '',
  taxType: 'VKN',
  taxNumber: ''
})

const roleLabels: Record<string, string> = {
  superadmin: 'Süper Admin',
  admin: 'Admin',
  gallery_owner: 'Galeri Sahibi',
  gallery_manager: 'Galeri Yöneticisi',
  inventory_manager: 'Envanter Yöneticisi'
}

const users = ref<any[]>([])

const loadUsers = async () => {
  loading.value = true
  try {
    const data = await api.get('/users')
    users.value = data.users || data || []
  } catch (error: any) {
    console.error('Kullanıcılar yüklenemedi:', error)
    toast.error('Kullanıcılar yüklenemedi: ' + error.message)
  } finally {
    loading.value = false
  }
}

const filteredUsers = computed(() => {
  if (!searchQuery.value) return users.value
  
  const query = searchQuery.value.toLowerCase()
  return users.value.filter(u => 
    u.name.toLowerCase().includes(query) ||
    u.email.toLowerCase().includes(query) ||
    (u.gallery && u.gallery.toLowerCase().includes(query))
  )
})

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('tr-TR')
}

const editUser = (id: number) => {
  const user = users.value.find(u => u.id === id)
  if (user) {
    editingUser.value = { ...user }
    showEditModal.value = true
  }
}

const saveEditUser = async () => {
  if (!editingUser.value || !editingUser.value.name || !editingUser.value.email) {
    toast.warning('Lütfen tüm gerekli alanları doldurun')
    return
  }
  
  try {
    const updated = await api.put(`/users/${editingUser.value.id}`, {
      name: editingUser.value.name,
      email: editingUser.value.email,
      role: editingUser.value.role,
      status: editingUser.value.status
    })
    const index = users.value.findIndex(u => u.id === editingUser.value.id)
    if (index > -1) {
      users.value[index] = updated
    }
    showEditModal.value = false
    editingUser.value = null
    toast.success('Kullanıcı güncellendi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const createLoading = ref(false)

const createUser = async () => {
  if (!newUser.value.name || !newUser.value.email || !newUser.value.password) {
    toast.warning('Lütfen tüm gerekli alanları doldurun')
    return
  }
  
  // Galeri sahibi için ek validasyon
  if (newUser.value.role === 'gallery_owner') {
    if (!newUser.value.galleryName) {
      toast.warning('Galeri adı zorunludur')
      return
    }
    if (!newUser.value.taxNumber) {
      toast.warning('Vergi/TC Kimlik numarası zorunludur')
      return
    }
    if (newUser.value.taxType === 'TCKN' && newUser.value.taxNumber.length !== 11) {
      toast.warning('TC Kimlik No 11 haneli olmalıdır')
      return
    }
    if (newUser.value.taxType === 'VKN' && newUser.value.taxNumber.length !== 10) {
      toast.warning('Vergi Kimlik No 10 haneli olmalıdır')
      return
    }
  }
  
  createLoading.value = true
  try {
    const response = await api.post('/users', newUser.value)
    users.value.push(response)
    showCreateModal.value = false
    newUser.value = { name: '', email: '', password: '', role: 'gallery_owner', galleryId: null, galleryName: '', taxType: 'VKN', taxNumber: '' }
    toast.success('Kullanıcı başarıyla oluşturuldu!')
  } catch (error: any) {
    console.error('Create user error:', error)
    toast.error('Hata: ' + error.message)
  } finally {
    createLoading.value = false
  }
}

const deleteUser = async (id: number) => {
  if (confirm('Bu kullanıcıyı silmek istediğinize emin misiniz?')) {
    try {
      await api.delete(`/users/${id}`)
      const index = users.value.findIndex(u => u.id === id)
      if (index > -1) {
        users.value.splice(index, 1)
      }
      toast.success('Kullanıcı silindi!')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

onMounted(() => {
  loadUsers()
})
</script>

