import { useStarknet } from '@starknet-react/core'

const Account = () => {
  const { account, disconnect } = useStarknet()
  return (
    <div>
      <h1>Account</h1>
      {account ? (
        <div style={{ display: 'flex', alignItems: 'center', gap: '1ch' }}>
          {account}
          <button onClick={disconnect}>Disconnect</button>
        </div>
      ) : (
        <p>Not Connected</p>
      )}
    </div>
  )
}

export default Account
