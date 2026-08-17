<script setup>
import Button from 'primevue/button'
import ProgressBar from 'primevue/progressbar'
import Tag from 'primevue/tag'

defineProps({
  tasks: {
    type: Array,
    required: true,
  },
  completedCount: {
    type: Number,
    required: true,
  },
  formatTaskProgress: {
    type: Function,
    required: true,
  },
})

const emit = defineEmits(['toggle', 'log'])
</script>

<template>
  <section class="mt-10">
    <div class="mb-3 flex items-center justify-between">
      <h2 class="text-lg font-bold text-surface-900">Hôm nay cần làm</h2>
      <span class="text-sm text-surface-500">{{ completedCount }}/{{ tasks.length }} xong</span>
    </div>

    <div class="overflow-hidden rounded-2xl border border-surface-200 bg-white">
      <div
        v-for="task in tasks"
        :key="task.id"
        class="flex items-start gap-3 border-b border-surface-100 p-4 last:border-b-0 sm:items-center"
      >
        <button
          type="button"
          class="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full border transition-colors sm:mt-0"
          :class="task.done ? 'border-primary bg-primary text-primary-contrast' : 'border-surface-300 hover:border-primary'"
          :aria-label="`Đánh dấu ${task.title}`"
          @click="emit('toggle', task)"
        >
          <i v-if="task.done" class="pi pi-check text-[10px]" />
        </button>

        <div class="min-w-0 flex-1">
          <p class="text-xs font-medium text-primary-600">{{ task.card }}</p>
          <p class="mt-1 text-sm font-semibold" :class="task.done ? 'text-surface-400 line-through' : 'text-surface-900'">
            {{ task.title }}
          </p>
          <p class="mt-1 text-xs text-surface-500">{{ task.detail }}</p>
          <div v-if="!task.done" class="mt-3 flex max-w-md items-center gap-3">
            <ProgressBar :value="task.progress" :show-value="false" class="h-1.5 flex-1" />
            <span class="shrink-0 text-[11px] text-surface-500">{{ formatTaskProgress(task) }}</span>
          </div>
        </div>

        <Button
          v-if="!task.done"
          label="Ghi"
          text
          size="small"
          class="shrink-0 !px-2"
          @click="emit('log', task)"
        />
        <Tag v-else value="Đã xong" severity="success" rounded class="shrink-0" />
      </div>
    </div>
  </section>
</template>
