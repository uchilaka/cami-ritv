import React, { FC, ReactEventHandler, useCallback, useEffect, useState } from 'react'
import TabLink from './TabLink'
import { useFeatureFlagsContext } from '@/components/FeatureFlagsProvider'
import { VendorType } from './types'

interface InvoicingVendorPickerProps {
  onChange?: (vendor: VendorType) => void
}

const InvoicingVendorPicker: FC<InvoicingVendorPickerProps> = ({ onChange }) => {
  const [activeTab, setActiveTab] = useState<VendorType>('paypal')
  const { isEnabled } = useFeatureFlagsContext()
  const hubspotInvoicingIsEnabled = isEnabled('hubspot_invoicing')
  const stripeInvoicingIsEnabled = isEnabled('stripe_invoicing')

  const tabIsEnabled = useCallback(
    (vendor: VendorType) => {
      switch (vendor) {
        case 'paypal':
          return true
        case 'hubspot':
          return hubspotInvoicingIsEnabled
        case 'stripe':
          return stripeInvoicingIsEnabled
      }
    },
    [hubspotInvoicingIsEnabled, stripeInvoicingIsEnabled],
  )

  const switchActiveTabHandler: ReactEventHandler<HTMLAnchorElement> = useCallback(
    ({ currentTarget }) => {
      const { tabVendor: vendor } = currentTarget.dataset as { tabVendor: VendorType }
      if (!tabIsEnabled(vendor)) return
      setActiveTab(vendor)
    },
    [tabIsEnabled],
  )

  useEffect(() => {
    if (onChange) onChange(activeTab)
  }, [onChange, activeTab])

  return (
    <div className="border-b border-gray-200 dark:border-gray-700">
      <ul className="flex flex-wrap -mb-px text-sm font-medium text-center text-gray-500 dark:text-gray-400">
        <li className="me-2">
          <TabLink href="#" data-tab-vendor="paypal" active={activeTab == 'paypal'} onClick={switchActiveTabHandler}>
            <i className="fa-brands text-3xl fa-paypal"></i>
            <span className="sr-only">PayPal</span>
          </TabLink>
        </li>
        <li className="me-2">
          <TabLink
            href="#"
            data-tab-vendor="hubspot"
            active={activeTab == 'hubspot'}
            disabled={!hubspotInvoicingIsEnabled}
            onClick={switchActiveTabHandler}
          >
            <i className="fa-brands text-3xl fa-hubspot"></i>
            <span className="sr-only">HubSpot</span>
          </TabLink>
        </li>
        <li className="me-2">
          <TabLink
            href="#"
            data-tab-vendor="stripe"
            active={activeTab == 'stripe'}
            disabled={!stripeInvoicingIsEnabled}
            onClick={switchActiveTabHandler}
          >
            <i className="fa-brands text-3xl fa-stripe"></i>
            <span className="sr-only">Stripe</span>
          </TabLink>
        </li>
      </ul>
    </div>
  )
}

export default InvoicingVendorPicker
