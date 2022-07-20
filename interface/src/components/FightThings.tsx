import { useState, useEffect } from 'react'
import { useStarknet } from '@starknet-react/core'
import { useThingsAddress } from '~/contexts/things-address'
import { encodeShortString } from 'starknet/utils/shortString'
import useThingsFight from '~/hooks/useThingsFight'
import useLocalThings from '~/hooks/useLocalThings'

const FightThings = () => {
  const address = useThingsAddress()
  const { fight, loading, data, error, reset } = useThingsFight(address)

  const [oppponent, setOpponent] = useState('')

  return (
    <div>
      <h3>Fight things!</h3>
      <div
        style={{
          display: 'flex',
          gap: '1ch',
          alignItems: 'center',
        }}
      >
        Opponent:
        <input
          placeholder="Opp. Thing ID"
          type="text"
          value={oppponent}
          onChange={e => setOpponent(e.target.value)}
        />
        <button
          type="button"
          onClick={() => fight(oppponent)}
          disabled={loading}
        >
          {loading ? 'Loading...' : 'Fight!'}
        </button>
        {data ? (
          <div>
            <h2>Minted! Wait for confirmation</h2>
            <pre>{data}</pre>
          </div>
        ) : null}
        {error ? (
          <div>
            <h2>Error!</h2>
            <pre>{error}</pre>
          </div>
        ) : null}
        {data || error ? (
          <button type="button" onClick={reset}>
            Reset
          </button>
        ) : null}
      </div>
    </div>
  )
}

export default FightThings
