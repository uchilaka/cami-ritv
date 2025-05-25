import React from 'react'
import { Decorator, Meta, StoryObj } from '@storybook/react'
import AccountForm from '../AccountForm'
import AccountProvider from '../AccountProvider'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import LogTransportProvider from '@/components/LogTransportProvider'
import FeatureFlagsProvider from '@/components/FeatureFlagsProvider'

const queryClient = new QueryClient()

const accountProviderDecorator: Decorator = (Story, { args }) => (
  <LogTransportProvider>
    <FeatureFlagsProvider>
      <QueryClientProvider client={queryClient}>
        <AccountProvider>
          <Story {...args} />
        </AccountProvider>
      </QueryClientProvider>
    </FeatureFlagsProvider>
  </LogTransportProvider>
)

const accountDataDecorator: Decorator = (Story, { args }) => {
  console.debug('Loading mock account data...')

  return <Story {...args} />
}

const meta: Meta<typeof AccountForm> = {
  decorators: [accountDataDecorator, accountProviderDecorator],
  title: 'AccountManager/AccountForm',
  component: AccountForm,
  argTypes: {
    accountId: {
      control: {
        type: 'text',
      },
    },
    initialType: {
      options: ['Business', 'Individual'],
      control: {
        type: 'radio',
      },
    },
  },
}

export default meta

type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: { readOnly: true, compact: false },
}

/**
 * This story demonstrates how to load a Business account. The account
 * data is only updated when the `accountId` prop changes while the form
 * is in read-only mode.
 */
export const BusinessForm: Story = {
  args: {
    initialType: 'Business',
    accountId: '4321',
    readOnly: true,
  },
  render: (args) => {
    return (
      <>
        <span>Some stuff</span>
        <AccountForm {...args} />
      </>
    )
  },
}

/**
 * This story demonstrates how to load an Individual account. The account
 * data is only updated when the `accountId` prop changes while the form
 * is in read-only mode.
 */
export const IndividualForm: Story = {
  args: { initialType: 'Individual', accountId: '1234', readOnly: true },
}
