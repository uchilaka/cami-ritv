import React from 'react'
import { Decorator, Meta, StoryObj, StrictArgs } from '@storybook/react'
import TextareaInput from '.'
import { Formik, FormikConfig } from 'formik'

const meta = {
  title: 'Components/TextareaInput',
  component: TextareaInput,
} satisfies Meta<typeof TextareaInput>

export default meta

type Story = StoryObj<typeof meta>

const withFormikDecorator: Decorator<StrictArgs> = (Story, { args, parameters }) => {
  const { initialValues, onSubmit } = parameters.formik as FormikConfig<any>
  return (
    <Formik initialValues={initialValues} onSubmit={onSubmit}>
      <Story {...args} />
    </Formik>
  )
}

export const Default: Story = {
  decorators: [withFormikDecorator],
  args: {
    label: 'Description',
    id: 'description',
    name: 'description',
  },
  parameters: {
    formik: {
      initialValues: {
        description: '',
      },
      onSubmit: (values: any) => {
        console.log(values)
      },
    },
  },
}

export const ReadOnly = {
  decorators: [withFormikDecorator],
  args: {
    label: 'Description',
    id: 'description',
    name: 'description',
    readOnly: true,
  },
  parameters: {
    formik: {
      initialValues: {
        description: 'This is a read-only field',
      },
      onSubmit: (values: any) => {
        console.log(values)
      },
    },
  },
}

export const WithError: Story = {
  decorators: [withFormikDecorator],
  args: {
    label: 'Description',
    id: 'description',
    name: 'description',
    error: true,
    hint: 'This field is invalid',
  },
  parameters: {
    formik: {
      initialValues: {
        description: '',
      },
      onSubmit: (values: any) => {
        console.log(values)
      },
    },
  },
}
