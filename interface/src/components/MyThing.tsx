import BN from 'bn.js'
import { useStarknet } from '@starknet-react/core'
import { useThingsAddress } from '~/contexts/things-address'
import { number } from 'starknet'
import useMyThing from '~/hooks/useMyThing'

interface UnprocessedThing {
  thingId: BN
  name: BN
  wins: BN
  losses: BN
}

interface Thing {
  thingId: string
  name: string
  wins: number
  losses: number
}

const process = (ut: UnprocessedThing) => ({
  thingId: number.toHex(ut.thingId),
  name: String.fromCharCode(...ut.name.toArray()),
  wins: ut.wins.toNumber(),
  losses: ut.losses.toNumber(),
})

const MyThing = () => {
  const address = useThingsAddress()
  const { account } = useStarknet()
  const { data, loading, error, refresh } = useMyThing(address, account ?? '')

  const refetch = (
    <button type="button" onClick={refresh}>
      Refresh
    </button>
  )

  if (loading) return <div>Loading...</div>

  if (error)
    return (
      <div>
        Error: {error} {refetch}
      </div>
    )

  if (!data) return null

  const myThing = process(data[0])

  if (myThing.thingId === '0x0') return null

  return (
    <div>
      <h3>My Thing</h3>
      <div>
        <p>ID: {myThing.thingId}</p>
        <p>Name: {myThing.name}</p>
        <p>Wins: {myThing.wins}</p>
        <p>Losses: {myThing.losses}</p>
      </div>
      {refetch}
    </div>
  )
}

export default MyThing
