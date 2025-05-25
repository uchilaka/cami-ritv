import { useCallback, useEffect, useState } from 'react'
import { getFeatureFlags } from '../api'

export type FEATURE_FLAGS =
  | 'editable_phone_numbers'
  | 'filterable_billing_type_badge'
  | 'account_filtering'
  | 'account_context_menu'
  | 'invoice_filtering'
  | 'invoice_filtering_by_account'
  | 'invoice_filtering_by_status'
  | 'invoice_filtering_by_due_date'
  | 'invoice_filtering_by_amount'
  | 'invoice_sortable_by_account'
  | 'invoice_sortable_by_due_date'
  | 'invoice_sortable_by_status'
  | 'invoice_bulk_actions'
  | 'invoice_search'
  | 'sortable_invoice_index'
  | 'stripe_invoicing'
  | 'hubspot_invoicing'

export interface FeatureFlagsProps {
  error: Error | unknown
  flags: Record<string, boolean>
  refetch: () => Promise<Record<string, boolean> | null>
  isEnabled: (...flags: FEATURE_FLAGS[]) => boolean
  loading?: boolean
}

const useFeatureFlags = (): FeatureFlagsProps => {
  const [loading, setLoading] = useState<boolean>()
  const [error, setError] = useState<Error | unknown>()
  const [flags, setFlags] = useState<Record<string, boolean>>({})

  const isEnabled = useCallback(
    (...checkFlags: FEATURE_FLAGS[]) => {
      return checkFlags.every((flag) => !!flags[`feat__${flag}`])
    },
    [flags],
  )

  const asyncFetch = async () => {
    try {
      setLoading(true)
      const latestFlags = await getFeatureFlags()
      setFlags(latestFlags)
      return latestFlags
    } catch (err) {
      setError(err)
      return null
    } finally {
      setLoading(false)
    }
  }

  console.debug({ loading, flags })

  useEffect(() => {
    asyncFetch()
  }, [])

  return { loading, error, flags, refetch: asyncFetch, isEnabled }
}

export default useFeatureFlags
