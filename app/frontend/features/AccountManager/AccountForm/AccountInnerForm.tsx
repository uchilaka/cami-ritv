import React, { Dispatch, FC, SetStateAction, useEffect, useState } from 'react'
import { UseMutationResult } from '@tanstack/react-query'
import { Form, FormikComputedProps, useFormikContext } from 'formik'
import clsx from 'clsx'

import type { Console } from 'node:console'

import { AccountFormData } from '../types'
import { arrayHasItems, BusinessAccount, IndividualAccount, isIndividualAccount } from '@/utils/api/types'
import { useFeatureFlagsContext } from '@/components/FeatureFlagsProvider'
import { Logger } from '@/components/LogTransportProvider'
import { useAccountContext } from '../AccountProvider'
import Alert from '@/components/Alert'
import FormInput from '@/components/FloatingFormInput'
import TextareaInput from '@/components/TextareaInput'
import Button, { ButtonLoader } from '@/components/Button'
import PhoneInput from '@/components/PhoneNumberInput/PhoneNumberComboInput'
import ButtonLink from '@/components/Button/ButtonLink'

export interface AccountFormProps {
  setReadOnly: Dispatch<SetStateAction<boolean>>
  accountId?: string
  compact?: boolean
  loading?: boolean
  initialType?: AccountFormData['type']
  initialValues?: AccountFormData
  readOnly?: boolean
  saved?: boolean
}

export type AccountInnerFormProps = AccountFormProps & {
  logger: Console | Logger
  account?: IndividualAccount | BusinessAccount | null
  updateAccount?: UseMutationResult<Response | undefined, Error, AccountFormData>
} & FormikComputedProps<AccountFormData>

const composeFormValues = (account?: IndividualAccount | BusinessAccount | null, initialType?: AccountFormData['type']) => {
  return {
    displayName: account?.displayName ?? '',
    email: account?.email ?? '',
    /**
     * TODO: There's a warning about this output (how we're processing it
     * on the backend using :to_plain_text on the ActionText::RichText object)
     * not being HTML safe:
     * https://api.rubyonrails.org/v8.0.0/classes/ActionText/RichText.html#method-i-to_plain_text
     */
    readme: account?.readme?.plaintext ?? '',
    phone: account?.phone ?? '',
    type: account?.type ?? initialType ?? 'Business',
    ...(isIndividualAccount(account)
      ? {
          givenName: account?.profile?.givenName ?? '',
          familyName: account?.profile?.familyName ?? '',
        }
      : {}),
  }
}

const AccountInnerForm: FC<AccountInnerFormProps> = ({
  compact,
  loading,
  saved,
  initialType,
  readOnly,
  setReadOnly,
  logger,
  account: initialAccount,
}) => {
  const [account, setAccount] = useState(() => initialAccount)
  const { handleChange, handleReset, handleBlur, handleSubmit, isValid, isValidating, isSubmitting, errors, values, setValues } =
    useFormikContext<AccountFormData>()
  const { loading: loadingFeatureFlags, isEnabled } = useFeatureFlagsContext()
  const { loading: loadingAccount, account: loadedAccount } = useAccountContext()
  // TODO: Deprecate the feat__editable_phone_numbers flag
  const disablePhoneNumbers = !isEnabled('editable_phone_numbers')
  const formClassName = clsx('mx-auto', { 'max-w-lg': !compact })

  logger.debug('AccountInnerForm:', { account, isReadOnly: readOnly, initialType, saved })

  useEffect(() => {
    if (account) setValues(composeFormValues(account))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [account])

  useEffect(() => {
    if (loadedAccount && readOnly) setAccount(loadedAccount)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [loadingAccount, loadedAccount, readOnly])

  return (
    <>
      {saved && (
        <Alert variant="success">
          <span className="font-medium">Done!</span> The account was saved successfully!
        </Alert>
      )}
      <Form className={formClassName} onSubmit={handleSubmit}>
        <FormInput
          id="displayName"
          type="text"
          label={values.type === 'Business' ? 'Company (Ex. Google)' : 'Display name'}
          autoComplete="off"
          name="displayName"
          placeholder=" "
          error={!!errors.displayName}
          hint={errors.displayName}
          onReset={handleReset}
          onChange={handleChange}
          onBlur={handleBlur}
          readOnly={loading || readOnly}
          required
        />

        <div className="grid md:gap-6 md:grid-cols-2">
          <FormInput
            id="email"
            type="email"
            label="Email address"
            name="email"
            placeholder=" "
            error={!!errors.email}
            hint={errors.email}
            onReset={handleReset}
            onChange={handleChange}
            onBlur={handleBlur}
            readOnly={loading || readOnly}
          />
          <PhoneInput
            id="phone"
            type="phone"
            label="Phone number"
            name="phone"
            placeholder=" "
            international
            hint={errors.phone}
            onReset={handleReset}
            onChange={handleChange}
            onBlur={handleBlur}
            readOnly={loading || loadingFeatureFlags || disablePhoneNumbers || readOnly}
          />
        </div>

        {/**
         * TODO: Detect if there is a (metadata) profile and offer
         * to create one to save givenName and familyName
         */}
        {values.type === 'Individual' && (
          <div className="grid md:gap-6 md:grid-cols-2">
            <FormInput
              type="text"
              id="givenName"
              name="givenName"
              label="First name"
              placeholder=" "
              onReset={handleReset}
              onChange={handleChange}
              onBlur={handleBlur}
              readOnly={loading || readOnly}
            />
            <FormInput
              type="text"
              id="familyName"
              name="familyName"
              label="Last name"
              placeholder=" "
              onReset={handleReset}
              onChange={handleChange}
              onBlur={handleBlur}
              readOnly={loading || readOnly}
            />
          </div>
        )}

        {/* @TODO Figure out how to handle trix-content via react frontend */}
        <TextareaInput
          id="readme"
          name="readme"
          label="Description"
          placeholder=" "
          onReset={handleReset}
          onChange={handleChange}
          onBlur={handleBlur}
          readOnly={loading || readOnly}
        />

        <div className="flex justify-end items-center space-x-2">
          {!readOnly && (
            <>
              <Button onClick={() => setReadOnly(true)}>Cancel</Button>
              <Button disabled variant="caution">
                Delete this account
              </Button>
              <Button
                variant="primary"
                type="submit"
                loading={loading || isValidating}
                disabled={loading || !isValid || isValidating || isSubmitting}
              >
                {isSubmitting ? <ButtonLoader>Saving...</ButtonLoader> : 'Save'}
              </Button>
            </>
          )}
          {readOnly && (
            <>
              {arrayHasItems(account?.invoices) ? (
                <ButtonLink href={account?.actions.transactionsIndex.url}>Transactions</ButtonLink>
              ) : (
                <Button disabled>Transactions</Button>
              )}
              {account?.actions.showProfile ? (
                <ButtonLink href={account.actions.showProfile.url}>Profile</ButtonLink>
              ) : (
                <>{isIndividualAccount(account) && <ButtonLink href={account.actions.profilesIndex.url}>Profiles</ButtonLink>}</>
              )}
              <Button variant="primary" onClick={() => setReadOnly(false)}>
                Edit
              </Button>
            </>
          )}
        </div>
      </Form>
    </>
  )
}

export default AccountInnerForm
