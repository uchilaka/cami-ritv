import React from 'react'
import { Meta, StoryObj } from '@storybook/react'
import SimpleButtonLink from './ButtonLink'

const meta = {
  title: 'Components/ButtonLink',
  component: SimpleButtonLink,
} satisfies Meta<typeof SimpleButtonLink>

export default meta

type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    children: 'Click me',
    variant: 'primary',
    href: 'https://youtu.be/dQw4w9WgXcQ',
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

export const ButtonLinkSizes: Story = {
  render: ({ variant, loading, href, onClick, ...args }) => {
    const supportedArgs = { variant, loading, href, target: '_blank' }

    return (
      <div className="space-x-2">
        <SimpleButtonLink {...supportedArgs} id="x-small" size="xs">
          Extra Small
        </SimpleButtonLink>
        <SimpleButtonLink {...supportedArgs} id="small" size="sm">
          Small
        </SimpleButtonLink>
        <SimpleButtonLink {...supportedArgs} id="base" size="base">
          Base
        </SimpleButtonLink>
        <SimpleButtonLink {...supportedArgs} id="large" size="lg">
          Large
        </SimpleButtonLink>
        <SimpleButtonLink {...supportedArgs} id="x-large" size="xl">
          Extra Large
        </SimpleButtonLink>
      </div>
    )
  },
  args: {
    variant: 'primary',
    loading: false,
    href: 'https://youtu.be/dQw4w9WgXcQ',
  },
}
