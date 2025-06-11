import { Meta, StoryObj } from '@storybook/react'
import PhoneLibNumberInput from './PhoneLibNumberInput'
import { withFormikDecorator, withLogTransportDecorator } from './storybook/decorators'

const meta = {
  title: 'Components/PhoneInput/PhoneLibNumberInput',
  component: PhoneLibNumberInput,
} satisfies Meta<typeof PhoneLibNumberInput>

export default meta

type Story = StoryObj<typeof meta>

export const Default: Story = {
  decorators: [withFormikDecorator, withLogTransportDecorator],
  args: {
    label: 'Phone Number',
    id: 'phone',
    name: 'phone',
    readOnly: false,
    disabled: false,
    international: false,
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
