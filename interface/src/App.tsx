import { useState, Fragment } from 'react'
import {
  StarknetProvider,
  useStarknet,
  useConnectors,
  getInstalledInjectedConnectors,
} from '@starknet-react/core'
import Account from './components/Account'
import ConnectWallet from './components/ConnectWallet'
import MintThing from './components/MintThing'
import Transactions from './components/Transactions'
import MyThing from './components/MyThing'
import FightThings from './/components/FightThings'
import { ThingsAddressProvider } from './contexts/things-address'

import './App.css'

const goerliAddress =
  '0x073c5a77c3d06e780eca1e4e0ec4b8e23e3fedcc046067e33268d902a4e39562'

const mainnetAddress =
  '0x02f118ffe5b7e319ed9874b60739ecf78682ff01c689fa3833825fd8d6c7d099'

const Body = () => {
  const starknet = useStarknet()
  const { account } = starknet

  if (!account) return null

  return (
    <Fragment key={account}>
      <Account />
      <MintThing />
      <MyThing />
      <FightThings />
    </Fragment>
  )
}

const App = () => {
  const connectors = getInstalledInjectedConnectors()
  const [thingsAddress, setThingsAddress] = useState(goerliAddress)

  return (
    <StarknetProvider connectors={connectors}>
      <ThingsAddressProvider address={mainnetAddress}>
        <div className="app">
          <Transactions />
          <ConnectWallet />
          <Body />
        </div>
      </ThingsAddressProvider>
    </StarknetProvider>
  )
}

export default App
