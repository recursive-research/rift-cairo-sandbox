// import { useStarknetCall } from '@starknet-react/core'
import { useStarknetCall } from './useStarknetCall'
import useThingsContract from '~/hooks/useThingsContract'

type ThingsCall = 'thingOf'

interface UseThingsMethodArgs {
  address: string
  method: ThingsCall
  args?: any[]
}

const useThingsCall = ({ address, method, args }: UseThingsMethodArgs) => {
  const { contract } = useThingsContract(address)
  return useStarknetCall({ contract, method, args: args ?? [] })
}

export default useThingsCall
