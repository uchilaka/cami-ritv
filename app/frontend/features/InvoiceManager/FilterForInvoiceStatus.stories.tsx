import React from 'react'
import { Decorator, Meta, StoryObj } from '@storybook/react'
import FilterForInvoiceStatus from './FilterForInvoiceStatus'
import { InvoiceProvider } from './InvoiceProvider'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient()

const invoiceProviderDecorator: Decorator = (Story, { args }) => (
  <QueryClientProvider client={queryClient}>
    <InvoiceProvider>
      <Story {...args} />
    </InvoiceProvider>
  </QueryClientProvider>
)

const meta = {
  decorators: [invoiceProviderDecorator],
  title: 'InvoiceManager/FilterForInvoiceStatus',
  component: FilterForInvoiceStatus,
} satisfies Meta<typeof FilterForInvoiceStatus>

export default meta

type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {},
}

export const Disabled: Story = {
  args: {
    disabled: true,
  },
}
