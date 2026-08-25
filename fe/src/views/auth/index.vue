<script setup lang="ts">
import { nextTick, onMounted, ref } from 'vue'
import Button from 'primevue/button'
import { useRouter } from 'vue-router'
import LoginForm from './components/LoginForm.vue'
import RegisterForm from './components/RegisterForm.vue'

type AuthMode = 'login' | 'register'

type AuthForm = {
  focusFirstInput: () => void
}

interface RegisteredPayload {
  email: string
  message: string
}

const router = useRouter()
const activeMode = ref<AuthMode>('login')
const activeAuthForm = ref<AuthForm | null>(null)
const registeredEmail = ref('')
const registerSuccessMessage = ref('')

function selectMode(mode: AuthMode): void {
  activeMode.value = mode

  if (mode === 'register') {
    registerSuccessMessage.value = ''
  }

  focusActiveInput()
}

function focusActiveInput(): void {
  void nextTick(() => {
    activeAuthForm.value?.focusFirstInput()
  })
}

function handleRegistered(payload: RegisteredPayload): void {
  registeredEmail.value = payload.email
  registerSuccessMessage.value = payload.message
  selectMode('login')
}

function handleGoogleLogin(): void {
  router.push('/my-cards')
}

onMounted(focusActiveInput)
</script>

<template>
  <main class="min-h-screen bg-white text-surface-900">
    <div class="grid min-h-screen w-full lg:grid-cols-[1.05fr_0.95fr]">
      <section class="relative hidden min-h-screen overflow-hidden bg-[#18324a] p-10 text-white lg:flex lg:flex-col lg:justify-center xl:p-14">
        <div class="absolute -right-24 -top-24 h-72 w-72 rounded-full bg-primary-400/20 blur-3xl" />
        <div class="absolute -bottom-32 -left-20 h-80 w-80 rounded-full bg-cyan-300/10 blur-3xl" />

        <div class="relative ml-auto mr-8 w-full max-w-md xl:mr-16">
          <div class="flex items-center gap-3">
            <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-white/12 ring-1 ring-white/20">
              <i class="pi pi-bolt text-lg text-primary-200" />
            </div>
            <div>
              <p class="text-sm font-bold tracking-tight">Cashbackly</p>
              <p class="text-[10px] text-slate-300">Daily card tracker</p>
            </div>
          </div>

          <div class="mt-16 max-w-sm">
            <p class="text-xs font-semibold uppercase tracking-[0.18em] text-primary-200">Tập trung vào việc cần làm</p>
            <h1 class="mt-4 text-4xl font-bold leading-tight tracking-tight xl:text-5xl">
              Đừng bỏ lỡ một khoản cashback nào.
            </h1>
            <p class="mt-5 text-sm leading-7 text-slate-300">
              Theo dõi tiến độ chi tiêu, điều kiện và ngày nhận hoàn tiền của tất cả thẻ trong một nơi.
            </p>
          </div>
        </div>

        <p class="relative ml-auto mr-8 mt-16 w-full max-w-md text-xs text-slate-400 xl:mr-16">Quản lý thẻ dễ hơn, tận dụng cashback tốt hơn.</p>
      </section>

      <section class="flex min-h-screen items-center p-6 sm:p-10 lg:p-12 xl:p-16">
        <div class="mx-auto w-full max-w-sm lg:ml-12 lg:mr-0 lg:max-w-sm xl:ml-16">
          <div class="mb-8 grid grid-cols-2 border-b border-surface-200">
            <button
              type="button"
              class="cursor-pointer border-b-2 px-3 pb-3 text-sm font-bold transition-colors"
              :class="activeMode === 'login' ? 'border-primary text-surface-900' : 'border-transparent text-surface-400 hover:text-surface-700'"
              @click="selectMode('login')"
            >
              Đăng nhập
            </button>
            <button
              type="button"
              class="cursor-pointer border-b-2 px-3 pb-3 text-sm font-bold transition-colors"
              :class="activeMode === 'register' ? 'border-primary text-surface-900' : 'border-transparent text-surface-400 hover:text-surface-700'"
              @click="selectMode('register')"
            >
              Đăng ký
            </button>
          </div>

          <div class="mb-8 lg:hidden">
            <div class="flex items-center gap-3">
              <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-primary text-primary-contrast shadow-sm shadow-primary/20">
                <i class="pi pi-bolt text-lg" />
              </div>
              <div>
                <p class="text-sm font-bold tracking-tight text-surface-900">Cashbackly</p>
                <p class="text-[10px] text-surface-400">Daily card tracker</p>
              </div>
            </div>
          </div>

          <div>
            <div v-if="activeMode === 'login'">
              <p class="text-sm font-medium text-primary-600">Chào mừng trở lại</p>
              <h2 class="mt-2 text-3xl font-bold tracking-tight text-surface-950">Đăng nhập</h2>
              <p class="mt-3 text-sm leading-6 text-surface-500">Đăng nhập để tiếp tục theo dõi các thẻ và chiến dịch của bạn.</p>
            </div>
            <div v-else>
              <p class="text-sm font-medium text-primary-600">Tham gia Cashbackly</p>
              <h2 class="mt-2 text-3xl font-bold tracking-tight text-surface-950">Tạo tài khoản</h2>
              <p class="mt-3 text-sm leading-6 text-surface-500">Lưu lại các thẻ và bắt đầu theo dõi cashback của bạn.</p>
            </div>

            <Transition name="auth-panel" mode="out-in" @after-enter="focusActiveInput">
              <KeepAlive>
                <LoginForm
                  v-if="activeMode === 'login'"
                  ref="activeAuthForm"
                  :initial-email="registeredEmail"
                  :success-message="registerSuccessMessage"
                />
                <RegisterForm
                  v-else
                  ref="activeAuthForm"
                  @registered="handleRegistered"
                />
              </KeepAlive>
            </Transition>
          </div>

          <div class="my-6 flex items-center gap-3 text-xs text-surface-400">
            <span class="h-px flex-1 bg-surface-200" />
            <span>HOẶC</span>
            <span class="h-px flex-1 bg-surface-200" />
          </div>

          <button type="button" class="flex w-full cursor-pointer items-center justify-center gap-2 rounded-lg border border-surface-300 bg-white px-4 py-2.5 text-sm font-medium text-surface-700 transition-colors hover:bg-surface-50" @click="handleGoogleLogin">
            <span class="text-base font-bold text-[#4285f4]">G</span>
            Tiếp tục với Google
          </button>
        </div>
      </section>
    </div>
  </main>
</template>

<style scoped>
.auth-panel-enter-active,
.auth-panel-leave-active {
  transition:
    opacity 50ms ease,
    transform 50ms ease;
}

.auth-panel-enter-from {
  opacity: 0;
  transform: translateY(6px);
}

.auth-panel-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

@media (prefers-reduced-motion: reduce) {
  .auth-panel-enter-active,
  .auth-panel-leave-active {
    transition-duration: 0.01ms;
  }
}
</style>
