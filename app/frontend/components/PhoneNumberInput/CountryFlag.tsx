import React, { FC, ReactNode } from 'react'

import USFlag from '../SVG/USFlag'
import UKFlag from '../SVG/UKFlag'
import AUFlag from '../SVG/AUFlag'
import DEFlag from '../SVG/DEFlag'
import FRFlag from '../SVG/FRFlag'
import CountryCodeBadge from './CountryCodeBadge'
import { CountryFlagProps } from '../SVG/types'
import { isKnownCountryFlag } from './types'

const CountryFlag: FC<CountryFlagProps> = ({ alpha2, size = 'sm', className = 'mx-2', ...passThroughProps }) => {
  if (isKnownCountryFlag(alpha2)) {
    return (
      <>
        {alpha2 === 'US' && <USFlag {...passThroughProps} size={size} className={className} />}
        {alpha2 === 'UK' && <UKFlag {...passThroughProps} size={size} className={className} />}
        {alpha2 === 'AU' && <AUFlag {...passThroughProps} size={size} className={className} />}
        {alpha2 === 'DE' && <DEFlag {...passThroughProps} size={size} className={className} />}
        {alpha2 === 'FR' && <FRFlag {...passThroughProps} size={size} className={className} />}
      </>
    )
  }

  return <CountryCodeBadge code={alpha2} />
}

export default CountryFlag
