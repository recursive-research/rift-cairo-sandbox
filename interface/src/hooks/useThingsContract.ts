import { useContract } from '@starknet-react/core'
import { Abi } from 'starknet'
import thingsAbi from '~/abis/things.json'

const useThingsContract = (address: string) => {
  return useContract({
    address,
    abi: thingsAbi as Abi,
  })
}

export default useThingsContract
