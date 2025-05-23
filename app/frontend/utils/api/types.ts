import { Invoice } from '@/features/InvoiceManager/types'
import { AccountAction, ActionKey } from '@/features/AccountManager/types'
import { GenericAccount } from './GenericAccount'

interface UserProfile {
  id: string
  givenName?: string
  familyName?: string
  phone?: string
}

interface RichText {
  html: string
  plaintext: string
}

export interface Account extends GenericAccount {
  isVendor: boolean
  actions: Record<ActionKey, AccountAction>
  invoices: Invoice[]
  email?: string
  phone?: string
  readme?: RichText
}

export interface IndividualAccount extends Account {
  type: 'Individual'
  email: string
  profile?: UserProfile
}

export interface BusinessAccount extends Account {
  type: 'Business'
  taxId: string
}

export const isValidAccount = (account?: IndividualAccount | BusinessAccount | null): account is IndividualAccount | BusinessAccount => {
  return !!account && !!account.displayName && !!account.slug && !!account.type
}

export const isActionableAccount = (
  account?: IndividualAccount | BusinessAccount | null,
): account is IndividualAccount | BusinessAccount => {
  return isValidAccount(account) && !!account.actions
}

export const isIndividualAccount = (account?: IndividualAccount | BusinessAccount | null): account is IndividualAccount => {
  return isValidAccount(account) && account.type === 'Individual'
}

export const isBusinessAccount = (account?: IndividualAccount | BusinessAccount | null): account is BusinessAccount => {
  return isValidAccount(account) && account.type === 'Business'
}

export const arrayHasItems = <T>(array: T[] | null | undefined): array is T[] => {
  return Array.isArray(array) && array.length > 0
}
