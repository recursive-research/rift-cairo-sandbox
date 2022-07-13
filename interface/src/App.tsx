import {
  StarknetProvider,
  useStarknet,
  useConnectors,
  getInstalledInjectedConnectors,
} from '@starknet-react/core'
import Account from './components/Account'
import ConnectWallet from './components/ConnectWallet'
import './App.css'

const App = () => {
  const connectors = getInstalledInjectedConnectors()
  return (
    <StarknetProvider connectors={connectors}>
      <div className="App">
        <ConnectWallet />
        <Account />
      </div>
    </StarknetProvider>
  )
}

export default App
