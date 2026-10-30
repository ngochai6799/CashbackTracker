<script setup lang="ts">
import LeftSidebar from './components/LeftSidebar.vue'
import ParticipatingCardsSection from './components/ParticipatingCardsSection.vue'
import { useCashbackDashboard } from './composables/useCashbackDashboard'

const {
  cards,
  cardCount,
  isLoading,
  error,
  loadCards,
} = useCashbackDashboard()
</script>

<template>
  <main class="min-h-screen bg-surface-50 text-surface-900">
    <div class="grid min-h-screen w-full xl:grid-cols-[15rem_minmax(0,1fr)]">
      <LeftSidebar
        :card-count="cardCount"
      />

      <div class="min-w-0 flex-1">
        <div class="px-4 py-6 sm:px-6 sm:py-10">
          <ParticipatingCardsSection
            :cards="cards"
            :is-loading="isLoading"
            :error="error"
            @retry="loadCards"
          />

          <p class="mt-10 text-center text-xs text-surface-400">Cashbackly · Theo dõi các chương trình đang tham gia</p>
        </div>
      </div>
    </div>
  </main>
</template>
