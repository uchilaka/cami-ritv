import { ChangeEvent } from 'react'
import { Account } from '../types'

export interface AccountSlice {
  accountsMap: Record<string, Account>
  selectedAccountsMap: Record<string, boolean>
  /**
   * Reduces the list of accounts to a map of accounts with the account ID as the key
   * @param accounts Account[]
   * @returns void
   */
  setAccounts: (accounts: Account[]) => void
  handleAccountSelectionChange: (ev: ChangeEvent<HTMLInputElement>) => void
}
