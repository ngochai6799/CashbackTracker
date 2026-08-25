<script setup lang="ts">
import Avatar from 'primevue/avatar'

defineProps<{
  cardCount: number
}>()
</script>

<template>
  <aside class="hidden min-h-screen w-full self-stretch flex-col border-r border-surface-200/80 bg-[#fbfcfe] px-4 py-7 xl:flex">
    <div class="flex items-center gap-3 px-2">
      <div class="flex h-9 w-9 items-center justify-center rounded-xl bg-primary text-primary-contrast shadow-sm shadow-primary/20">
        <i class="pi pi-bolt text-sm" />
      </div>
      <div>
        <p class="text-sm font-bold tracking-tight text-surface-900">Cashbackly</p>
        <p class="text-[10px] text-surface-400">Daily card tracker</p>
      </div>
    </div>

    <div class="mt-12 px-2 text-[10px] font-semibold uppercase tracking-[0.16em] text-surface-400">Theo dõi</div>
    <nav class="mt-3 space-y-1">
      <a href="#cards" class="group relative flex items-center gap-3 rounded-xl bg-white px-3 py-2.5 text-sm font-semibold text-primary-700 shadow-sm ring-1 ring-surface-200/70">
        <span class="absolute -left-4 h-5 w-0.5 rounded-r-full bg-primary" />
        <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-primary-50 text-primary-600">
          <i class="pi pi-credit-card text-sm" />
        </span>
        <span>Thẻ của tôi</span>
        <span class="ml-auto text-xs font-medium text-primary-500">{{ cardCount }}</span>
      </a>
    </nav>

    <div class="mt-auto border-t border-surface-200/70 pt-5">
      <div class="flex items-center gap-3 px-2">
        <Avatar label="LH" shape="circle" class="!h-8 !w-8 !bg-surface-200 !text-xs !text-surface-600" />
        <div class="min-w-0">
          <p class="truncate text-xs font-semibold text-surface-700">Linh Hoàng</p>
          <p class="truncate text-[10px] text-surface-400">{{ cardCount }} thẻ đang theo dõi</p>
        </div>
        <i class="pi pi-ellipsis-h ml-auto text-xs text-surface-300" />
      </div>
    </div>
  </aside>
</template>
