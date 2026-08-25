import { computed } from 'vue'
import { participatingCards } from '../data/cashbackMock'

export function useCashbackDashboard() {
  const cardCount = computed(() => participatingCards.length)

  return {
    participatingCards,
    cardCount,
  }
}
