import React, { FC } from 'react'
import { Meta, StoryObj } from '@storybook/react'
import { fn } from '@storybook/test'
import SimpleButton, { ButtonProps } from '.'

const ButtonSizes: FC<ButtonProps> = ({ variant, ...otherProps }) => {
  return (
    <div className="space-x-2">
      <SimpleButton {...otherProps} id="x-small" variant={variant} size="xs">
        Extra Small
      </SimpleButton>
      <SimpleButton {...otherProps} id="small" variant={variant} size="sm">
        Small
      </SimpleButton>
      <SimpleButton {...otherProps} id="base" variant={variant} size="base">
        Base
      </SimpleButton>
      <SimpleButton {...otherProps} id="large" variant={variant} size="lg">
        Large
      </SimpleButton>
      <SimpleButton {...otherProps} id="x-large" variant={variant} size="xl">
        Extra Large
      </SimpleButton>
    </div>
  )
}

const meta = {
  title: 'Components/Button/Sizes + Variants',
  component: ButtonSizes,
} satisfies Meta<typeof ButtonSizes>

export default meta

type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    variant: 'primary',
    onClick: fn(),
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
