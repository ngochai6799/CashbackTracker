import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL
const API_TIMEOUT = Number(import.meta.env.VITE_API_TIMEOUT)
const WITH_CREDENTIALS = import.meta.env.VITE_API_WITH_CREDENTIALS === 'true'
const ACCESS_TOKEN_KEY = 'access_token'

export class ApiError extends Error {
  constructor({ message, status, data, code, method, url, originalError }) {
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

function setHeader(config, name, value) {
  if (typeof config.headers?.set === 'function') {
    config.headers.set(name, value)
    return
  }

  config.headers = config.headers || {}
  config.headers[name] = value
}

function normalizeError(error) {
  const responseData = error.response?.data
  const message =
    responseData?.message ||
    responseData?.error ||
    error.message ||
    'Không thể kết nối tới máy chủ.'

  return new ApiError({
    message,
    status: error.response?.status || null,
    data: responseData || null,
    code: error.code || null,
    method: error.config?.method?.toUpperCase() || null,
    url: error.config?.url || null,
    originalError: error,
  })
}

apiClient.interceptors.request.use(
  (config) => {
    const accessToken =
      typeof window !== 'undefined' ? window.localStorage.getItem(ACCESS_TOKEN_KEY) : null

    if (accessToken) {
      setHeader(config, 'Authorization', `Bearer ${accessToken}`)
    }

    return config
  },
  (error) => Promise.reject(error),
)

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    const apiError = normalizeError(error)

    if (apiError.status === 401 && typeof window !== 'undefined') {
      window.dispatchEvent(new CustomEvent('api:unauthorized', { detail: apiError }))
    }

    return Promise.reject(apiError)
  },
)

function request(config) {
  return apiClient.request(config).then((response) => response.data)
}

export const http = {
  request,

  get(url, config = {}) {
    return request({ ...config, method: 'get', url })
  },

  post(url, data, config = {}) {
    return request({ ...config, method: 'post', url, data })
  },

  put(url, data, config = {}) {
    return request({ ...config, method: 'put', url, data })
  },

  patch(url, data, config = {}) {
    return request({ ...config, method: 'patch', url, data })
  },

  delete(url, config = {}) {
    return request({ ...config, method: 'delete', url })
  },
}

export default http
