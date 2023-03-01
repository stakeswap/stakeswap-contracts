import '@nomicfoundation/hardhat-foundry'
import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import { SolcUserConfig } from 'hardhat/types'
import 'hardhat-deploy'
import { config as dotenvConfig } from 'dotenv'
import 'hardhat-gas-reporter'

import { parseEther } from 'ethers/lib/utils'
import invariant from 'invariant'
// import "./tasks";

dotenvConfig()

const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL
invariant(MAINNET_RPC_URL, 'MAINNET_RPC_URL env var must be provided')

// const BAIL = process.argv.includes("--bail") || process.argv.includes("-b");

// mnemonic phrases for each network
const DEFAULT_MNEMONIC = 'maze drift razor shy spring stick name sell lobster drink blossom cost' ?? process.env.DEFAULT_MNEMONIC
const MAINNET_MNEMONIC = process.env.MAINNET_MNEMONIC ?? DEFAULT_MNEMONIC

const DEFAULT_COMPILER_SETTINGS: SolcUserConfig = {
  version: '0.8.17',
  settings: {
    // viaIR: true,
    optimizer: {
      enabled: true,
      runs: 200
    },
    metadata: {
      bytecodeHash: 'none'
    }
  }
}

const config: HardhatUserConfig = {
  namedAccounts: {
    deployer: {
      default: 0
    },
    trader0: {
      default: 1
    },
    trader1: {
      default: 2
    },
    trader2: {
      default: 3
    },
    lps0: {
      default: 4
    },
    lps1: {
      default: 5
    },
    lps2: {
      default: 6
    }
  },
  networks: {
    hardhat: {
      // TODO: should be false after refactor contracts...
      allowUnlimitedContractSize: true,

      chainId: 1, // always miannet
      forking: {
        url: MAINNET_RPC_URL
      },
      accounts: {
        mnemonic: DEFAULT_MNEMONIC,
        accountsBalance: parseEther('10000000000').toString()
      }
    },
    localhost: {
      url: 'http://localhost:8545',
      accounts: {
        mnemonic: DEFAULT_MNEMONIC
      }
    },
    mainnet: {
      url: MAINNET_RPC_URL,
      accounts: {
        mnemonic: MAINNET_MNEMONIC
      }
    }
  },

  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS]
  },

  typechain: {
    outDir: 'typechain'
  },

  gasReporter: {
    enabled: true,
    currency: 'USD',
    // gasPrice: 21
    src: 'src'
  }

  // mocha: {
  //   bail: BAIL,
  // },
}

export default config
