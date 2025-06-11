import React, { FC } from 'react'

import { ISO3166Country } from './hooks/useListOfCountries'
import CountryFlag from './CountryFlag'
import { CountryFlagProps } from '../SVG/types'

type CountryCodeProps = Omit<CountryFlagProps, 'alpha2'> & {
  country?: ISO3166Country
}

const CountryCode: FC<CountryCodeProps> = ({ country, size, className }) => {
  const passThruFlagProps = { size, className }
  return (
    <>
      <CountryFlag {...passThruFlagProps} alpha2={country?.alpha2} /> <span>{country?.dialCode ?? '###'}</span>
    </>
  )
}

export default CountryCode
