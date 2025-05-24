import { useCallback, useEffect, useState } from 'react'
import useListOfCountries, { ISO3166Country } from './useListOfCountries'

const useSelectedCountry = (initialCountryAlpha2?: string) => {
  const { loading, countries } = useListOfCountries()
  const [country, setCountry] = useState<ISO3166Country | undefined>()

  const selectCountry = useCallback(
    (alpha2: string) => {
      const latestCountry = countries.find((c) => c.alpha2 === alpha2)
      setCountry(latestCountry)
      return latestCountry
    },
    [countries],
  )

  useEffect(() => {
    if (initialCountryAlpha2) selectCountry(initialCountryAlpha2)
  }, [selectCountry, initialCountryAlpha2])

  return { loading, countries, country, selectCountry }
}

export default useSelectedCountry
