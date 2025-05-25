import React, { FC } from 'react'
import { CountryFlagProps } from './types'
import ScalableVectorGraphic from './ScalableVectorGraphic'

const DEFlag: FC<CountryFlagProps> = (props) => {
  return (
    <ScalableVectorGraphic {...props}>
      <rect width="19.6" height="14" y=".5" fill="#fff" rx="2" />
      <mask id="a" style={{ maskType: 'luminance' }} width="20" height="15" x="0" y="0" maskUnits="userSpaceOnUse">
        <rect width="19.6" height="14" y=".5" fill="#fff" rx="2" />
      </mask>
      <g mask="url(#a)">
        <path fill="#262626" fillRule="evenodd" d="M0 5.167h19.6V.5H0v4.667z" clipRule="evenodd" />
        <g filter="url(#filter0_d_374_135180)">
          <path fill="#F01515" fillRule="evenodd" d="M0 9.833h19.6V5.167H0v4.666z" clipRule="evenodd" />
        </g>
        <g filter="url(#filter1_d_374_135180)">
          <path fill="#FFD521" fillRule="evenodd" d="M0 14.5h19.6V9.833H0V14.5z" clipRule="evenodd" />
        </g>
      </g>
      <defs>
        <filter
          id="filter0_d_374_135180"
          width="19.6"
          height="4.667"
          x="0"
          y="5.167"
          colorInterpolationFilters="sRGB"
          filterUnits="userSpaceOnUse"
        >
          <feFlood floodOpacity="0" result="BackgroundImageFix" />
          <feColorMatrix in="SourceAlpha" result="hardAlpha" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" />
          <feOffset />
          <feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.06 0" />
          <feBlend in2="BackgroundImageFix" result="effect1_dropShadow_374_135180" />
          <feBlend in="SourceGraphic" in2="effect1_dropShadow_374_135180" result="shape" />
        </filter>
        <filter
          id="filter1_d_374_135180"
          width="19.6"
          height="4.667"
          x="0"
          y="9.833"
          colorInterpolationFilters="sRGB"
          filterUnits="userSpaceOnUse"
        >
          <feFlood floodOpacity="0" result="BackgroundImageFix" />
          <feColorMatrix in="SourceAlpha" result="hardAlpha" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" />
          <feOffset />
          <feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.06 0" />
          <feBlend in2="BackgroundImageFix" result="effect1_dropShadow_374_135180" />
          <feBlend in="SourceGraphic" in2="effect1_dropShadow_374_135180" result="shape" />
        </filter>
      </defs>
    </ScalableVectorGraphic>
  )
}

export default DEFlag
