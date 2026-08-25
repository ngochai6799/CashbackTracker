<script setup lang="ts">
import { nextTick, onActivated, onMounted, ref, watch } from 'vue'
import Button from 'primevue/button'
import Checkbox from 'primevue/checkbox'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import { useRouter } from 'vue-router'
import {
  loginAccount,
  saveLoginSession,
  type AuthApiError,
} from '@/services/authService'

interface Props {
  initialEmail?: string
  successMessage?: string
}

type FocusableComponent = {
  $el: HTMLElement
}

const props = withDefaults(defineProps<Props>(), {
  initialEmail: '',
  successMessage: '',
})

const router = useRouter()
const loginEmailInput = ref<FocusableComponent | null>(null)
const loginEmail = ref(props.initialEmail)
const loginPassword = ref('')
const rememberMe = ref(true)
const loginSubmitted = ref(false)
const isLoggingIn = ref(false)
const loginError = ref('')

watch(
  () => props.initialEmail,
  (email) => {
    if (email) {
      loginEmail.value = email
    }
  },
)

function focusFirstInput(): void {
  void nextTick(() => {
    loginEmailInput.value?.$el.focus()
  })
}

async function handleSubmit(): Promise<void> {
  loginSubmitted.value = true
  loginError.value = ''

  if (!loginEmail.value.trim() || !loginPassword.value) return

  isLoggingIn.value = true

  try {
    const response = await loginAccount({
      email: loginEmail.value.trim().toLowerCase(),
      password: loginPassword.value,
    })

    saveLoginSession(response)
    await router.push('/my-cards')
  } catch (error: unknown) {
    const apiError = error as AuthApiError
    loginError.value = apiError.message || 'Không thể đăng nhập lúc này.'
  } finally {
    isLoggingIn.value = false
  }
}

defineExpose({ focusFirstInput })

onMounted(focusFirstInput)
onActivated(focusFirstInput)
</script>

<template>
  <form class="mt-8 space-y-5" @submit.prevent="handleSubmit">
    <p
      v-if="successMessage"
      class="rounded-lg bg-emerald-50 px-3 py-2 text-sm text-emerald-700"
    >
      {{ successMessage }}
    </p>

    <p
      v-if="loginError"
      class="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600"
    >
      {{ loginError }}
    </p>

    <div>
      <label for="auth-login-email" class="mb-2 block cursor-pointer text-sm font-medium text-surface-700">Email</label>
      <InputText
        ref="loginEmailInput"
        id="auth-login-email"
        v-model="loginEmail"
        type="email"
        autocomplete="email"
        placeholder="you@example.com"
        class="w-full"
        :invalid="loginSubmitted && !loginEmail.trim()"
      />
      <small v-if="loginSubmitted && !loginEmail.trim()" class="mt-1 block text-xs text-red-500">Vui lòng nhập email.</small>
    </div>

    <div>
      <label for="auth-login-password" class="mb-2 block cursor-pointer text-sm font-medium text-surface-700">Mật khẩu</label>
      <Password
        id="auth-login-password"
        v-model="loginPassword"
        input-id="auth-login-password-input"
        autocomplete="current-password"
        placeholder="Nhập mật khẩu"
        :feedback="false"
        toggle-mask
        class="w-full"
        input-class="w-full"
        :invalid="loginSubmitted && !loginPassword"
      />
      <small v-if="loginSubmitted && !loginPassword" class="mt-1 block text-xs text-red-500">Vui lòng nhập mật khẩu.</small>
    </div>

    <div class="flex items-center justify-between gap-4">
      <div class="flex items-center gap-2 text-sm text-surface-600">
        <Checkbox input-id="auth-remember-me" v-model="rememberMe" binary />
        <label for="auth-remember-me" class="cursor-pointer">Ghi nhớ</label>
      </div>
      <button type="button" class="cursor-pointer text-sm font-medium text-primary-600 transition-colors hover:text-primary-700">
        Quên mật khẩu?
      </button>
    </div>

    <Button
      type="submit"
      label="Đăng nhập"
      icon="pi pi-arrow-right"
      icon-pos="right"
      :loading="isLoggingIn"
      :disabled="isLoggingIn"
      class="w-full cursor-pointer"
    />
  </form>
</template>
