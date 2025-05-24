import { getAccount } from '@/utils/api'
import { BusinessAccount, IndividualAccount } from '@/utils/api/types'
import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'

export const useAccountSummaryQuery = (accountId?: string) => {
  const [account, setAccount] = useState<IndividualAccount | BusinessAccount | null>(null)

  const query = useQuery({
    queryKey: ['accountSummary', accountId],
    queryFn: async () => {
      if (!accountId) return null

      const data = await getAccount(accountId)
      // TODO: test to make sure we're not firing this more times than we need to
      setAccount(data)
      // TODO: Add error handling for account summary query
      return data
    },
  })

  return { query, account }
}

export default useAccountSummaryQuery
