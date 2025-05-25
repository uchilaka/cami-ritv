export type AccountStatus = 'demo' | 'guest' | 'active' | 'payment_due' | 'overdue' | 'paid' | 'suspended' | 'deactivated'

export type GenericAccount = {
  id: string
  displayName: string
  slug: string
  status: AccountStatus
  email?: string
}
