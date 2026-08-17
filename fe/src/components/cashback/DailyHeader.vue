<script setup>
import Button from 'primevue/button'

defineProps({
  todayLabel: {
    type: String,
    required: true,
  },
})

const emit = defineEmits(['log'])
</script>

<template>
  <header class="flex items-center justify-between">
    <div>
      <p class="text-sm font-medium text-surface-500">{{ todayLabel }}</p>
      <h1 class="mt-1 text-2xl font-bold tracking-tight text-surface-950">Cashback của tôi</h1>
    </div>
    <Button icon="pi pi-plus" label="Ghi giao dịch" size="small" @click="emit('log')" />
  </header>
</template>
