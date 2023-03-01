// eslint-disable @typescript-eslint/no-explicit-any
import { JsonRpcSigner } from '@ethersproject/providers'
import { Fixture } from 'ethereum-waffle'

import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

import { FraxAdaptor, LidoAdaptor, RocketPoolAdaptor, LSDAggregator, Factory, Router, Pair, Staking } from '../typechain'
import { ERC20, WETHInterface } from '../typechain'

declare module 'mocha' {
  export interface Context {
    loadFixture: <T>(fixture: Fixture<T>) => Promise<T>

    WETH: WETHInterface
    USDC: ERC20

    // accounts
    namedSigners: {
      deployer: SignerWithAddress
      trader0: SignerWithAddress
      trader1: SignerWithAddress
      trader2: SignerWithAddress
      lps0: SignerWithAddress
      lps1: SignerWithAddress
      lps2: SignerWithAddress
    }

    // contracts
    contracts: {
      FraxAdaptor: FraxAdaptor
      LidoAdaptor: LidoAdaptor
      RocketPoolAdaptor: RocketPoolAdaptor
      LSDAggregator: LSDAggregator
      Factory: Factory
      Router: Router
      Pair_WETH_USDC: Pair
      Staking_WETH_USDC: Staking
    }
  }
}
