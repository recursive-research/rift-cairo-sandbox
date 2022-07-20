import { useConnectors } from '@starknet-react/core'

const ConnectWallet = () => {
  const { connect, connectors } = useConnectors()
  return (
    <div>
      <h3>Connect Wallet</h3>
      <div style={{ display: 'flex', gap: '1ch' }}>
        {connectors.map(connector =>
          connector.available() ? (
            <button key={connector.id()} onClick={() => connect(connector)}>
              Connect {connector.name()}
            </button>
          ) : null,
        )}
      </div>
    </div>
  )
}

export default ConnectWallet
