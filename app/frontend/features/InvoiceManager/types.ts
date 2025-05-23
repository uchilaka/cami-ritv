import { AppGlobalProps } from '@/utils'
import { GenericAccount } from '@/utils/api/GenericAccount'

export type VendorType = 'paypal' | 'hubspot' | 'stripe'

type ActionKey = 'show' | 'back'

// TODO: Refactor InvoiceAction and AccountAction to generic ResourceAction
export interface InvoiceAction {
  domId: string
  httpMethod: 'GET' | 'POST' | 'PUT' | 'DELETE'
  label: string
  url: string
}

interface InvoiceAmount {
  value: number
  formattedValue: string
  currencyCode: string
}

export interface Invoice {
  id: string
  vendorRecordId: string
  paymentVendor: 'paypal' | 'stripe'
  createdAt: Date
  dueAt: Date
  updatedAt: Date
  number: string
  status: 'PAID' | 'OVERDUE' | 'SENT' | 'CANCELLED' | 'DRAFT' | 'PARTIALLY_PAID'
  amount: InvoiceAmount
  paidAt?: Date
  // eslint-disable-next-line no-use-before-define
  account?: GenericAccount
  isRecurring?: boolean
  tooltipId?: string
  itemActionBtnClasses?: string
  paymentVendorURL: string
  actions: Record<ActionKey, InvoiceAction>
}

type SortKey = keyof Pick<Invoice, 'account' | 'status' | 'dueAt' | 'paidAt' | 'amount'> | 'account.email' | 'account.displayName'
type FilterKey = 'status' | 'invoiceNumber' | 'account.displayName' | 'account.email'

export interface InvoiceSearchProps {
  // Sorting
  s: Partial<Record<SortKey, 'asc' | 'desc' | null>>
  // Filtering
  f: Partial<Record<FilterKey, string>>
  // (Full-text search) query string
  q: string
}

interface FindInvoiceOptions {
  signal: AbortSignal
}

export type InvoicesLoaderFn = (params: Partial<InvoiceSearchProps>, options?: Partial<FindInvoiceOptions>) => Promise<Invoice[]>
