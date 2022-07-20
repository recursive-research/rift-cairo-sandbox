import useThingsCall from '~/hooks/useThingsCall'

const useMyThing = (address: string, account: string) => {
  return useThingsCall({ address, method: 'thingOf', args: [account] })
}

export default useMyThing
