import { Invoice } from '@/features/InvoiceManager/types'

type AccountStatus = 'demo' | 'guest' | 'active' | 'payment_due' | 'overdue' | 'paid' | 'suspended' | 'deactivated'

export interface AccountAction {
  domId: string
  httpMethod: 'GET' | 'POST' | 'PUT' | 'DELETE'
  label: string
  url: string
}

export type ActionKey = 'delete' | 'edit' | 'show' | 'showProfile' | 'profilesIndex' | 'transactionsIndex'

interface RichText {
  html: string
  plaintext: string
}

export interface Account {
  id: string
  displayName: string
  slug: string
  status: AccountStatus
  isVendor: boolean
  actions: Record<ActionKey, AccountAction>
  invoices: Invoice[]
  email?: string
  readme?: RichText
}

export type ProfileFormData = {
  givenName: string
  familyName: string
  phone?: string
}

export type AccountFormData = Partial<ProfileFormData> & {
  displayName: string
  email: string
  type: 'Individual' | 'Business'
  readme?: string
}
