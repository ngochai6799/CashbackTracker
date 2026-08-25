export interface CampaignCondition {
  name: string
  progress: number
  detail: string
}

export interface CampaignTask {
  name: string
  status: string
  severity: string
}

export interface MonthlyCampaign {
  id: number
  period: string
  dateRange: string
  status: string
  statusSeverity: string
  step: string
  next: string
  progress: number
  spent: string
  cashback: string
  cashbackStatus: string
  cashbackSeverity: string
  conditions: CampaignCondition[]
  tasks: CampaignTask[]
}

export interface AnnualFeeSummary {
  amount: string
  status: string
  statusSeverity: string
  spent: string
  progress: number
  next: string
}

export interface MainProgram {
  name: string
  description: string
  reward: string
}

export interface CashbackCard {
  id: number
  bank: string
  card: string
  annualFee: AnnualFeeSummary
  mainProgram: MainProgram
  monthlyCampaigns: MonthlyCampaign[]
}

export const participatingCards: CashbackCard[] = [
  {
    id: 1,
    bank: 'Vietcombank',
    card: 'VCB Visa Signature',
    annualFee: {
      amount: '1.200.000 ₫',
      status: 'Chưa đạt điều kiện',
      statusSeverity: 'warn',
      spent: '6.000.000 ₫ / 10.000.000 ₫',
      progress: 60,
      next: 'Còn thiếu 4.000.000 ₫ để được hoàn phí năm sau',
    },
    mainProgram: {
      name: 'Cashback ăn uống',
      description: 'Hoàn tiền cho nhóm ăn uống mỗi tháng',
      reward: 'Tối đa 1.000.000 ₫ / tháng',
    },
    monthlyCampaigns: [
      {
        id: 101,
        period: 'Tháng 08/2026',
        dateRange: '01/08/2026 — 31/08/2026',
        status: 'Đang thực hiện',
        statusSeverity: 'info',
        step: 'Đang gom chi tiêu',
        next: 'Mua sắm còn 1.600.000 ₫',
        progress: 60,
        spent: '6.000.000 ₫ / 10.000.000 ₫',
        cashback: 'Tối đa 1.000.000 ₫',
        cashbackStatus: 'Chưa nhận',
        cashbackSeverity: 'warn',
        conditions: [
          { name: 'Mua sắm', progress: 60, detail: '2.400.000 ₫ / 4.000.000 ₫' },
          { name: 'Ăn uống', progress: 66, detail: '2 / 3 giao dịch' },
          { name: 'Tùy chọn', progress: 0, detail: '0 / 1 bước' },
        ],
        tasks: [
          { name: 'Chi tiêu mua sắm', status: 'Đang làm', severity: 'info' },
          { name: 'Hoàn tất giao dịch ăn uống thứ 3', status: 'Đang làm', severity: 'info' },
          { name: 'Nhắc bạn hoàn lại tiền', status: 'Chưa làm', severity: 'secondary' },
        ],
      },
    ],
  },
  {
    id: 2,
    bank: 'Techcombank',
    card: 'TCB World Mastercard',
    annualFee: {
      amount: '800.000 ₫',
      status: 'Đủ điều kiện',
      statusSeverity: 'success',
      spent: '10.000.000 ₫ / 10.000.000 ₫',
      progress: 100,
      next: 'Đã đủ điều kiện hoàn phí năm tiếp theo',
    },
    mainProgram: {
      name: 'Cashback ăn uống',
      description: 'Hoàn tiền cho giao dịch nhà hàng và cà phê',
      reward: 'Tối đa 500.000 ₫ / tháng',
    },
    monthlyCampaigns: [
      {
        id: 201,
        period: 'Tháng 08/2026',
        dateRange: '01/08/2026 — 31/08/2026',
        status: 'Đang thực hiện',
        statusSeverity: 'info',
        step: 'Đang hoàn thành số giao dịch',
        next: 'Cần thêm 1 giao dịch ăn uống',
        progress: 66,
        spent: '2 / 3 giao dịch',
        cashback: 'Tối đa 500.000 ₫',
        cashbackStatus: 'Chưa nhận',
        cashbackSeverity: 'warn',
        conditions: [
          { name: 'Giao dịch ăn uống', progress: 66, detail: '2 / 3 giao dịch' },
          { name: 'Đăng ký ưu đãi', progress: 100, detail: 'Đã hoàn thành' },
        ],
        tasks: [
          { name: 'Thực hiện giao dịch ăn uống thứ 3', status: 'Đang làm', severity: 'info' },
          { name: 'Kiểm tra giao dịch hợp lệ', status: 'Đã xong', severity: 'success' },
        ],
      },
    ],
  },
  {
    id: 3,
    bank: 'MB Bank',
    card: 'MB Hi Collection',
    annualFee: {
      amount: '600.000 ₫',
      status: 'Đang tích lũy',
      statusSeverity: 'info',
      spent: '35.000.000 ₫ / 50.000.000 ₫',
      progress: 70,
      next: 'Còn thiếu 15.000.000 ₫ để đạt điều kiện',
    },
    mainProgram: {
      name: 'Cashback giao dịch online',
      description: 'Hoàn tiền cho các giao dịch mua sắm online',
      reward: 'Tối đa 300.000 ₫ / tháng',
    },
    monthlyCampaigns: [
      {
        id: 301,
        period: 'Tháng 08/2026',
        dateRange: '01/08/2026 — 31/08/2026',
        status: 'Đang thực hiện',
        statusSeverity: 'info',
        step: 'Chưa đạt số giao dịch',
        next: 'Cần thực hiện thêm 3 giao dịch online',
        progress: 25,
        spent: '1 / 4 giao dịch',
        cashback: 'Tối đa 300.000 ₫',
        cashbackStatus: 'Chưa nhận',
        cashbackSeverity: 'secondary',
        conditions: [
          { name: 'Giao dịch online', progress: 25, detail: '1 / 4 giao dịch' },
          { name: 'Kích hoạt ưu đãi', progress: 100, detail: 'Đã hoàn thành' },
        ],
        tasks: [
          { name: 'Thực hiện giao dịch online thứ 2', status: 'Chưa làm', severity: 'secondary' },
          { name: 'Kiểm tra giao dịch hợp lệ', status: 'Chưa làm', severity: 'secondary' },
        ],
      },
    ],
  },
]
