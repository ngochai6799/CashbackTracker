<script setup lang="ts">
import { nextTick, onActivated, onMounted, ref } from 'vue'
import Button from 'primevue/button'
import Checkbox from 'primevue/checkbox'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import {
  registerAccount,
  type RegisterApiError,
  type RegisterValidationErrors,
} from '@/services/authService'

type FocusableComponent = {
  $el: HTMLElement
}

interface RegisteredPayload {
  email: string
  message: string
}

const emit = defineEmits<{
  registered: [payload: RegisteredPayload]
}>()

const registerNameInput = ref<FocusableComponent | null>(null)
const registerName = ref('')
const registerEmail = ref('')
const registerPassword = ref('')
const confirmPassword = ref('')
const agreeToTerms = ref(false)
const registerSubmitted = ref(false)
const isRegistering = ref(false)
const registerError = ref('')
const registerFieldErrors = ref<RegisterValidationErrors>({})

function focusFirstInput(): void {
  void nextTick(() => {
    registerNameInput.value?.$el.focus()
  })
}

function clearErrors(): void {
  registerSubmitted.value = false
  registerError.value = ''
  registerFieldErrors.value = {}
}

async function handleSubmit(): Promise<void> {
  registerSubmitted.value = true
  registerError.value = ''
  registerFieldErrors.value = {}

  if (
    !registerName.value.trim()
    || !registerEmail.value.trim()
    || registerPassword.value.length < 6
    || registerPassword.value !== confirmPassword.value
    || !agreeToTerms.value
  ) {
    return
  }

  isRegistering.value = true

  try {
    const normalizedEmail = registerEmail.value.trim().toLowerCase()
    const response = await registerAccount({
      name: registerName.value.trim(),
      email: normalizedEmail,
      password: registerPassword.value,
      confirmPassword: confirmPassword.value,
    })

    registerPassword.value = ''
    confirmPassword.value = ''
    agreeToTerms.value = false

    emit('registered', {
      email: normalizedEmail,
      message: `${response.message} Bạn có thể đăng nhập ngay bây giờ.`,
    })
  } catch (error: unknown) {
    const apiError = error as RegisterApiError

    registerError.value = apiError.message || 'Không thể tạo tài khoản lúc này.'
    registerFieldErrors.value = apiError.data?.errors || {}
  } finally {
    isRegistering.value = false
  }
}

defineExpose({ focusFirstInput, clearErrors })

onMounted(focusFirstInput)
onActivated(() => {
  clearErrors()
  focusFirstInput()
})
</script>

<template>
  <form class="mt-8 space-y-4" @submit.prevent="handleSubmit">
    <p
      v-if="registerError"
      class="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600"
    >
      {{ registerError }}
    </p>

    <div>
      <label for="auth-register-name" class="mb-2 block cursor-pointer text-sm font-medium text-surface-700">Họ và tên</label>
      <InputText
        ref="registerNameInput"
        id="auth-register-name"
        v-model="registerName"
        autocomplete="name"
        placeholder="Nguyễn Văn A"
        class="w-full"
        :invalid="registerSubmitted && (!registerName.trim() || !!registerFieldErrors.name)"
      />
      <small v-if="registerFieldErrors.name" class="mt-1 block text-xs text-red-500">{{ registerFieldErrors.name }}</small>
      <small v-else-if="registerSubmitted && !registerName.trim()" class="mt-1 block text-xs text-red-500">Vui lòng nhập họ tên.</small>
    </div>

    <div>
      <label for="auth-register-email" class="mb-2 block cursor-pointer text-sm font-medium text-surface-700">Email</label>
      <InputText
        id="auth-register-email"
        v-model="registerEmail"
        type="email"
        autocomplete="email"
        placeholder="you@example.com"
        class="w-full"
        :invalid="registerSubmitted && (!registerEmail.trim() || !!registerFieldErrors.email)"
      />
      <small v-if="registerFieldErrors.email" class="mt-1 block text-xs text-red-500">{{ registerFieldErrors.email }}</small>
      <small v-else-if="registerSubmitted && !registerEmail.trim()" class="mt-1 block text-xs text-red-500">Vui lòng nhập email.</small>
    </div>

    <div>
      <label for="auth-register-password" class="mb-2 block cursor-pointer text-sm font-medium text-surface-700">Mật khẩu</label>
      <Password
        id="auth-register-password"
        v-model="registerPassword"
        input-id="auth-register-password-input"
        autocomplete="new-password"
        placeholder="Tối thiểu 6 ký tự"
        :feedback="false"
        toggle-mask
        class="w-full"
        input-class="w-full"
        :invalid="registerSubmitted && (registerPassword.length < 6 || !!registerFieldErrors.password)"
      />
      <small v-if="registerFieldErrors.password" class="mt-1 block text-xs text-red-500">{{ registerFieldErrors.password }}</small>
      <small v-else-if="registerSubmitted && registerPassword.length < 6" class="mt-1 block text-xs text-red-500">Mật khẩu cần ít nhất 6 ký tự.</small>
    </div>

    <div>
      <label for="auth-confirm-password" class="mb-2 block cursor-pointer text-sm font-medium text-surface-700">Xác nhận mật khẩu</label>
      <Password
        id="auth-confirm-password"
        v-model="confirmPassword"
        input-id="auth-confirm-password-input"
        autocomplete="new-password"
        placeholder="Nhập lại mật khẩu"
        :feedback="false"
        toggle-mask
        class="w-full"
        input-class="w-full"
        :invalid="registerSubmitted && (registerPassword !== confirmPassword || !!registerFieldErrors.confirmPassword)"
      />
      <small v-if="registerFieldErrors.confirmPassword" class="mt-1 block text-xs text-red-500">{{ registerFieldErrors.confirmPassword }}</small>
      <small v-else-if="registerSubmitted && registerPassword !== confirmPassword" class="mt-1 block text-xs text-red-500">Mật khẩu xác nhận chưa khớp.</small>
    </div>

    <div class="flex items-start gap-2 pt-1 text-xs leading-5 text-surface-600">
      <Checkbox input-id="auth-agree-terms" v-model="agreeToTerms" binary :invalid="registerSubmitted && !agreeToTerms" />
      <label for="auth-agree-terms" class="cursor-pointer">Tôi đồng ý với điều khoản sử dụng và chính sách bảo mật.</label>
    </div>
    <small v-if="registerSubmitted && !agreeToTerms" class="-mt-2 block text-xs text-red-500">Bạn cần đồng ý để tiếp tục.</small>

    <Button
      type="submit"
      label="Tạo tài khoản"
      icon="pi pi-arrow-right"
      icon-pos="right"
      :loading="isRegistering"
      :disabled="isRegistering"
      class="w-full cursor-pointer"
    />
  </form>
</template>
