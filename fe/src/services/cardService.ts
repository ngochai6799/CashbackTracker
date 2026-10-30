import http from '../lib/httpClient'

export interface Card {
  id: number
  issuer: string
  cardName: string
  lastFour: string | null
  annualFee: number
  currency: string
  isActive: boolean
  createdAt: string
}

export interface GetCardsResponse {
  message: string
  data: {
    cards: Card[]
  }
}

export async function getCards(): Promise<GetCardsResponse> {
  return await http.get<GetCardsResponse>('/api/cards')
}
