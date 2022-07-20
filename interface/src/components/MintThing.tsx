import { useState, useEffect } from 'react'
import { useStarknet } from '@starknet-react/core'
import { useThingsAddress } from '~/contexts/things-address'
import { encodeShortString } from 'starknet/utils/shortString'
import useThingsMint from '~/hooks/useThingsMint'
import useLocalThings from '~/hooks/useLocalThings'

const MintThing = () => {
  const { account } = useStarknet()
  const address = useThingsAddress()
  const { mint, loading, data, error, reset } = useThingsMint(address)

  const [to, setTo] = useState(account ?? '')
  const [name, setName] = useState('')

  return (
    <div>
      <h3>Mint a Thing!</h3>
      <div
        style={{
          display: 'flex',
          gap: '1ch',
          alignItems: 'center',
        }}
      >
        To:
        <input
          placeholder="To"
          type="text"
          value={to}
          onChange={e => setTo(e.target.value)}
        />
        Name:
        <input
          placeholder="Thing name"
          type="text"
          value={name}
          onChange={e => setName(e.target.value)}
        />
        <button
          type="button"
          onClick={() => mint(to, encodeShortString(name))}
          disabled={loading}
        >
          {loading ? 'Loading...' : 'Mint!'}
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

export default MintThing
