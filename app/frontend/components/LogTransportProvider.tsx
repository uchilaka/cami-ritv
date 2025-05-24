import React, { createContext, FC, ReactNode } from 'react'
import { Console } from 'node:console'
import { MissingRequiredContextError } from '@/utils/errors'

type LogMessageFn = (message: string, ...payload: any) => Promise<void>
type LogMetadataFn = (...payload: any) => Promise<void>

export interface Logger {
  log: LogMessageFn | LogMetadataFn
  error: LogMessageFn | LogMetadataFn
  warn: LogMessageFn | LogMetadataFn
  info: LogMessageFn | LogMetadataFn
  debug: LogMetadataFn
}

interface LogTransportContextProps {
  logger: Console | Logger
}

const LogTransportContext = createContext<LogTransportContextProps>(null!)

export const useLogTransport = () => {
  const context = React.useContext(LogTransportContext)
  if (!context) {
    throw new MissingRequiredContextError('useLogTransport must be used within a LogTransportProvider')
  }
  return context
}

const LogTransportProvider: FC<{ children: ReactNode }> = ({ children }) => {
  return <LogTransportContext.Provider value={{ logger: console }}>{children}</LogTransportContext.Provider>
}

export default LogTransportProvider
