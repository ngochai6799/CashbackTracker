<script setup>
import { ref } from 'vue'
import DailyHeader from '@/components/cashback/DailyHeader.vue'
import LeftSidebar from '@/components/cashback/LeftSidebar.vue'
import LogTransactionDialog from '@/components/cashback/LogTransactionDialog.vue'
import MyCardsSection from '@/components/cashback/MyCardsSection.vue'
import PendingCashbacksSection from '@/components/cashback/PendingCashbacksSection.vue'
import TodayTasksSection from '@/components/cashback/TodayTasksSection.vue'
import { useCashbackDashboard } from '@/composables/useCashbackDashboard'

const {
  cards,
  completedCount,
  formatTaskProgress,
  formatTodayLabel,
  pendingCashbacks,
  pendingCount,
  saveTransaction,
  todayTasks,
  toggleTask,
} = useCashbackDashboard()

const showLogDialog = ref(false)
const selectedTask = ref(null)

function openLogDialog(task) {
  selectedTask.value = task
  showLogDialog.value = true
}

function handleSaveTransaction({ amount }) {
  saveTransaction({ task: selectedTask.value, amount })
  showLogDialog.value = false
  selectedTask.value = null
}
</script>

<template>
  <main class="min-h-screen bg-surface-50 text-surface-900">
    <div class="mx-auto grid min-h-screen max-w-5xl xl:grid-cols-[15rem_minmax(0,1fr)]">
      <LeftSidebar
        :today-label="formatTodayLabel()"
        :completed-count="completedCount"
        :task-count="todayTasks.length"
        :card-count="cards.length"
        :pending-count="pendingCount"
      />

      <div class="min-w-0 flex-1">
        <div class="mx-auto max-w-2xl px-4 py-6 sm:px-6 sm:py-10">
          <DailyHeader :today-label="formatTodayLabel()" @log="openLogDialog(todayTasks[0])" />

          <div id="today">
            <TodayTasksSection
              :tasks="todayTasks"
              :completed-count="completedCount"
              :format-task-progress="formatTaskProgress"
              @toggle="toggleTask"
              @log="openLogDialog"
            />
          </div>

          <div id="cards">
            <MyCardsSection :cards="cards" />
          </div>
          <div id="pending">
            <PendingCashbacksSection :cashbacks="pendingCashbacks" />
          </div>

          <p class="mt-10 text-center text-xs text-surface-400">
            Cashbackly · Chỉ hiển thị những gì bạn cần làm
          </p>
        </div>
      </div>

    </div>

    <LogTransactionDialog
      v-model:visible="showLogDialog"
      :task="selectedTask"
      @save="handleSaveTransaction"
    />
  </main>
</template>
