import React, { act } from 'react'
import { createRoot, Root } from 'react-dom/client'
import { Formik } from 'formik'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import PhoneNumberComboInput from './PhoneNumberComboInput'

// The real hook fetches /api/form_data/countries; pin it to the US so the
// component's libphonenumber formatting runs deterministically.
vi.mock('./hooks/useListOfCountries', () => ({
  default: () => ({
    loading: false,
    countries: [{ id: 'us', name: 'United States', alpha2: 'US', dialCode: '+1' }],
  }),
}))

vi.mock('../LogTransportProvider', () => ({
  useLogTransport: () => ({ logger: { debug: () => {}, info: () => {}, warn: () => {}, error: () => {} } }),
}))

// React 19 only routes updates through act() when this flag is set.
;(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true

describe('PhoneNumberComboInput', () => {
  let container: HTMLDivElement
  let root: Root

  beforeEach(() => {
    container = document.createElement('div')
    document.body.appendChild(container)
    root = createRoot(container)
  })

  afterEach(() => {
    act(() => root.unmount())
    container.remove()
  })

  const renderWith = async (phone: string, props: Record<string, unknown> = {}) => {
    await act(async () => {
      root.render(
        <Formik initialValues={{ phone }} onSubmit={() => {}}>
          <PhoneNumberComboInput id="phone" name="phone" label="Phone number" {...props} />
        </Formik>,
      )
    })
    return container.querySelector<HTMLInputElement>('input#phone')!
  }

  // LAR-198: the component reformats to "(614) 288-6938", which the old
  // hard-coded dash pattern rejected, blocking form submission.
  it('passes native validation for the national format it produces', async () => {
    const input = await renderWith('6142886938')

    expect(input.value).toBe('(614) 288-6938')
    expect(input.validity.patternMismatch).toBe(false)
    expect(input.checkValidity()).toBe(true)
  })

  it('passes native validation for an international number', async () => {
    const input = await renderWith('+16142886938')

    expect(input.value).toBe('(614) 288-6938')
    expect(input.checkValidity()).toBe(true)
  })

  it('still honours a pattern the caller passes in', async () => {
    const input = await renderWith('6142886938', { pattern: '\\+[0-9]+' })

    expect(input.getAttribute('pattern')).toBe('\\+[0-9]+')
    expect(input.validity.patternMismatch).toBe(true)
  })
})
