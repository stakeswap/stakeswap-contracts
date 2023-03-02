# StakeSwap Contracts

StakeSwap smart contract implementation for 1) Liquid Staking Aggregator and 2) AMM forked from Uniswap V2.

## Development

1. install [foundry](https://book.getfoundry.sh/getting-started/installation)
2. install [yarn](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable)
3. clone this repository
   ```bash
   git clone https://github.com/stakeswap/stake-swap-contracts.git
   ```
4. install foundry packages:
   ```bash
   forge install
   ```
5. install npm packages:
   ```bash
   yarn install
   ```
6. build contracts
   ```bash
   yarn build
   ```
7. run mainnet-forked testnet
   ```bash
   yarn dev
   ```
8. (optional) manipulate the price of yield-beraing tokens (wstETH, rETH, sfrxETH)
   ```bash
   yarn dev:manipulate-price
   ```
