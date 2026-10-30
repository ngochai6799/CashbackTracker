<script setup lang="ts">
import { ref } from 'vue'
import Button from 'primevue/button'
import Column from 'primevue/column'
import DataTable from 'primevue/datatable'
import Tag from 'primevue/tag'
import type { Card } from '@/services/cardService'

defineProps<{
  cards: Card[]
  isLoading: boolean
  error: string
}>()

const emit = defineEmits<{
  retry: []
}>()

const expandedRows = ref<Record<number, boolean>>({})

function formatCurrency(amount: number, currency: string): string {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency,
  }).format(amount)
}
</script>

<template>
  <section id="cards" class="mt-2">
    <div class="mb-5 flex flex-col justify-between gap-3 sm:flex-row sm:items-end">
      <div>
        <p class="mb-1 text-xs font-medium uppercase tracking-[0.14em] text-primary-600">Các thẻ đang theo dõi</p>
        <h1 class="text-2xl font-bold tracking-tight text-surface-950">Thẻ của tôi</h1>
        <p class="mt-2 text-sm text-surface-500">
          Danh sách các thẻ thuộc tài khoản của bạn.
        </p>
      </div>
      <Button label="Thêm thẻ" icon="pi pi-plus" text size="small" class="cursor-pointer" />
    </div>

    <div
      v-if="isLoading"
      class="flex min-h-52 items-center justify-center rounded-2xl border border-surface-200 bg-white text-sm text-surface-500 shadow-sm"
    >
      <i class="pi pi-spin pi-spinner mr-2" />
      Đang tải danh sách thẻ...
    </div>

    <div
      v-else-if="error"
      class="flex min-h-52 flex-col items-center justify-center rounded-2xl border border-red-100 bg-red-50 px-6 text-center shadow-sm"
    >
      <i class="pi pi-exclamation-circle mb-3 text-xl text-red-500" />
      <p class="text-sm text-red-600">{{ error }}</p>
      <Button label="Thử lại" text size="small" class="mt-3 cursor-pointer" @click="emit('retry')" />
    </div>

    <div
      v-else-if="!cards.length"
      class="flex min-h-52 flex-col items-center justify-center rounded-2xl border border-dashed border-surface-300 bg-white px-6 text-center shadow-sm"
    >
      <i class="pi pi-credit-card mb-3 text-xl text-surface-400" />
      <p class="text-sm font-medium text-surface-700">Bạn chưa có thẻ nào.</p>
      <p class="mt-1 text-xs text-surface-500">Thêm thẻ đầu tiên để bắt đầu theo dõi cashback.</p>
    </div>

    <div v-else class="overflow-hidden rounded-2xl border border-surface-200 bg-white shadow-sm">
      <DataTable
        v-model:expanded-rows="expandedRows"
        :value="cards"
        data-key="id"
        scrollable
        striped-rows
        row-hover
        size="small"
        table-style="min-width: 82rem"
      >
        <Column expander style="width: 3rem" />

        <Column header="Thẻ" style="min-width: 15rem">
          <template #body="{ data }">
            <div>
              <p class="font-semibold text-surface-900">{{ data.cardName }}</p>
              <p class="mt-1 text-xs text-surface-500">
                {{ data.issuer }}<span v-if="data.lastFour"> · •••• {{ data.lastFour }}</span>
              </p>
            </div>
          </template>
        </Column>

        <Column header="Chương trình chính" style="min-width: 20rem">
          <template #body>
            <p class="text-sm text-surface-400">Chưa có dữ liệu chương trình</p>
            <p class="mt-1 text-xs text-surface-400">Sẽ được kết nối ở bước tiếp theo</p>
          </template>
        </Column>

        <Column header="Chiến dịch tháng" style="min-width: 15rem">
          <template #body>
            <p class="text-sm text-surface-400">Chưa có campaign</p>
            <p class="mt-1 text-xs text-surface-400">Chưa có dữ liệu để theo dõi</p>
          </template>
        </Column>

        <Column header="Phí thường niên" style="min-width: 11rem; width: 11rem">
          <template #body="{ data }">
            <div class="text-surface-500">
              <p class="text-xs font-semibold text-surface-700">{{ formatCurrency(data.annualFee, data.currency) }}</p>
              <Tag
                :value="data.isActive ? 'Đang hoạt động' : 'Đã tắt'"
                :severity="data.isActive ? 'success' : 'secondary'"
                rounded
                class="mt-1 !text-[10px]"
              />
            </div>
          </template>
        </Column>

        <Column header="Chi tiêu năm" style="min-width: 14rem; width: 14rem">
          <template #body>
            <p class="text-xs text-surface-400">Chưa có dữ liệu chi tiêu</p>
            <p class="mt-1 text-[10px] leading-4 text-surface-400">Tiến độ sẽ lấy từ campaign</p>
          </template>
        </Column>

        <template #expansion>
          <div class="bg-surface-50/70 p-5">
            <p class="text-xs font-semibold uppercase tracking-wide text-surface-400">Chiến dịch theo tháng</p>
            <p class="mt-2 text-sm text-surface-500">
              Chưa có dữ liệu campaign cho thẻ này.
            </p>
          </div>
        </template>
      </DataTable>
    </div>
  </section>
</template>
