import React, { FC } from 'react'
import { CountryFlagProps } from './types'
import ScalableVectorGraphic from './ScalableVectorGraphic'

const NGFlag: FC<CountryFlagProps> = (props) => {
  return (
    <ScalableVectorGraphic {...props}>
      <rect width="19.1" height="13.5" x=".25" y=".75" fill="#fff" stroke="#F5F5F5" strokeWidth=".5" rx="1.75" />
      <mask id="a" style={{ maskType: 'luminance' }} width="20" height="15" x="0" y="0" maskUnits="userSpaceOnUse">
        <rect width="19.1" height="13.5" x=".25" y=".75" fill="#fff" stroke="#fff" strokeWidth=".5" rx="1.75" />
      </mask>
      <g mask="url(#a)">
        <path fill="#00833E" d="M13.067.5H19.6v14h-6.533z" />
        <path fill="#00833E" fillRule="evenodd" d="M0 14.5h6.533V.5H0v14z" clipRule="evenodd" />
      </g>
    </ScalableVectorGraphic>
  )
}

export default NGFlag
