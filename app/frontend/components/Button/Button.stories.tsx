import React from 'react'
import { Meta, StoryObj } from '@storybook/react'
import { fn } from '@storybook/test'
import SimpleButton from '.'
import SimpleButtonLink from './ButtonLink'

import { Default as ButtonSizes } from './ButtonSizes.stories'

const meta = {
  title: 'Components/Button',
  component: SimpleButton,
} satisfies Meta<typeof SimpleButton>

export default meta

type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    children: 'Click me',
    variant: 'primary',
    onClick: fn(),
    disabled: false,
    loading: false,
  },
  argTypes: {
    variant: {
      options: ['primary', 'secondary', 'caution'],
      control: {
        type: 'radio',
      },
    },
  },
}

export const Sizes: Story = {
  render: (args) => {
    return (
      <div className="space-x-2">
        <SimpleButton {...args} {...ButtonSizes.args} id="x-small" size="xs">
          Extra Small
        </SimpleButton>
        <SimpleButton {...args} {...ButtonSizes.args} id="small" size="sm">
          Small
        </SimpleButton>
        <SimpleButton {...args} {...ButtonSizes.args} id="base" size="base">
          Base
        </SimpleButton>
        <SimpleButton {...args} {...ButtonSizes.args} id="large" size="lg">
          Large
        </SimpleButton>
        <SimpleButton {...args} {...ButtonSizes.args} id="x-large" size="xl">
          Extra Large
        </SimpleButton>
      </div>
    )
  },
}

export const DisabledWhileLoading: Story = {
  args: {
    loading: true,
  },
}

export const ButtonLink: Story = {
  render: () => {
    return <SimpleButtonLink href="https://www.google.com">Google</SimpleButtonLink>
  },
  args: {
    loading: false,
    variant: 'primary',
  },
}
