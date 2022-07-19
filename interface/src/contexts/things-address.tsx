import { createContext, useContext } from 'react'

const ThingsAddressContext = createContext<string | null>(null)

interface ThingsAddressProviderProps {
  children: React.ReactNode
  address: string
}

export const ThingsAddressProvider = ({
  children,
  address,
}: ThingsAddressProviderProps) => {
  return (
    <ThingsAddressContext.Provider value={address}>
      {children}
    </ThingsAddressContext.Provider>
  )
}

export const useThingsAddress = () => {
  const address = useContext(ThingsAddressContext)

  if (address === null) {
    throw new Error(
      'useThingsAddress must be used within a ThingsAddressProvider',
    )
  }

  return address
}
