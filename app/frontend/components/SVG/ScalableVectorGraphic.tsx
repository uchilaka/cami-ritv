import React, { FC } from 'react'
import clsx from 'clsx'

import { ScalableVectorGraphicProps } from './types'

const ScalableVectorGraphic: FC<ScalableVectorGraphicProps> = ({
  size = 'xs',
  className,
  fill = 'none',
  viewBox = '0 0 20 15',
  xmlns = 'http://www.w3.org/2000/svg',
  preserveAspectRatio = 'xMidYMid meet',
  children,
  ...props
}) => {
  const propsWithDefaults = { fill, viewBox, preserveAspectRatio }
  const svgClassNames = clsx(className, {
    'h-4 w-auto': size === 'xs',
    'h-5 w-auto': size === 'sm',
    'h-6 w-auto': size === 'md',
    'h-7 w-auto': size === 'lg',
    'h-8 w-auto': size === 'xl',
  })

  return (
    <svg {...props} {...propsWithDefaults} className={svgClassNames} xmlns={xmlns}>
      {children}
    </svg>
  )
}

export default ScalableVectorGraphic
