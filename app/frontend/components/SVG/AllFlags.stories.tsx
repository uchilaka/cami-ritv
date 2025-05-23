import React from 'react'
import { Meta, StoryObj } from '@storybook/react'
import CountryFlag from '../PhoneNumberInput/CountryFlag'
import USFlag from './USFlag'
import AUFlag from './AUFlag'
import UKFlag from './UKFlag'
import DEFlag from './DEFlag'
import FRFlag from './FRFlag'
import NGFlag from './NGFlag'

const meta: Meta<typeof CountryFlag> = {
  title: 'Components/CountryFlag',
  component: CountryFlag,
  argTypes: {
    size: {
      options: ['xs', 'sm', 'md', 'lg', 'xl'],
      control: {
        type: 'radio',
      },
    },
  },
}

export default meta

type Story = StoryObj<typeof meta>

export const AllFlags: Story = {
  args: { size: 'md', className: 'mx-2' },
  render: ({ size, className, ..._otherArgs }) => {
    const passThroughProps = { size, className }
    return (
      <div className="flex flex-row">
        <USFlag {...passThroughProps} />
        <UKFlag {...passThroughProps} />
        <NGFlag {...passThroughProps} />
        <AUFlag {...passThroughProps} />
        <DEFlag {...passThroughProps} />
        <FRFlag {...passThroughProps} />
      </div>
    )
  },
}

export const Default: Story = {
  args: { alpha2: 'US', className: 'mx-2', size: 'md' },
}
