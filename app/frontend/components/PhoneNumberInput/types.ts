export const KNOWN_COUNTRY_FLAGS = ['US', 'UK', 'AU', 'DE', 'FR']

// Creates a type from the values of the KNOWN_COUNTRY_FLAGS array
export type KnownCountryFlag = (typeof KNOWN_COUNTRY_FLAGS)[number]

export const isKnownCountryFlag = (alpha2?: string): boolean => !!alpha2 && KNOWN_COUNTRY_FLAGS.includes(alpha2)
