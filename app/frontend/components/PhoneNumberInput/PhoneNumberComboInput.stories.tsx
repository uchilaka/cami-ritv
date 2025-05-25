import { Meta, StoryObj } from '@storybook/react'
import PhoneNumberInput from './PhoneNumberComboInput'
import { withFormikDecorator, withLogTransportDecorator } from './storybook/decorators'

const meta = {
  title: 'Components/PhoneInput/PhoneNumberComboInput',
  component: PhoneNumberInput,
} satisfies Meta<typeof PhoneNumberInput>

export default meta

type Story = StoryObj<typeof meta>

export const Default: Story = {
  decorators: [withLogTransportDecorator, withFormikDecorator],
  args: {
    label: 'Phone Number',
    id: 'phone',
    name: 'phone',
  },
  parameters: {
    formik: {
      initialValues: {
        phone: '',
      },
      onSubmit: (values: any) => {
        console.log(values)
      },
    },
  },
}

export const WithInitialValue: Story = {
  decorators: [withLogTransportDecorator, withFormikDecorator],
  args: {
    label: 'Phone Number',
    name: 'phone',
  },
  parameters: {
    formik: {
      initialValues: {
        phone: '+17405678900',
      },
      onSubmit: (values: any) => {
        console.log(values)
      },
    },
  },
}

export const ReadOnlyWithInitialValue: Story = {
  decorators: [withLogTransportDecorator, withFormikDecorator],
  args: {
    label: 'Phone Number',
    name: 'phone',
    readOnly: true,
  },
  parameters: {
    formik: {
      initialValues: {
        phone: '+17405678900',
      },
      onSubmit: (values: any) => {
        console.log(values)
      },
    },
  },
}
