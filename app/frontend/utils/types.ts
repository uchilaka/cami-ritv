import { Invoice } from '@/features/InvoiceManager/types'
import { BusinessAccount, IndividualAccount } from './api/types'
import { StoreApi } from 'zustand'
import { AppStore, createAppStoreWithDevtools } from '@/utils/store'

/**
 * Event detail types should support state composition i.e. if we
 * merged them all together, there should still be the integrity
 * of the data slices within each of them.
 */
export type LoadAccountEventDetail = {
  accountId: string
}

export type LoadInvoiceEventDetail = {
  invoiceId: string
}

export type LoadedAccountEventDetail = {
  account: IndividualAccount | BusinessAccount
}

export type LoadedInvoiceEventDetail = {
  invoice: Invoice
}

export interface AppGlobalProps {
  appStore: ReturnType<typeof createAppStoreWithDevtools>
}
