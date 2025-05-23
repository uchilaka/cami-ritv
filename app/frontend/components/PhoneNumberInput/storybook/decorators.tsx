import React from 'react'
import { Decorator, StrictArgs } from '@storybook/react'
import { Formik, FormikConfig } from 'formik'
import LogTransportProvider from '@/components/LogTransportProvider'

export const withFormikDecorator: Decorator<StrictArgs> = (Story, { args, parameters }) => {
  const { initialValues, onSubmit } = parameters.formik as FormikConfig<any>
  return (
    <Formik initialValues={initialValues} onSubmit={onSubmit}>
      <Story {...args} />
    </Formik>
  )
}

export const withLogTransportDecorator: Decorator<StrictArgs> = (Story, { args, parameters }) => {
  return (
    <LogTransportProvider>
      <Story {...args} />
    </LogTransportProvider>
  )
}
