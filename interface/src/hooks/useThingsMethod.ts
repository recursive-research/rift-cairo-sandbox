import { useStarknetInvoke } from '@starknet-react/core'
import useThingsContract from '~/hooks/useThingsContract'

type ThingsMethod = 'mint' | 'fight'

interface UseThingsMethodArgs {
  address: string
  method: ThingsMethod
}

const useThingsMethod = ({ address, method }: UseThingsMethodArgs) => {
  const { contract } = useThingsContract(address)
  return useStarknetInvoke({ contract, method })
}

export default useThingsMethod
