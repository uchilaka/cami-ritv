import React from 'react'
import Alert from '../Alert'
import { Meta, StoryObj } from '@storybook/react'

const meta = {
  title: 'Components/Alert',
  component: Alert,
} satisfies Meta<typeof Alert>

type Story = StoryObj<typeof meta>

export default meta

export const Default: Story = {
  args: {
    children: (
      <>
        <span className="font-medium">Something happened!</span> Just an FYI.
      </>
    ),
    variant: 'info',
  },
}
