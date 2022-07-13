import { useConnectors } from '@starknet-react/core'

const ConnectWallet = () => {
  const { connect, connectors } = useConnectors()
  return (
    <div>
      <h1>Connect Wallet</h1>
      {connectors.map((connector) =>
        connector.available() ? (
          <button key={connector.id()} onClick={() => connect(connector)}>
            Connect {connector.name()}
          </button>
        ) : null,
      )}
    </div>
  )
}

export default ConnectWallet
