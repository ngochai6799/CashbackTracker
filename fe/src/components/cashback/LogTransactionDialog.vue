<script setup>
import { ref, watch } from 'vue'
import Button from 'primevue/button'
import Dialog from 'primevue/dialog'
import InputNumber from 'primevue/inputnumber'
import InputText from 'primevue/inputtext'

const props = defineProps({
  visible: {
    type: Boolean,
    required: true,
  },
  task: {
    type: Object,
    default: null,
  },
})

const emit = defineEmits(['update:visible', 'save'])
const entryAmount = ref(null)
const entryMerchant = ref('')

watch(
  () => props.visible,
  (visible) => {
    if (visible) {
      entryAmount.value = null
      entryMerchant.value = ''
    }
  },
)

function close() {
  emit('update:visible', false)
}

function save() {
  if (!entryAmount.value) return

  emit('save', {
    amount: entryAmount.value,
    merchant: entryMerchant.value,
  })
}
</script>

<template>
  <Dialog :visible="visible" modal header="Ghi giao dịch" :style="{ width: '28rem' }" @update:visible="emit('update:visible', $event)">
    <div v-if="task" class="space-y-5">
      <div class="rounded-xl bg-surface-50 p-3">
        <p class="text-xs text-surface-500">Cập nhật task</p>
        <p class="mt-1 text-sm font-semibold text-surface-900">{{ task.title }}</p>
      </div>
      <div>
        <label for="merchant" class="mb-2 block text-sm font-medium text-surface-700">Nơi giao dịch</label>
        <InputText id="merchant" v-model="entryMerchant" class="w-full" placeholder="Ví dụ: WinMart, Highlands..." />
      </div>
      <div>
        <label for="amount" class="mb-2 block text-sm font-medium text-surface-700">Số tiền</label>
        <InputNumber
          id="amount"
          v-model="entryAmount"
          mode="currency"
          currency="VND"
          locale="vi-VN"
          class="w-full"
          input-class="w-full"
        />
      </div>
      <div class="flex justify-end gap-2">
        <Button label="Hủy" text severity="secondary" @click="close" />
        <Button label="Lưu" icon="pi pi-check" :disabled="!entryAmount" @click="save" />
      </div>
    </div>
  </Dialog>
</template>
