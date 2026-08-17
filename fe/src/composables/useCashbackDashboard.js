import { computed, ref } from 'vue'
import { cards, createTodayTasks, pendingCashbacks } from '@/data/cashbackMock'
import { formatMoney, formatTaskProgress, formatTodayLabel } from '@/utils/formatters'

export function useCashbackDashboard() {
  const todayTasks = ref(createTodayTasks())

  const completedCount = computed(() => todayTasks.value.filter((task) => task.done).length)
  const pendingCount = computed(() => pendingCashbacks.length)

  function toggleTask(task) {
    task.done = !task.done
    task.progress = task.done ? 100 : Math.min(task.progress, 90)
  }

  function saveTransaction({ task, amount }) {
    if (!task || !amount) return

    if (task.target === 3) {
      task.current = Math.min(task.target, task.current + 1)
    } else if (task.target > 1) {
      task.current = Math.min(task.target, task.current + amount)
    } else {
      task.current = 1
    }

    task.progress = Math.round((task.current / task.target) * 100)

    if (task.current >= task.target) {
      task.done = true
      task.progress = 100
    }
  }

  return {
    cards,
    completedCount,
    formatMoney,
    formatTaskProgress,
    formatTodayLabel,
    pendingCashbacks,
    pendingCount,
    saveTransaction,
    todayTasks,
    toggleTask,
  }
}
