export function formatMoney(value) {
  return `${new Intl.NumberFormat('vi-VN').format(value)} ₫`
}

export function formatTodayLabel(date = new Date()) {
  return new Intl.DateTimeFormat('vi-VN', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
  }).format(date)
}

export function formatTaskProgress(task) {
  if (task.target === 1) return 'Chưa hoàn thành'
  if (task.target === 3) return `${task.current}/${task.target} giao dịch`
  return `${formatMoney(task.current)} / ${formatMoney(task.target)}`
}
