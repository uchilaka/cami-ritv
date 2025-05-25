import { SVGProps } from 'react'

export type ScalableVectorGraphicProps = SVGProps<SVGSVGElement> & { size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' }

// Generate a type from the keys of the dictionary.
type KnownFlagKeys = 'US' | 'UK' | 'AU' | 'DE' | 'FR'

export type CountryFlagProps = Pick<
  ScalableVectorGraphicProps,
  'fill' | 'fillOpacity' | 'fillRule' | 'preserveAspectRatio' | 'size' | 'viewBox' | 'className'
> & { alpha2?: string | KnownFlagKeys }
