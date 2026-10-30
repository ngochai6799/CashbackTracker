import { computed, onMounted, ref } from 'vue'
import { getCards, type Card } from '@/services/cardService'

export function useCashbackDashboard() {
  const cards = ref<Card[]>([])
  const isLoading = ref(false)
  const error = ref('')

  const cardCount = computed(() => cards.value.length)

  async function loadCards(): Promise<void> {
    isLoading.value = true
    error.value = ''

    try {
      const response = await getCards()
      cards.value = response.data.cards
    } catch (requestError: unknown) {
      const apiError = requestError as { message?: string }
      error.value = apiError.message || 'Không thể tải danh sách thẻ lúc này.'
    } finally {
      isLoading.value = false
    }
  }

  onMounted(loadCards)

  return {
    cards,
    cardCount,
    isLoading,
    error,
    loadCards,
  }
}
