export const STORAGE_KEYS = {
  accessToken: 'access_token',
  authUser: 'auth_user',
} as const

export function getLocalStorageItem(key: string): string | null {
  if (typeof localStorage === 'undefined') return null

  return localStorage.getItem(key)
}

export function setLocalStorageItem(key: string, value: string): void {
  if (typeof localStorage === 'undefined') return

  localStorage.setItem(key, value)
}

export function removeLocalStorageItem(key: string): void {
  if (typeof localStorage === 'undefined') return

  localStorage.removeItem(key)
}

export function setLocalStorageJson<T>(key: string, value: T): void {
  setLocalStorageItem(key, JSON.stringify(value))
}

export function getLocalStorageJson<T>(key: string): T | null {
  const value = getLocalStorageItem(key)

  if (!value) return null

  try {
    return JSON.parse(value) as T
  } catch {
    removeLocalStorageItem(key)
    return null
  }
}

export function clearAuthStorage(): void {
  Object.values(STORAGE_KEYS).forEach(removeLocalStorageItem)
}
