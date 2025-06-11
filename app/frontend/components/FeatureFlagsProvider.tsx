import React, { createContext, FC, ReactNode } from 'react'
import useFeatureFlags, { FeatureFlagsProps } from '@/utils/hooks/useFeatureFlags'
import { MissingRequiredContextError } from '@/utils/errors'
import LoadingAnimation from './LoadingAnimation'

type FeatureFlagContextProps = Pick<FeatureFlagsProps, 'error' | 'loading' | 'refetch' | 'isEnabled'>

const FeatureFlagsContext = createContext<FeatureFlagContextProps>(null!)

export const useFeatureFlagsContext = () => {
  const context = React.useContext(FeatureFlagsContext)
  if (!context) {
    throw new MissingRequiredContextError('useFeatureFlagsContext must be used within a FeatureFlagsProvider')
  }
  return context
}

export const FeatureFlagsProvider: FC<{ children?: ReactNode }> = ({ children }) => {
  const { error, isEnabled, loading, refetch } = useFeatureFlags()

  if (loading === undefined || loading) {
    return <LoadingAnimation />
  }

  return <FeatureFlagsContext.Provider value={{ loading, error, isEnabled, refetch }}>{children}</FeatureFlagsContext.Provider>
}

export default FeatureFlagsProvider
