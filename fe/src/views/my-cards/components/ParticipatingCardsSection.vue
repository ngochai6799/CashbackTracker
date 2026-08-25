<script setup lang="ts">
import { ref } from 'vue'
import Button from 'primevue/button'
import Column from 'primevue/column'
import DataTable from 'primevue/datatable'
import ProgressBar from 'primevue/progressbar'
import Tag from 'primevue/tag'
import type { CashbackCard } from '../data/cashbackMock'

defineProps<{
  cards: CashbackCard[]
}>()

const expandedRows = ref<Record<number, boolean>>({})
</script>

<template>
  <section id="cards" class="mt-2">
    <div class="mb-5 flex flex-col justify-between gap-3 sm:flex-row sm:items-end">
      <div>
        <p class="mb-1 text-xs font-medium uppercase tracking-[0.14em] text-primary-600">Các thẻ đang theo dõi</p>
        <h1 class="text-2xl font-bold tracking-tight text-surface-950">Thẻ của tôi</h1>
        <p class="mt-2 text-sm text-surface-500">
          Mỗi dòng là một thẻ. Mở rộng để xem các chiến dịch theo tháng đang còn mở.
        </p>
      </div>
      <Button label="Thêm thẻ" icon="pi pi-plus" text size="small" />
    </div>

    <div class="overflow-hidden rounded-2xl border border-surface-200 bg-white shadow-sm">
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
              <p class="font-semibold text-surface-900">{{ data.card }}</p>
              <p class="mt-1 text-xs text-surface-500">{{ data.bank }}</p>
            </div>
          </template>
        </Column>

        <Column header="Chương trình chính" style="min-width: 20rem">
          <template #body="{ data }">
            <p class="font-semibold text-surface-800">{{ data.mainProgram.name }}</p>
            <p class="mt-1 text-xs leading-5 text-surface-500">{{ data.mainProgram.description }}</p>
            <p class="mt-2 text-xs font-semibold text-primary-600">{{ data.mainProgram.reward }}</p>
          </template>
        </Column>

        <Column header="Chiến dịch tháng" style="min-width: 15rem">
          <template #body="{ data }">
            <template v-if="data.monthlyCampaigns[0]">
              <span class="font-semibold text-surface-800">{{ data.monthlyCampaigns.length }} chiến dịch mở</span>
              <div class="mt-2 flex items-center gap-2">
                <Tag :value="data.monthlyCampaigns[0].status" :severity="data.monthlyCampaigns[0].statusSeverity" rounded />
                <span class="text-xs text-surface-500">{{ data.monthlyCampaigns[0].period }}</span>
              </div>
            </template>
            <span v-else class="text-xs text-surface-400">Không có chiến dịch tháng đang mở</span>
          </template>
        </Column>

        <Column header="Phí thường niên" style="min-width: 11rem; width: 11rem">
          <template #body="{ data }">
            <div class="text-surface-500">
              <p class="text-xs font-semibold text-surface-700">{{ data.annualFee.amount }}</p>
              <Tag :value="data.annualFee.status" :severity="data.annualFee.statusSeverity" rounded class="mt-1 !text-[10px]" />
              <p class="mt-1 text-[10px]">Hoàn phí năm sau</p>
            </div>
          </template>
        </Column>

        <Column header="Chi tiêu năm" style="min-width: 14rem; width: 14rem">
          <template #body="{ data }">
            <div class="mb-1 flex items-center justify-between gap-2 text-[11px] text-surface-500">
              <span>{{ data.annualFee.spent }}</span>
              <span class="font-semibold text-surface-600">{{ data.annualFee.progress }}%</span>
            </div>
            <ProgressBar :value="data.annualFee.progress" :show-value="false" class="h-1" />
            <p class="mt-1 line-clamp-2 text-[10px] leading-4 text-surface-400">{{ data.annualFee.next }}</p>
          </template>
        </Column>

        <template #expansion="{ data }">
          <div class="space-y-4 bg-surface-50/70 p-5">
            <div class="flex flex-col justify-between gap-2 sm:flex-row sm:items-center">
              <div>
                <p class="text-xs font-semibold uppercase tracking-wide text-surface-400">Chiến dịch theo tháng</p>
                <p class="mt-1 text-sm text-surface-600">
                  Chỉ hiển thị các kỳ tháng chưa hoàn thành hoặc chưa nhận cashback.
                </p>
              </div>
              <span class="text-xs font-medium text-surface-500">{{ data.monthlyCampaigns.length }} kỳ đang mở</span>
            </div>

            <div v-if="data.monthlyCampaigns.length" class="space-y-4">
              <article
                v-for="campaign in data.monthlyCampaigns"
                :key="campaign.id"
                class="rounded-xl border border-surface-200 bg-white p-4 shadow-sm"
              >
                <div class="flex flex-col justify-between gap-3 lg:flex-row lg:items-start">
                  <div>
                    <div class="flex flex-wrap items-center gap-2">
                      <h3 class="text-base font-bold text-surface-900">{{ campaign.period }}</h3>
                      <Tag :value="campaign.status" :severity="campaign.statusSeverity" rounded />
                    </div>
                    <p class="mt-1 text-xs text-surface-500">{{ campaign.dateRange }} · {{ campaign.step }}</p>
                  </div>
                  <div class="lg:min-w-72">
                    <div class="mb-1 flex items-center justify-between text-xs">
                      <span class="text-surface-500">Tiến độ</span>
                      <span class="font-semibold text-primary-600">{{ campaign.progress }}%</span>
                    </div>
                    <ProgressBar :value="campaign.progress" :show-value="false" class="h-1.5" />
                    <p class="mt-2 text-right text-xs text-surface-500">{{ campaign.spent }}</p>
                  </div>
                </div>

                <div class="mt-5 grid gap-5 border-t border-surface-100 pt-4 lg:grid-cols-[1.1fr_1fr_0.8fr]">
                  <div>
                    <p class="mb-3 text-xs font-semibold uppercase tracking-wide text-surface-400">Điều kiện</p>
                    <div class="space-y-3">
                      <div v-for="condition in campaign.conditions" :key="condition.name">
                        <div class="mb-1 flex items-center justify-between gap-3 text-xs">
                          <span class="font-medium text-surface-700">{{ condition.name }}</span>
                          <span class="text-surface-500">{{ condition.detail }}</span>
                        </div>
                        <ProgressBar :value="condition.progress" :show-value="false" class="h-1.5" />
                      </div>
                    </div>
                  </div>

                  <div>
                    <p class="mb-3 text-xs font-semibold uppercase tracking-wide text-surface-400">Task trong kỳ</p>
                    <div class="space-y-2">
                      <div v-for="task in campaign.tasks" :key="task.name" class="flex items-center justify-between gap-3">
                        <span class="text-xs text-surface-700">{{ task.name }}</span>
                        <Tag :value="task.status" :severity="task.severity" rounded />
                      </div>
                    </div>
                  </div>

                  <div>
                    <p class="mb-3 text-xs font-semibold uppercase tracking-wide text-surface-400">Cashback</p>
                    <p class="text-lg font-bold text-surface-900">{{ campaign.cashback }}</p>
                    <Tag :value="campaign.cashbackStatus" :severity="campaign.cashbackSeverity" rounded class="mt-2" />
                    <p class="mt-3 text-xs leading-5 text-surface-600">Tiếp theo: {{ campaign.next }}</p>
                  </div>
                </div>
              </article>
            </div>

            <p v-else class="rounded-xl border border-dashed border-surface-300 bg-white p-6 text-center text-sm text-surface-500">
              Không còn chiến dịch theo tháng chưa hoàn thành.
            </p>
          </div>
        </template>
      </DataTable>
    </div>
  </section>
</template>
