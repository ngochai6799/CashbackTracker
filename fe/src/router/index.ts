import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      redirect: '/auth',
    },
    {
      path: '/auth',
      name: 'auth',
      component: () => import('@/views/auth/index.vue'),
    },
    {
      path: '/my-cards',
      name: 'my-cards',
      component: () => import('@/views/my-cards/index.vue'),
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/auth',
    },
  ],
})

export default router
