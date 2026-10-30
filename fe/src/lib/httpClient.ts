import axios, { type AxiosRequestConfig, type InternalAxiosRequestConfig } from 'axios'
import router from '@/router'
import {
  clearAuthStorage,
  getLocalStorageItem,
  STORAGE_KEYS,
} from '../utils/storage'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL
const API_TIMEOUT = Number(import.meta.env.VITE_API_TIMEOUT)
const WITH_CREDENTIALS = import.meta.env.VITE_API_WITH_CREDENTIALS === 'true'
let isRedirectingToAuth = false

interface ApiErrorOptions {
  message: string
  status: number | null
  data: unknown
  code: string | null
  method: string | null
  url: string | null
  originalError: unknown
}

interface ApiErrorPayload {
  message?: string
  error?: string
  data?: unknown
}

export class ApiError extends Error {
  status: number | null
  data: unknown
  code: string | null
  method: string | null
  url: string | null
  originalError: unknown

  constructor({ message, status, data, code, method, url, originalError }: ApiErrorOptions) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.data = data
    this.code = code
    this.method = method
    this.url = url
    this.originalError = originalError
  }
}

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  withCredentials: WITH_CREDENTIALS,
  headers: {
    Accept: 'application/json',
  },
})

function setHeader(config: InternalAxiosRequestConfig, name: string, value: string): void {
  if (typeof config.headers?.set === 'function') {
    config.headers.set(name, value)
    return
  }

  config.headers = config.headers || {}
  const headers = config.headers as unknown as Record<string, string>
  headers[name] = value
}

function normalizeError(error: unknown): ApiError {
  const axiosError = axios.isAxiosError(error) ? error : null
  const responseData = axiosError?.response?.data as ApiErrorPayload | undefined
  const message =
    responseData?.message ||
    responseData?.error ||
    (error instanceof Error ? error.message : '') ||
    'Không thể kết nối tới máy chủ.'

  return new ApiError({
    message,
    status: axiosError?.response?.status || null,
    data: responseData?.data ?? null,
    code: axiosError?.code || null,
    method: axiosError?.config?.method?.toUpperCase() || null,
    url: axiosError?.config?.url || null,
    originalError: error,
  })
}

function isAuthRequest(url: string | null): boolean {
  return Boolean(url && /\/api\/auth(?:\/|$)/.test(url))
}

function redirectToAuth(): void {
  if (isRedirectingToAuth || router.currentRoute.value.name === 'auth') return

  isRedirectingToAuth = true

  void router.replace({ name: 'auth' }).finally(() => {
    isRedirectingToAuth = false
  })
}

apiClient.interceptors.request.use(
  (config) => {
    const accessToken = getLocalStorageItem(STORAGE_KEYS.accessToken)

    if (accessToken) {
      setHeader(config, 'Authorization', `Bearer ${accessToken}`)
    }

    return config
  },
  (error) => Promise.reject(error),
)

apiClient.interceptors.response.use(
  (response) => response,
  (error: unknown) => {
    const apiError = normalizeError(error)

    if (
      apiError.status === 401 &&
      typeof window !== 'undefined' &&
      !isAuthRequest(apiError.url)
    ) {
      clearAuthStorage()
      redirectToAuth()
    }

    return Promise.reject(apiError)
  },
)

async function request<T>(config: AxiosRequestConfig): Promise<T> {
  const response = await apiClient.request<T>(config)
  return response.data
}

export const http = {
  request,

  get<T = unknown>(url: string, config: AxiosRequestConfig = {}): Promise<T> {
    return request<T>({ ...config, method: 'get', url })
  },

  post<T = unknown>(url: string, data?: unknown, config: AxiosRequestConfig = {}): Promise<T> {
    return request<T>({ ...config, method: 'post', url, data })
  },

  put<T = unknown>(url: string, data?: unknown, config: AxiosRequestConfig = {}): Promise<T> {
    return request<T>({ ...config, method: 'put', url, data })
  },

  patch<T = unknown>(url: string, data?: unknown, config: AxiosRequestConfig = {}): Promise<T> {
    return request<T>({ ...config, method: 'patch', url, data })
  },

  delete<T = unknown>(url: string, config: AxiosRequestConfig = {}): Promise<T> {
    return request<T>({ ...config, method: 'delete', url })
  },
}

export default http
