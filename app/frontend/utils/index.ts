import { APPLICATION_SHORT_NAME } from '@/utils/constants'

export * from './types'

export const nsEventName = (suffix: string) => `${APPLICATION_SHORT_NAME.toLowerCase()}:${suffix}`

export const isDevProxied = () => {
  console.debug(`Hostname: ${window.location.hostname}`)
  return /\.ngrok\.dev/.test(window.location.hostname)
}

export const isLocalhost = () => {
  console.debug(`Hostname: ${window.location.hostname}`)
  return window.location.port === '16006'
}

export const appBaseUrl = () => {
  if (isLocalhost()) return 'http://127.0.0.1:16006'

  return `https://${window.location.hostname}`
}
