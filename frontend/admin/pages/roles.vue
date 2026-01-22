<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Roller & İzinler</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Kullanıcı rollerini ve izinlerini yönetin</p>
      </div>
      <button
        @click="openCreateModal"
        class="px-4 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold rounded-lg hover:shadow-lg transition-all"
      >
        <Plus class="w-4 h-4 inline mr-2" />
        Yeni Rol Ekle
      </button>
    </div>

    <!-- Roles Grid -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="role in roles"
        :key="role.id"
        class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border-2 p-6"
        :class="role.isDefault ? 'border-primary-500' : 'border-gray-200 dark:border-gray-700'"
      >
        <!-- Header -->
        <div class="flex items-center justify-between mb-4">
          <div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">{{ role.name }}</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ role.description }}</p>
          </div>
          <span
            v-if="role.isDefault"
            class="px-2 py-1 text-xs font-semibold rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400"
          >
            Varsayılan
          </span>
        </div>

        <!-- Permissions Count -->
        <div class="mb-4">
          <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">İzinler</div>
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ role.permissions.length }} / {{ allPermissions.length }}
          </div>
        </div>

        <!-- Users Count -->
        <div class="mb-4">
          <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Kullanıcı Sayısı</div>
          <div class="text-xl font-bold text-gray-900 dark:text-white">{{ role.userCount }}</div>
        </div>

        <!-- Actions -->
        <div class="flex items-center gap-2 pt-4 border-t border-gray-200 dark:border-gray-700">
          <button
            @click="editRole(role.id)"
            class="flex-1 px-4 py-2 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 rounded-lg hover:bg-primary-200 dark:hover:bg-primary-900/50 transition-colors font-semibold text-sm"
          >
            Düzenle
          </button>
          <button
            v-if="!role.isDefault && role.id > 6"
            @click="deleteRole(role.id)"
            class="px-4 py-2 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg hover:bg-red-200 dark:hover:bg-red-900/50 transition-colors font-semibold text-sm"
          >
            Sil
          </button>
        </div>
      </div>
    </div>

    <!-- Permissions Matrix -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700 p-6">
      <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">İzin Matrisi</h3>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50">
            <tr>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">İzin</th>
              <th
                v-for="role in roles"
                :key="role.id"
                class="px-4 py-3 text-center text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase"
              >
                {{ role.name }}
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="permission in allPermissions"
              :key="permission.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/50"
            >
              <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">{{ permission.name }}</td>
              <td
                v-for="role in roles"
                :key="role.id"
                class="px-4 py-3 text-center"
              >
                <input
                  type="checkbox"
                  :checked="role.permissions.includes(permission.id)"
                  @change="togglePermission(role.id, permission.id)"
                  :disabled="role.isDefault || role.id <= 6"
                  class="rounded"
                  :class="(role.isDefault || role.id <= 6) ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Create/Edit Role Modal -->
    <div
      v-if="showEditModal"
      class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      @click.self="showEditModal = false; editingRole = null"
    >
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-md w-full p-6">
        <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">
          {{ editingRole?.id ? 'Rol Düzenle' : 'Yeni Rol Ekle' }}
        </h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Rol Adı
            </label>
            <input
              v-model="editingRole.name"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="Rol adı"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Açıklama
            </label>
            <textarea
              v-model="editingRole.description"
              rows="3"
              class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              placeholder="Rol açıklaması"
            />
          </div>
        </div>
        <div class="flex items-center justify-end gap-3 mt-6">
          <button
            @click="showEditModal = false; editingRole = null"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
          >
            İptal
          </button>
          <button
            @click="saveRole"
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
import { Plus } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useToast } from '~/composables/useToast'

const api = useApi()
const toast = useToast()
const loading = ref(false)

const allPermissions = ref<any[]>([])
const roles = ref<any[]>([])

const loadRoles = async () => {
  loading.value = true
  try {
    const response = await api.get<any>('/admin/roles')
    // Handle response format
    if (response.success) {
      roles.value = response.roles || []
    } else if (Array.isArray(response)) {
      roles.value = response
    } else {
      roles.value = []
    }
  } catch (error: any) {
    console.error('Roller yüklenemedi:', error)
    toast.error('Roller yüklenemedi: ' + error.message)
    roles.value = []
  } finally {
    loading.value = false
  }
}

