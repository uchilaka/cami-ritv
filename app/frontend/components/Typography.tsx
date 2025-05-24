import React, { ComponentProps, FC } from 'react'

export const Title: FC<ComponentProps<'h1'>> = ({ children, ...props }) => (
  <h1 {...props} className="mb-4 text-4xl dark:text-white font-bold">
    {children}
  </h1>
)

export const Subtitle: FC<ComponentProps<'h2'>> = ({ children, ...props }) => (
  <h2 {...props} className="mb-3 text-3xl dark:text-white font-semibold">
    {children}
  </h2>
)

export const Paragraph: FC<ComponentProps<'p'>> = ({ children, ...props }) => (
  <p {...props} className="mb-4 text-lg font-normal text-gray-500 dark:text-gray-400">
    {children}
  </p>
)

export const SectionTitle: FC<ComponentProps<'h3'>> = ({ children, ...props }) => (
  <h3 {...props} className="mb-2 text-3xl dark:text-white font-medium">
    {children}
  </h3>
)
