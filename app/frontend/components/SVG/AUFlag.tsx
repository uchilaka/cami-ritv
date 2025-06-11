import React, { FC } from 'react'

import { CountryFlagProps } from './types'
import ScalableVectorGraphic from './ScalableVectorGraphic'

/**
 * The Australian flag (AU) in SVG.
 *
 * For a guide on scaling SVGs, see https://css-tricks.com/scale-svg/
 * @param param0
 * @returns
 */
const AUFlag: FC<CountryFlagProps> = (props) => {
  return (
    <ScalableVectorGraphic {...props}>
      <rect width="19.6" height="14" y=".5" fill="#fff" rx="2" />
      <mask id="a" style={{ maskType: 'luminance' }} width="20" height="15" x="0" y="0" maskUnits="userSpaceOnUse">
        <rect width="19.6" height="14" y=".5" fill="#fff" rx="2" />
      </mask>
      <g mask="url(#a)">
        <path fill="#0A17A7" d="M0 .5h19.6v14H0z" />
        <path
          fill="#fff"
          stroke="#fff"
          strokeWidth=".667"
          d="M0 .167h-.901l.684.586 3.15 2.7v.609L-.194 6.295l-.14.1v1.24l.51-.319L3.83 5.033h.73L7.7 7.276a.488.488 0 00.601-.767L5.467 4.08v-.608l2.987-2.134a.667.667 0 00.28-.543V-.1l-.51.318L4.57 2.5h-.73L.66.229.572.167H0z"
        />
        <path
          fill="url(#paint0_linear_374_135177)"
          fillRule="evenodd"
          d="M0 2.833V4.7h3.267v2.133c0 .369.298.667.666.667h.534a.667.667 0 00.666-.667V4.7H8.2a.667.667 0 00.667-.667V3.5a.667.667 0 00-.667-.667H5.133V.5H3.267v2.333H0z"
          clipRule="evenodd"
        />
        <path
          fill="url(#paint1_linear_374_135177)"
          fillRule="evenodd"
          d="M0 3.3h3.733V.5h.934v2.8H8.4v.933H4.667v2.8h-.934v-2.8H0V3.3z"
          clipRule="evenodd"
        />
        <path
          fill="#fff"
          fillRule="evenodd"
          d="M4.2 11.933l-.823.433.157-.916-.666-.65.92-.133.412-.834.411.834.92.134-.665.649.157.916-.823-.433zm9.8.7l-.66.194.194-.66-.194-.66.66.193.66-.193-.193.66.193.66-.66-.194zm0-8.866l-.66.193.194-.66-.194-.66.66.193.66-.193-.193.66.193.66-.66-.193zm2.8 2.8l-.66.193.193-.66-.193-.66.66.193.66-.193-.193.66.193.66-.66-.193zm-5.6.933l-.66.193.193-.66-.193-.66.66.194.66-.194-.193.66.193.66-.66-.193zm4.2 1.167l-.33.096.096-.33-.096-.33.33.097.33-.097-.097.33.097.33-.33-.096z"
          clipRule="evenodd"
        />
      </g>
      <defs>
        <linearGradient id="paint0_linear_374_135177" x1="0" x2="0" y1=".5" y2="7.5" gradientUnits="userSpaceOnUse">
          <stop stopColor="#fff" />
          <stop offset="1" stopColor="#F0F0F0" />
        </linearGradient>
        <linearGradient id="paint1_linear_374_135177" x1="0" x2="0" y1=".5" y2="7.033" gradientUnits="userSpaceOnUse">
          <stop stopColor="#FF2E3B" />
          <stop offset="1" stopColor="#FC0D1B" />
        </linearGradient>
      </defs>
    </ScalableVectorGraphic>
  )
}

export default AUFlag
