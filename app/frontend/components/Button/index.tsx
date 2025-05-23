import React, { ButtonHTMLAttributes, FC, forwardRef } from 'react'
import clsx from 'clsx'
import useButtonClassNames from '@/utils/hooks/useButtonClassNames'
import ButtonLoader from './ButtonLoader'

export { ButtonLoader as ButtonLoader }

export type ButtonBaseProps = {
  loading?: boolean
  variant?: 'primary' | 'secondary' | 'caution' | 'transparent'
  size?: 'xs' | 'sm' | 'base' | 'lg' | 'xl'
}

export type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & ButtonBaseProps

export const RefButton = forwardRef<HTMLButtonElement, ButtonProps>(function RefButton(props, ref) {
  const { id, children, loading, variant = 'secondary', size, className = 'text-center mb-2 rounded-lg', ...otherProps } = props
  const { buttonClassNames } = useButtonClassNames({ variant, size, loading, disabled: otherProps.disabled })
  // TODO: experimenting with "me-2 mb-2" in base style
  const buttonStyle = clsx(className, buttonClassNames)

  return (
    <button type="button" {...otherProps} id={id} ref={ref} className={buttonStyle}>
      {loading ? <ButtonLoader /> : children}
    </button>
  )
})

const Button: FC<ButtonProps> = ({
  id,
  children,
  loading,
  variant = 'secondary',
  size = 'base',
  className = 'text-center mb-2 rounded-lg',
  ...otherProps
}) => {
  const { buttonClassNames } = useButtonClassNames({ variant, size, loading, disabled: otherProps.disabled })
  // TODO: experimenting with "me-2 mb-2" in base style
  const buttonStyle = clsx(className, buttonClassNames)

  return (
    <button type="button" {...otherProps} id={id} className={buttonStyle}>
      {loading ? <ButtonLoader /> : children}
    </button>
  )
}

export default Button
