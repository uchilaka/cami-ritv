import React from 'react'
import { Meta, StoryObj } from '@storybook/react'
import LoadingAnimation from './LoadingAnimation'

const meta = {
  title: 'Components/LoadingAnimation',
  component: LoadingAnimation,
} satisfies Meta<typeof LoadingAnimation>

export default meta

type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {},
}

export const Text: Story = {
  args: {
    variant: 'text',
  },
}
