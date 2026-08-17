<script setup>
defineProps({
  cashbacks: {
    type: Array,
    required: true,
  },
})
</script>

<template>
  <section class="mt-10">
    <div class="mb-3 flex items-center justify-between">
      <h2 class="text-lg font-bold text-surface-900">Chưa hoàn tiền</h2>
      <span class="text-sm text-surface-500">{{ cashbacks.length }} khoản</span>
    </div>

    <div class="overflow-hidden rounded-2xl border border-surface-200 bg-white">
      <div
        v-for="cashback in cashbacks"
        :key="cashback.id"
        class="flex items-center gap-3 border-b border-surface-100 p-4 last:border-b-0"
      >
        <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-orange-100 text-orange-600">
          <i class="pi pi-clock text-sm" />
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-semibold text-surface-900">{{ cashback.card }}</p>
          <p class="mt-1 text-xs text-surface-500">{{ cashback.campaign }}</p>
          <p class="mt-1 text-xs" :class="cashback.expected.includes('quá hạn') ? 'font-semibold text-red-600' : 'text-surface-500'">
            {{ cashback.status }} · {{ cashback.expected }}
          </p>
        </div>
        <p class="shrink-0 text-sm font-bold text-surface-900">{{ cashback.amount }}</p>
      </div>
    </div>
  </section>
</template>
