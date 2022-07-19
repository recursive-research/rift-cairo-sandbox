import { useCallback } from 'react'
import { useStarknet } from '@starknet-react/core'
import useLocalStorage from '~/hooks/useLocalStorage'

type ThingID = string

interface Things {
  [account: string]: ThingID[]
}

const useThings = () => {
  const { account } = useStarknet()

  const [things, setThings] = useLocalStorage<Things>('rift-cairo-things', {})

  const add = useCallback(
    (thingID: ThingID) => {
      if (!account) return
      setThings({
        ...things,
        [account]: [...things[account], thingID],
      })
    },
    [account, things, setThings],
  )

  const remove = useCallback(
    (thingID: ThingID) => {
      if (!account) return
      setThings({
        ...things,
        [account]: things[account].filter(id => id !== thingID),
      })
    },
    [account, things, setThings],
  )

  return {
    things: account ? things[account] ?? [] : [],
    add,
    remove,
  }
}

export default useThings
