<script setup>
import ProgressBar from 'primevue/progressbar'
import Tag from 'primevue/tag'

defineProps({
  cards: {
    type: Array,
    required: true,
  },
})
</script>

<template>
  <section class="mt-10">
    <div class="mb-3 flex items-center justify-between">
      <h2 class="text-lg font-bold text-surface-900">Thẻ của tôi</h2>
      <span class="text-sm text-surface-500">{{ cards.length }} thẻ</span>
    </div>

    <div class="space-y-3">
      <div
        v-for="card in cards"
        :key="card.id"
        class="flex items-center gap-3 rounded-2xl border border-surface-200 bg-white p-4 shadow-sm transition-shadow hover:shadow-md"
      >
        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl text-xs font-bold" :class="card.colorClass">
          {{ card.bank }}
        </div>
        <div class="min-w-0 flex-1">
          <div class="flex flex-wrap items-center gap-2">
            <p class="text-sm font-semibold text-surface-900">{{ card.bank }} {{ card.name }}</p>
            <Tag :value="card.step" :severity="card.progress === 100 ? 'success' : 'info'" rounded />
          </div>
          <p class="mt-1 text-xs text-surface-500">{{ card.campaign }}</p>
          <p class="mt-2 text-xs font-medium text-surface-700">Tiếp theo: {{ card.next }}</p>
          <ProgressBar :value="card.progress" :show-value="false" class="mt-2 h-1" />
        </div>
      </div>
    </div>
  </section>
</template>
