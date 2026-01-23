<script setup lang="ts">
// Panel already has a Profile tab under /settings.
// Keep /profile for sidebar/user menu compatibility.
await navigateTo('/settings', { replace: true })
</script>

