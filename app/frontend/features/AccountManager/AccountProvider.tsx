import React, { ComponentType, createContext, Dispatch, SetStateAction, useCallback, useContext, useEffect, useState } from 'react'
import { BusinessAccount, IndividualAccount } from '@/utils/api/types'
import { LoadAccountEventDetail, nsEventName } from '@/utils'
import useAccountSummaryQuery from './hooks/useAccountQuery'

interface AccountContextProps {
  listenForAccountLoadEvents: () => AbortController
  setAccountId: Dispatch<SetStateAction<string | undefined>>
  reload: () => Promise<void>
  loading?: boolean
  account?: IndividualAccount | BusinessAccount | null
}

const AccountContext = createContext<AccountContextProps>(null!)

export const useAccountContext = () => useContext(AccountContext)

export const AccountProvider = ({ children }: { children: React.ReactNode }) => {
  const [accountId, setAccountId] = useState<string>()
  const [loading, setLoading] = useState<boolean>()
  const { account, query } = useAccountSummaryQuery(accountId)

  const reload = useCallback(async () => {
    console.debug(`Loading account: ${accountId}`)
    setLoading(true)
    const result = await query.refetch()
    console.debug({ result })
    if (result.isSuccess) setLoading(false)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [query, accountId])

  const listenForAccountLoadEvents = () => {
    const accountLoader = new AbortController()
    document.addEventListener(
      nsEventName('account:load'),
      (ev) => {
        const { detail } = ev as CustomEvent<LoadAccountEventDetail>
        console.debug(`Received request to load account: ${detail.accountId}`)
        setAccountId(detail.accountId)
      },
      /**
       * https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener#options
       */
      { capture: true, passive: true, signal: accountLoader.signal },
    )
    return accountLoader
  }

  useEffect(() => {
    if (accountId) reload()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [accountId])

  console.debug('AccountProvider:', { account })

  return (
    <AccountContext.Provider value={{ loading, account, reload, listenForAccountLoadEvents, setAccountId }}>
      {children}
    </AccountContext.Provider>
  )
}

export const withAccountProvider = <P extends {}>(WrappedComponent: ComponentType<P>) => {
  const displayName = WrappedComponent.displayName ?? WrappedComponent.name ?? 'Component'
  /**
   * TODO: Should the ComponentWithAccountProvider `props` type be `P` instead of `any`?
   */
  const ComponentWithAccountProvider = (props: any) => {
    /**
     * React query functions: https://tanstack.com/query/latest/docs/framework/react/guides/query-functions
     * - variables: https://tanstack.com/query/latest/docs/framework/react/guides/query-functions#query-function-variables   * React query options: https://tanstack.com/query/latest/docs/framework/react/guides/query-options
     * Using react query with fetch: https://tanstack.com/query/latest/docs/framework/react/guides/query-functions#usage-with-fetch-and-other-clients-that-do-not-throw-by-default
     */
    return (
      <AccountProvider>
        <WrappedComponent {...props} />
      </AccountProvider>
    )
  }
  ComponentWithAccountProvider.displayName = `withAccountProvider(${displayName})`
  return ComponentWithAccountProvider
}

export default AccountProvider
