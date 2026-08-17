export function createTodayTasks() {
  return [
    {
      id: 1,
      card: 'VCB Visa Signature',
      title: 'Chi tiêu mua sắm',
      detail: 'Còn thiếu 1.600.000 ₫ để đủ điều kiện',
      current: 2400000,
      target: 4000000,
      progress: 60,
      done: false,
    },
    {
      id: 2,
      card: 'VCB Visa Signature',
      title: 'Hoàn tất giao dịch ăn uống thứ 3',
      detail: 'Đã hoàn tất 2/3 giao dịch',
      current: 2,
      target: 3,
      progress: 66,
      done: false,
    },
    {
      id: 3,
      card: 'VCB Visa Signature',
      title: 'Nhắc bạn hoàn lại tiền',
      detail: 'Subtask của khoản chi tùy chọn',
      current: 0,
      target: 1,
      progress: 0,
      done: false,
    },
  ]
}

export const cards = [
  {
    id: 1,
    bank: 'VCB',
    name: 'Visa Signature',
    campaign: 'Cashback tháng 08/2026',
    step: 'Đang gom chi tiêu',
    next: 'Mua sắm còn 1.600.000 ₫',
    progress: 60,
    colorClass: 'bg-emerald-100 text-emerald-700',
  },
  {
    id: 2,
    bank: 'TCB',
    name: 'World Mastercard',
    campaign: 'Hoàn phí thường niên 2026',
    step: 'Đã đủ điều kiện',
    next: 'Chờ ngân hàng hoàn tiền',
    progress: 100,
    colorClass: 'bg-violet-100 text-violet-700',
  },
  {
    id: 3,
    bank: 'MB',
    name: 'Hi Collection',
    campaign: 'Ưu đãi giao dịch online',
    step: 'Chưa bắt đầu',
    next: 'Cần thực hiện 2 giao dịch online',
    progress: 25,
    colorClass: 'bg-sky-100 text-sky-700',
  },
]

export const pendingCashbacks = [
  {
    id: 1,
    card: 'TCB World Mastercard',
    campaign: 'Hoàn phí thường niên 2026',
    amount: '500.000 ₫',
    status: 'Đủ điều kiện · Chờ hoàn',
    expected: 'Dự kiến 15/09/2026',
  },
  {
    id: 2,
    card: 'VCB Visa Signature',
    campaign: 'Cashback tháng 07/2026',
    amount: '820.000 ₫',
    status: 'Đã gửi yêu cầu',
    expected: 'Đã quá hạn 3 ngày',
  },
]
