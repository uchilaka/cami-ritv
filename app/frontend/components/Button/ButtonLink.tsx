import React, { AnchorHTMLAttributes, FC } from 'react'
import { ButtonBaseProps, ButtonLoader } from '.'
import useButtonClassNames from '@/utils/hooks/useButtonClassNames'
import clsx from 'clsx'

type ButtonLinkProps = AnchorHTMLAttributes<HTMLAnchorElement> & ButtonBaseProps

const ButtonLink: FC<ButtonLinkProps> = ({
  id,
  children,
  href,
  loading,
  variant = 'secondary',
  size = 'base',
  className = 'text-center mb-2 rounded-lg',
  ...otherProps
}) => {
  const { buttonClassNames } = useButtonClassNames({ variant, size, loading })
  const buttonStyle = clsx(className, buttonClassNames)
  return (
    <a href={href} {...otherProps} id={id} className={buttonStyle}>
      {loading ? <ButtonLoader /> : children}
    </a>
  )
}

export default ButtonLink
