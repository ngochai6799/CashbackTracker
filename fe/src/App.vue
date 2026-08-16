<script setup>
import { computed, ref } from 'vue'
import Avatar from 'primevue/avatar'
import Badge from 'primevue/badge'
import Button from 'primevue/button'
import Card from 'primevue/card'
import Divider from 'primevue/divider'
import ProgressBar from 'primevue/progressbar'
import Tag from 'primevue/tag'

const activeMenu = ref('Tổng quan')

const menuItems = [
  { label: 'Tổng quan', icon: 'pi pi-home' },
  { label: 'Thẻ của tôi', icon: 'pi pi-credit-card' },
  { label: 'Chương trình', icon: 'pi pi-sparkles' },
  { label: 'Chiến dịch', icon: 'pi pi-chart-line' },
]

const summaryCards = [
  {
    label: 'Cashback dự kiến',
    value: '2.450.000 ₫',
    note: '+18,4% so với tháng trước',
    icon: 'pi pi-wallet',
    iconClass: 'bg-emerald-50 text-emerald-600',
  },
  {
    label: 'Chi tiêu tháng này',
    value: '7.680.000 ₫',
    note: '76,8% mục tiêu tháng',
    icon: 'pi pi-shopping-bag',
    iconClass: 'bg-violet-50 text-violet-600',
  },
  {
    label: 'Chiến dịch đang theo dõi',
    value: '03',
    note: '01 sắp hoàn thành',
    icon: 'pi pi-bolt',
    iconClass: 'bg-amber-50 text-amber-600',
  },
  {
    label: 'Thẻ đang sử dụng',
    value: '04',
    note: '02 thẻ có ưu đãi nổi bật',
    icon: 'pi pi-credit-card',
    iconClass: 'bg-blue-50 text-blue-600',
  },
]

const campaigns = ref([
  {
    id: 1,
    bank: 'Vietcombank',
    card: 'Visa Signature',
    title: 'Hoàn tiền chi tiêu tháng 08/2026',
    reward: 'Tối đa 1.000.000 ₫',
    progress: 76,
    spent: '7.680.000 ₫',
    target: '10.000.000 ₫',
    daysLeft: '15 ngày còn lại',
    color: 'emerald',
  },
  {
    id: 2,
    bank: 'Techcombank',
    card: 'World Mastercard',
    title: 'Hoàn phí thường niên 2026',
    reward: 'Hoàn 500.000 ₫',
    progress: 48,
    spent: '4.800.000 ₫',
    target: '10.000.000 ₫',
    daysLeft: '124 ngày còn lại',
    color: 'violet',
  },
])

const tasks = ref([
  {
    id: 1,
    title: 'Chi tiêu mua sắm tối thiểu 4.000.000 ₫',
    campaign: 'Visa Signature · Tháng 08/2026',
    progress: 82,
    status: 'Đang thực hiện',
    severity: 'info',
  },
  {
    id: 2,
    title: 'Hoàn tất 3 giao dịch ăn uống',
    campaign: 'Visa Signature · Tháng 08/2026',
    progress: 66,
    status: 'Đang thực hiện',
    severity: 'info',
  },
  {
    id: 3,
    title: 'Đăng ký nhận hoàn phí thường niên',
    campaign: 'World Mastercard · Năm 2026',
    progress: 100,
    status: 'Đã hoàn thành',
    severity: 'success',
  },
])

const completedTaskCount = computed(
  () => tasks.value.filter((task) => task.progress === 100).length,
)

function selectMenu(label) {
  activeMenu.value = label
}

function markTaskCompleted(task) {
  task.progress = task.progress === 100 ? 0 : 100
  task.status = task.progress === 100 ? 'Đã hoàn thành' : 'Đang thực hiện'
  task.severity = task.progress === 100 ? 'success' : 'info'
}
</script>