const loadPermissions = async () => {
  try {
    const response = await api.get<any>('/admin/roles/permissions')
    // Handle response format
    if (response.success) {
      allPermissions.value = response.permissions || []
    } else if (Array.isArray(response)) {
      allPermissions.value = response
    } else {
      // Fallback to default permissions
      allPermissions.value = [
        { id: 1, name: 'Galerileri Görüntüle' },
        { id: 2, name: 'Galerileri Düzenle' },
        { id: 3, name: 'Galerileri Sil' },
        { id: 4, name: 'Kullanıcıları Görüntüle' },
        { id: 5, name: 'Kullanıcıları Düzenle' },
        { id: 6, name: 'Kullanıcıları Sil' },
        { id: 7, name: 'Raporları Görüntüle' },
        { id: 8, name: 'Sistem Ayarları' },
        { id: 9, name: 'Yedekleme Yönetimi' },
        { id: 10, name: 'Entegrasyon Yönetimi' }
      ]
    }
  } catch (error: any) {
    console.error('İzinler yüklenemedi:', error)
    // Keep default permissions on error
    allPermissions.value = [
      { id: 1, name: 'Galerileri Görüntüle' },
      { id: 2, name: 'Galerileri Düzenle' },
      { id: 3, name: 'Galerileri Sil' },
      { id: 4, name: 'Kullanıcıları Görüntüle' },
      { id: 5, name: 'Kullanıcıları Düzenle' },
      { id: 6, name: 'Kullanıcıları Sil' },
      { id: 7, name: 'Raporları Görüntüle' },
      { id: 8, name: 'Sistem Ayarları' },
      { id: 9, name: 'Yedekleme Yönetimi' },
      { id: 10, name: 'Entegrasyon Yönetimi' }
    ]
  }
}

const togglePermission = async (roleId: number, permissionId: number) => {
  const role = roles.value.find(r => r.id === roleId)
  if (!role) return

  // Default roles (id <= 6) cannot be modified
  if (role.isDefault || roleId <= 6) {
    toast.warning('Varsayılan sistem rollerinin izinleri değiştirilemez')
    return
  }

  const index = role.permissions.indexOf(permissionId)
  const hasPermission = index > -1
  
  try {
    await api.put(`/admin/roles/${roleId}/permissions`, {
      permissionId,
      enabled: !hasPermission
    })
    
    // Update local state optimistically
    if (hasPermission) {
      role.permissions.splice(index, 1)
    } else {
      role.permissions.push(permissionId)
    }
    
    toast.success('İzin güncellendi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
    // Reload roles on error to sync state
    await loadRoles()
  }
}

const showEditModal = ref(false)
const editingRole = ref<any>(null)

const openCreateModal = () => {
  editingRole.value = {
    name: '',
    description: '',
    permissions: [],
    isDefault: false
  }
  showEditModal.value = true
}

const editRole = (id: number) => {
  const role = roles.value.find(r => r.id === id)
  if (!role) return

  // Default roles cannot be edited
  if (role.isDefault || id <= 6) {
    toast.warning('Varsayılan sistem rollerini düzenleyemezsiniz')
    return
  }

  editingRole.value = { ...role }
  showEditModal.value = true
}

const saveRole = async () => {
  if (!editingRole.value?.name) {
    toast.error('Rol adı gereklidir')
    return
  }
  
  try {
    if (editingRole.value.id) {
      const response = await api.put(`/admin/roles/${editingRole.value.id}`, editingRole.value)
      // Reload roles to get updated data
      await loadRoles()
    } else {
      const response = await api.post('/admin/roles', editingRole.value)
      // Handle response format
      if (response.success && response.id) {
        // Reload roles to get the new role with proper data
        await loadRoles()
      } else if (response.id) {
        // Response is the role object itself
        await loadRoles()
      }
    }
    showEditModal.value = false
    editingRole.value = null
    toast.success('Rol kaydedildi!')
  } catch (error: any) {
    toast.error('Hata: ' + error.message)
  }
}

const deleteRole = async (id: number) => {
  if (confirm('Bu rolü silmek istediğinize emin misiniz?')) {
    try {
      await api.delete(`/admin/roles/${id}`)
      roles.value = roles.value.filter(r => r.id !== id)
      toast.success('Rol silindi!')
    } catch (error: any) {
      toast.error('Hata: ' + error.message)
    }
  }
}

onMounted(() => {
  loadRoles()
  loadPermissions()
})
</script>

