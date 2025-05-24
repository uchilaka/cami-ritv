import { InvalidAccountError } from '../../../utils/errors'
import { isValidAccount } from '../../../utils/api/types'

// import { request } from '@/utils/gaxios'
// import { BusinessAccount, IndividualAccount } from './types'

export const getAccount = async (accountId: string, payload?: Record<string, string>) => {
  // TODO: Implement API call to fetch account data via gaxios with a feature flag
  // return await request<BusinessAccount | IndividualAccount>({ url: `/account/${accountId}` })
  const params = new URLSearchParams(payload ?? {})
  params.append('format', 'json')

  /**
   * The benefit of using gaxios is more configuration features for the request boundary
   * our of the box (vs. fetch). That said, worth looking into doing that with react query
   * (which is new to me at the time of writing this comment) since we already have that in
   * here, and still would even if we used gaxios.
   *
   * Stepping over it for now, but I think this is a good candidate for a refactor.
   *
   * TIP: we can also use /accounts/:id.json to send the format=json query param
   */
  const result = await fetch(`/accounts/${accountId}?${params.toString()}`)
  const data = await result.json()
  if (!isValidAccount(data)) throw new InvalidAccountError('Invalid account data', data)
  return data
}

export default getAccount
