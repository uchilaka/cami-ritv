import * as gaxios from 'gaxios'
import { appBaseUrl } from '@/utils'

/**
 * Request options:
 * https://github.com/googleapis/gaxios?tab=readme-ov-file#request-options
 */
gaxios.instance.defaults = {
  baseURL: appBaseUrl(),
  headers: {
    Accept: 'application/json',
  },
  retryConfig: {
    retryDelay: 100,
    httpMethodsToRetry: ['GET', 'PUT', 'HEAD', 'OPTIONS', 'DELETE'],
    noResponseRetries: 2,
  },
}

export const request = gaxios.request

export default gaxios
