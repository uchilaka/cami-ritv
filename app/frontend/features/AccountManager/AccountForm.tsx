import React, { FC, useEffect, useState } from 'react'
import snakecaseKeys from 'snakecase-keys'
import { useAccountContext } from './AccountProvider'
import { useMutation } from '@tanstack/react-query'
import { withFormik } from 'formik'
import * as Yup from 'yup'
import { useLogTransport } from '@/components/LogTransportProvider'
import { isActionableAccount } from '@/utils/api/types'
import useCsrfToken from '@/utils/hooks/useCsrfToken'
import { AccountFormData } from './types'
import AccountInnerForm, { AccountFormProps, AccountInnerFormProps } from './AccountForm/AccountInnerForm'

export const validationSchema = Yup.object({
  displayName: Yup.string().required('A display name is required'),
  email: Yup.string()
    .email('must be a valid email address')
    .test({
      name: 'is-valid-email',
      skipAbsent: false,
      test(value, ctx) {
        const source: AccountFormData = ctx.parent
        if (source.type === 'Business' && !value) {
          return ctx.createError({ message: 'Email address is required for a business' })
        }
        return true
      },
    }),
})

export const AccountFormWithFormik = withFormik<AccountInnerFormProps, AccountFormData>({
  validationSchema,
  validateOnBlur: true,
  mapPropsToValues: ({ initialValues }) => ({
    givenName: '',
    familyName: '',
    phone: '',
    readme: '',
    ...initialValues,
  }),
  handleSubmit: async (values, { setSubmitting, validateForm, props }) => {
    const { logger, account, updateAccount } = props
    setSubmitting(true)
    const validationErrors = await validateForm(values)
    if (Object.keys(validationErrors).length > 0) {
      // Errors were reported
      logger.debug({ values, errors: validationErrors })
    } else {
      logger.debug({ values })
      if (updateAccount && isActionableAccount(account)) {
        // Submit the form
        updateAccount.mutate(values)
      } else {
        // Set an error
      }
    }
    setSubmitting(false)
  },
})(AccountInnerForm)

const AccountForm: FC<Omit<AccountFormProps, 'setReadOnly'>> = ({ compact, initialType, readOnly, saved, accountId, ...props }) => {
  const [hasBeenSaved, setHasBeenSaved] = useState<boolean | undefined>(saved)
  const [isReadOnly, setIsReadOnly] = useState(readOnly ?? true)
  const { logger } = useLogTransport()
  const { loading, account, setAccountId } = useAccountContext()
  const [currentAccount, setCurrentAccount] = useState(account)
  const { csrfToken } = useCsrfToken()

  const updateAccount = useMutation({
    mutationFn: async (values: AccountFormData) => {
      if (isActionableAccount(account)) {
        // Submit the form
        const { edit } = account.actions
        const { givenName, familyName, phone, ...rest } = values
        const payload = {
          [account.type.toLowerCase()]: { phone, ...rest },
          profile: { givenName, familyName, phone },
        }
        return fetch(edit.url, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            'X-CSRF-Token': csrfToken,
          },
          body: JSON.stringify(snakecaseKeys(payload)),
        })
      } else {
        // TODO: Raise AccountNotActionableError
      }
    },
    onSuccess: async (result) => {
      const account = await result?.json()
      logger.debug('Account updated:', { account })
      setHasBeenSaved(true)
      /**
       * IMPORTANT: Enabling read-only mode signals to the form that
       * the account data has been updated and passes the condition(s) for
       * the form to be reloaded.
       */
      setIsReadOnly(true)
      setCurrentAccount(account)
    },
  })

  logger.debug('Account Form (withFormik):', { account, loading })

  const mappedProps = {
    compact,
    loading,
    ...props,
    dirty: false,
    initialType,
    initialErrors: {},
    initialTouched: {},
    isValid: false,
    saved: hasBeenSaved,
    readOnly: isReadOnly,
    setReadOnly: setIsReadOnly,
  }

  useEffect(() => {
    // Capture the account ID property and set it in the context
    if (accountId && readOnly) setAccountId(accountId)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [accountId, readOnly])

  return (
    <AccountFormWithFormik
      {...mappedProps}
      logger={logger}
      initialValues={{
        displayName: '',
        givenName: '',
        familyName: '',
        phone: '',
        email: '',
        readme: '',
        type: initialType ?? 'Business',
      }}
      account={currentAccount}
      updateAccount={updateAccount}
    />
  )
}

export default AccountForm
