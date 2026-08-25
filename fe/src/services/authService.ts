import http, { ACCESS_TOKEN_KEY } from './httpClient'

export interface RegisterRequest {
  name: string
  email: string
  password: string
  confirmPassword: string
}

export interface RegisteredUser {
  id: number
  name: string
  email: string
  isActive: boolean
  emailVerified: boolean
  createdAt: string
}

export interface RegisterResponse {
  message: string
  data: {
    user: RegisteredUser
  }
}

export interface LoginRequest {
  email: string
  password: string
}

export interface LoginResponse {
  message: string
  data: {
    accessToken: string
    tokenType: string
    expiresIn: string
    user: RegisteredUser
  }
}

export interface RegisterValidationErrors {
  name?: string
  email?: string
  password?: string
  confirmPassword?: string
}

export interface RegisterApiErrorData {
  errors?: RegisterValidationErrors
}

export interface RegisterApiError {
  message?: string
  data?: RegisterApiErrorData
}

export interface AuthApiError {
  message?: string
}

export async function registerAccount(payload: RegisterRequest): Promise<RegisterResponse> {
  return await http.post<RegisterResponse>('/api/auth/register', payload)
}

export async function loginAccount(payload: LoginRequest): Promise<LoginResponse> {
  return await http.post<LoginResponse>('/api/auth/login', payload)
}

export function saveLoginSession(response: LoginResponse): void {
  localStorage.setItem(ACCESS_TOKEN_KEY, response.data.accessToken)
  localStorage.setItem('auth_user', JSON.stringify(response.data.user))
}