<template>
  <div class="min-h-screen bg-surface-50 text-surface-900">
    <div class="flex min-h-screen">
      <aside
        class="hidden w-72 shrink-0 flex-col border-r border-surface-200 bg-white px-5 py-6 lg:flex"
      >
        <div class="flex items-center gap-3 px-2">
          <div
            class="flex h-10 w-10 items-center justify-center rounded-xl bg-primary text-primary-contrast shadow-sm"
          >
            <i class="pi pi-wallet text-lg" />
          </div>
          <div>
            <p class="text-base font-bold tracking-tight text-surface-900">Cashbackly</p>
            <p class="text-xs text-surface-500">Smart card rewards</p>
          </div>
        </div>

        <div class="mt-10 px-2 text-[11px] font-semibold uppercase tracking-[0.18em] text-surface-400">
          Workspace
        </div>

        <nav class="mt-3 space-y-1">
          <button
            v-for="item in menuItems"
            :key="item.label"
            type="button"
            class="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm transition-colors"
            :class="
              activeMenu === item.label
                ? 'bg-primary-50 font-semibold text-primary-700'
                : 'text-surface-600 hover:bg-surface-100 hover:text-surface-900'
            "
            @click="selectMenu(item.label)"
          >
            <i :class="item.icon" class="text-sm" />
            <span>{{ item.label }}</span>
            <Badge
              v-if="item.label === 'Chiến dịch'"
              value="3"
              severity="contrast"
              class="ml-auto"
            />
          </button>
        </nav>

        <Divider />

        <nav class="space-y-1">
          <button
            type="button"
            class="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm text-surface-600 transition-colors hover:bg-surface-100 hover:text-surface-900"
          >
            <i class="pi pi-bookmark text-sm" />
            <span>Đã lưu</span>
          </button>
          <button
            type="button"
            class="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm text-surface-600 transition-colors hover:bg-surface-100 hover:text-surface-900"
          >
            <i class="pi pi-cog text-sm" />
            <span>Cài đặt</span>
          </button>
        </nav>

        <div class="mt-auto rounded-2xl bg-primary-50 p-4">
          <div class="mb-3 flex h-9 w-9 items-center justify-center rounded-lg bg-primary-100 text-primary-700">
            <i class="pi pi-lightbulb" />
          </div>
          <p class="text-sm font-semibold text-surface-900">Mẹo tối ưu cashback</p>
          <p class="mt-1 text-xs leading-5 text-surface-600">
            Chia nhỏ giao dịch theo từng nhóm chi tiêu để dễ theo dõi điều kiện hơn.
          </p>
          <Button label="Xem mẹo" text size="small" class="mt-2 !px-0" />
        </div>
      </aside>

      <main class="min-w-0 flex-1">
        <header
          class="flex h-20 items-center justify-between border-b border-surface-200 bg-white px-4 sm:px-6 lg:px-10"
        >
          <div class="flex items-center gap-3">
            <Button icon="pi pi-bars" text rounded class="lg:!hidden" aria-label="Mở menu" />
            <div>
              <p class="text-xs font-medium text-surface-500">Thứ Sáu, 14 tháng 8, 2026</p>
              <h1 class="mt-0.5 text-lg font-bold tracking-tight text-surface-900 sm:text-xl">
                Chào buổi sáng, Linh 👋
              </h1>
            </div>
          </div>
          <div class="flex items-center gap-2 sm:gap-4">
            <Button icon="pi pi-bell" text rounded aria-label="Thông báo" />
            <div class="hidden h-7 w-px bg-surface-200 sm:block" />
            <div class="flex items-center gap-2">
              <Avatar label="LH" shape="circle" class="!bg-primary-100 !text-primary-700" />
              <div class="hidden text-left sm:block">
                <p class="text-sm font-semibold text-surface-900">Linh Hoàng</p>
                <p class="text-xs text-surface-500">Tài khoản cá nhân</p>
              </div>
              <i class="pi pi-chevron-down ml-1 hidden text-xs text-surface-400 sm:block" />
            </div>
          </div>
        </header>

        <div class="mx-auto max-w-7xl p-4 sm:p-6 lg:p-10">
          <section class="mb-8 flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
            <div>
              <p class="mb-2 text-sm font-medium text-primary-600">Tổng quan tài chính</p>
              <h2 class="text-2xl font-bold tracking-tight text-surface-950 sm:text-3xl">
                Theo dõi cashback của bạn
              </h2>
              <p class="mt-2 max-w-xl text-sm leading-6 text-surface-500">
                Quản lý thẻ, chương trình ưu đãi và tiến độ hoàn tiền tại một nơi.
              </p>
            </div>
            <Button label="Thêm chương trình" icon="pi pi-plus" />
          </section>

          <section class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <Card v-for="item in summaryCards" :key="item.label" class="border border-surface-200 shadow-none">
              <template #content>
                <div class="flex items-start justify-between gap-3">
                  <div>
                    <p class="text-sm text-surface-500">{{ item.label }}</p>
                    <p class="mt-2 text-xl font-bold tracking-tight text-surface-900">
                      {{ item.value }}
                    </p>
                    <p class="mt-2 text-xs text-surface-500">{{ item.note }}</p>
                  </div>
                  <div
                    class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl"
                    :class="item.iconClass"
                  >
                    <i :class="item.icon" />
                  </div>
                </div>
              </template>
            </Card>
          </section>

          <section class="mt-8 grid gap-6 xl:grid-cols-[minmax(0,1.35fr)_minmax(320px,0.65fr)]">
            <Card class="border border-surface-200 shadow-none">
              <template #title>
                <div class="flex items-center justify-between gap-3">
                  <div>
                    <h3 class="text-lg font-bold text-surface-900">Chiến dịch đang theo dõi</h3>
                    <p class="mt-1 text-sm font-normal text-surface-500">
                      Tiến độ các chương trình cashback hiện tại
                    </p>
                  </div>
                  <Button label="Xem tất cả" text size="small" />
                </div>
              </template>
              <template #content>
                <div class="space-y-6">
                  <div v-for="campaign in campaigns" :key="campaign.id">
                    <div class="flex items-start justify-between gap-4">
                      <div class="flex min-w-0 items-start gap-3">
                        <div
                          class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl text-sm font-bold"
                          :class="
                            campaign.color === 'emerald'
                              ? 'bg-emerald-100 text-emerald-700'
                              : 'bg-violet-100 text-violet-700'
                          "
                        >
                          {{ campaign.bank.slice(0, 2).toUpperCase() }}
                        </div>
                        <div class="min-w-0">
                          <p class="truncate text-sm font-semibold text-surface-900">
                            {{ campaign.title }}
                          </p>
                          <p class="mt-1 text-xs text-surface-500">
                            {{ campaign.bank }} · {{ campaign.card }}
                          </p>
                        </div>
                      </div>
                      <Tag :value="campaign.reward" severity="success" rounded class="shrink-0" />
                    </div>
                    <div class="mt-4 flex items-center justify-between text-xs">
                      <span class="font-medium text-surface-600">{{ campaign.spent }} / {{ campaign.target }}</span>
                      <span class="font-semibold text-primary-600">{{ campaign.progress }}%</span>
                    </div>
                    <ProgressBar :value="campaign.progress" :show-value="false" class="mt-2 h-2" />
                    <div class="mt-2 flex items-center justify-between text-xs text-surface-500">
                      <span>{{ campaign.daysLeft }}</span>
                      <Button label="Chi tiết" text size="small" class="!p-0" />
                    </div>
                  </div>
                </div>
              </template>
            </Card>

            <Card class="border border-surface-200 bg-surface-900 !text-white shadow-none">
              <template #content>
                <div class="flex h-full flex-col">
                  <div class="flex items-start justify-between">
                    <div>
                      <p class="text-sm text-surface-300">Cashback đã nhận</p>
                      <p class="mt-3 text-3xl font-bold tracking-tight">8.760.000 ₫</p>
                    </div>
                    <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-white/10">
                      <i class="pi pi-chart-line text-primary-300" />
                    </div>
                  </div>
                  <div class="mt-8 flex items-end gap-1">
                    <div v-for="(height, index) in [25, 42, 34, 58, 48, 72, 64, 88]" :key="index" class="flex-1">
                      <div
                        class="rounded-t-md bg-primary-400/80 transition-all hover:bg-primary-300"
                        :style="{ height: `${height}px` }"
                      />
                    </div>
                  </div>
                  <div class="mt-3 flex justify-between text-[11px] text-surface-400">
                    <span>Tháng 01</span>
                    <span>Tháng 08</span>
                  </div>
                  <Divider class="!my-5 !border-surface-700" />
                  <div class="mt-auto flex items-center justify-between">
                    <div>
                      <p class="text-xs text-surface-400">So với năm ngoái</p>
                      <p class="mt-1 text-sm font-semibold text-emerald-300">+24,8%</p>
                    </div>
                    <i class="pi pi-arrow-up-right text-emerald-300" />
                  </div>
                </div>
              </template>
            </Card>
          </section>

          <section class="mt-8">
            <Card class="border border-surface-200 shadow-none">
              <template #title>
                <div class="flex flex-col justify-between gap-3 sm:flex-row sm:items-center">
                  <div>
                    <h3 class="text-lg font-bold text-surface-900">Nhiệm vụ cần hoàn thành</h3>
                    <p class="mt-1 text-sm font-normal text-surface-500">
                      {{ completedTaskCount }}/{{ tasks.length }} nhiệm vụ đã hoàn thành
                    </p>
                  </div>
                  <Button label="Quản lý nhiệm vụ" text size="small" />
                </div>
              </template>
              <template #content>
                <div class="divide-y divide-surface-100">
                  <div
                    v-for="task in tasks"
                    :key="task.id"
                    class="flex flex-col gap-4 py-4 first:pt-0 last:pb-0 sm:flex-row sm:items-center sm:justify-between"
                  >
                    <div class="flex min-w-0 items-start gap-3">
                      <button
                        type="button"
                        class="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full border transition-colors"
                        :class="
                          task.progress === 100
                            ? 'border-primary bg-primary text-primary-contrast'
                            : 'border-surface-300 text-transparent hover:border-primary'
                        "
                        :aria-label="`Đánh dấu nhiệm vụ: ${task.title}`"
                        @click="markTaskCompleted(task)"
                      >
                        <i v-if="task.progress === 100" class="pi pi-check text-[10px]" />
                      </button>
                      <div class="min-w-0">
                        <p
                          class="text-sm font-semibold"
                          :class="task.progress === 100 ? 'text-surface-400 line-through' : 'text-surface-900'"
                        >
                          {{ task.title }}
                        </p>
                        <p class="mt-1 text-xs text-surface-500">{{ task.campaign }}</p>
                      </div>
                    </div>
                    <div class="flex items-center gap-4 pl-8 sm:pl-0">
                      <div class="w-36">
                        <div class="mb-1 flex justify-between text-[11px] text-surface-500">
                          <span>Tiến độ</span>
                          <span>{{ task.progress }}%</span>
                        </div>
                        <ProgressBar :value="task.progress" :show-value="false" class="h-1.5" />
                      </div>
                      <Tag :value="task.status" :severity="task.severity" rounded />
                    </div>
                  </div>
                </div>
              </template>
            </Card>
          </section>

          <footer class="mt-8 text-center text-xs text-surface-400">
            Cashbackly · Theo dõi ưu đãi thẻ tín dụng dễ dàng hơn
          </footer>
        </div>
      </main>
    </div>
  </div>
</template>
