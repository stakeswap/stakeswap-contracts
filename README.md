# StakeSwap Contracts

StakeSwap smart contract implementation for 1) Liquid Staking Aggregator and 2) AMM forked from Uniswap V2.

## Deployment

### Mainnet

```json
{
  "Factory": "0x68b35bAEc7db54028bacE32aE0eD927149E6C1fE",
  "Router": "0xe606ca437EA7Eac743f5304bd85261F7C5BB85A1",
  "LSDAggregator": "0xf05974963f4805038E9Da82429E7f551E9e484D6",
  "FraxAdaptor": "0xB58130DF43ab82C40aa5bB87BE204c404Ff6DF08",
  "LidoAdaptor": "0x0C9A9EbfB6C9F5A46Eb55B1F038C857cda0CA39E",
  "RocketPoolAdaptor": "0xFaBa6E9c5D9a1C2A03d99987ebaE89E15f2eBE70"
}
```

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
