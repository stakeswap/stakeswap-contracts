import hre, { deployments, ethers, getNamedAccounts } from 'hardhat'
import { SnapshotRestorer, takeSnapshot, time } from '@nomicfoundation/hardhat-network-helpers'
import { expect } from 'chai'
import { Factory } from '../../../typechain'
import { formatUnits, parseUnits } from 'ethers/lib/utils'
import { BigNumber } from 'ethers'
import { increaseAll_2p } from '../lib/price-manipulator'
import { latest } from '@nomicfoundation/hardhat-network-helpers/dist/src/helpers/time'

const MaxUint256 = ethers.constants.MaxUint256

describe('AMM', function () {
  this.timeout(100000000)

  beforeEach('load deploy fixture', async function () {
    await deployments.fixture()
  })

  let _s: SnapshotRestorer
  beforeEach('take a snapshot', async function () {
    _s = await takeSnapshot()
  })
  afterEach('rollback', async function () {
    await _s.restore()
  })

  beforeEach('setup contracts and signers', async function () {
    // set signers
    const { deployer, trader0, trader1, trader2, lps0, lps1, lps2 } = await ethers.getNamedSigners()
    this.namedSigners = { deployer, trader0, trader1, trader2, lps0, lps1, lps2 }

    // set contracts
    const factory = (await ethers.getContract('Factory')) as Factory
    const pairAddress_WETH_USDC = await factory.getPair(await factory.WETH(), await factory.USDC())
    const stakingAddress_WETH_USDC = await factory.getStaking(await factory.WETH(), await factory.USDC())
    this.contracts = {
      FraxAdaptor: await ethers.getContract('FraxAdaptor'),
      LidoAdaptor: await ethers.getContract('LidoAdaptor'),
      RocketPoolAdaptor: await ethers.getContract('RocketPoolAdaptor'),
      LSDAggregator: await ethers.getContract('LSDAggregator'),
      Factory: await ethers.getContract('Factory'),
      Router: await ethers.getContract('Router'),
      Pair_WETH_USDC: await ethers.getContractAt('Pair', pairAddress_WETH_USDC),
      Staking_WETH_USDC: await ethers.getContractAt('Staking', stakingAddress_WETH_USDC)
    }

    this.WETH = await ethers.getContractAt('WETHInterface', await factory.WETH())
    this.USDC = await ethers.getContractAt('lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol:ERC20', await factory.USDC())
  })

  it('should run test', async function () {
    const sorted = (await this.contracts.Pair_WETH_USDC.token0()).toLowerCase() === this.WETH.address.toLowerCase()
    const slippageBPS = 100 // 1% of slippage tolerance (in basis points)

    const kDecimals = 27 // 18 (WETH) + 6 (DAI)
    const getK = async () => {
      const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
      return reserve0.mul(reserve1)
    }

    const createKChecker = async () => {
      const Ks = [await getK()]
      const captions = ['']

      const check = async (caption = '') => {
        const newK = await getK()
        const lastK = Ks[Ks.length - 1]
        Ks.push(newK)
        captions.push(caption)

        // allow change at most 1bps
        expect(newK).to.be.closeTo(lastK, lastK.div(10000))
      }

      const calcChange = (prevK: BigNumber, newK: BigNumber) => {
        const diff = newK.sub(prevK)
        return diff.mul(parseUnits('1', kDecimals)).div(prevK)
      }

      const log = async (includeNewK = false) => {
        const ks = [...Ks]
        if (includeNewK) ks.push(await getK())
        ks.forEach((K, i) => {
          const prevK = i === 0 ? undefined : ks[i - 1]
          const change = prevK ? calcChange(prevK, K) : BigNumber.from(0)
          const caption = captions[i]
          if (change.eq(0)) console.log('  K#%s : %s - %s', i, formatUnits(K, kDecimals), caption)
          else console.log('  K#%s : %s - %s\n    (change=%s)', i, formatUnits(K, kDecimals), caption, formatUnits(change, kDecimals))
        })
      }

      const checkAndSyncAndCheckAndLog = async (caption: string) => {
        await check(caption)
        // await this.contracts.Pair_WETH_USDC.skim(this.namedSigners.deployer.address)
        // await check('after skim')
        await this.contracts.Pair_WETH_USDC.sync()
        await check('after sync')
        await log()
      }

      return {
        check,
        log,
        checkAndSyncAndCheckAndLog
      }
    }

    /* 1. add liquidity (lps0, lps1) */
    {
      const lps = [this.namedSigners.lps0, this.namedSigners.lps1] // a list of liquidity providers

      // iterate over liquidity providers
      for (const lp of lps) {
        // approve token pair to router
        await this.WETH.connect(lp).approve(this.contracts.Router.address, MaxUint256)
        await this.USDC.connect(lp).approve(this.contracts.Router.address, MaxUint256)

        // add liquidity
        const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
        const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)

        const ethAmount = parseUnits('0.1', 18)
        const usdcAmount =
          reserve0.eq(0) && reserve1.eq(0) ? parseUnits('160', 6) : await this.contracts.Router.quote(ethAmount, ethReserve, usdcReserve)

        console.log('1. add liquidity')
        console.log('  ethReserve  ', formatUnits(ethReserve, 18))
        console.log('  usdcReserve ', formatUnits(usdcReserve, 6))
        console.log('  ethAmount   ', formatUnits(ethAmount, 18))
        console.log('  usdcAmount  ', formatUnits(usdcAmount, 6))

        const tx = this.contracts.Router.connect(lp).addLiquidityETH(
          this.USDC.address,
          usdcAmount,
          usdcAmount,
          ethAmount,
          lp.address,
          (await time.latest()) + 1000,
          {
            value: ethAmount
          }
        )

        await expect(tx).to.changeTokenBalance(this.USDC, this.contracts.Pair_WETH_USDC, usdcAmount)
        await expect(tx).to.changeTokenBalance(this.USDC, lp, usdcAmount.mul(-1))
        await expect(tx).to.changeTokenBalance(this.WETH, this.contracts.Pair_WETH_USDC, ethAmount)
        await expect(tx).to.changeEtherBalance(lp, ethAmount.mul(-1))

        expect(await this.contracts.Pair_WETH_USDC.balanceOf(lp.address)).to.be.gt(0)
      }
    }

    // create KChecker after add liquidity
    const kChecker = await createKChecker()

    // TODO: check K is not changed after sync
    /* 2. trade before stake (trader0, trader1) */
    {
      console.log('2. trade')

      // trader0: swap ETH for USDC
      {
        const trader = this.namedSigners.trader0
        // try to swap 0.001 ETH
        const ethAmountIn = parseUnits('0.001', 18)

        // calculate min USDC amount
        const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
        const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)

        const usdcAmountOut = await this.contracts.Router.getAmountOut(ethAmountIn, ethReserve, usdcReserve)
        const minUsdcAmountOut = usdcAmountOut.mul(10_000 - slippageBPS).div(10_000)

        console.log('2.1 trade0: ETH -> USDC')
        console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
        console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        console.log('  ethAmount        : %s', formatUnits(ethAmountIn, 18))
        console.log('  usdcAmountOut    : %s', formatUnits(usdcAmountOut, 6))
        console.log('  minUsdcAmountOut : %s', formatUnits(minUsdcAmountOut, 6))

        // send tx to swap
        const tx = await this.contracts.Router.connect(trader).swapExactETHForTokens(
          minUsdcAmountOut,
          [this.WETH.address, this.USDC.address],
          trader.address,
          (await time.latest()) + 1000,
          {
            value: ethAmountIn
          }
        )
        await expect(tx).to.changeEtherBalance(trader, ethAmountIn.mul(-1))
        await expect(tx).to.changeTokenBalance(this.USDC, trader, usdcAmountOut)
        console.log('SWAP DONE')
        await kChecker.checkAndSyncAndCheckAndLog('trader0: swap ETH for USDC')

        {
          const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
          const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)
          console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
          console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        }
      }

      // trader1: swap USDC for WETH
      {
        const trader = this.namedSigners.trader1
        await this.USDC.connect(trader).approve(this.contracts.Router.address, MaxUint256)
        // try to swap 1.6 USDC
        const usdcAmountIn = parseUnits('1.6', 6)

        // calculate min USDC amount
        const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
        const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)

        const wethAmountOut = await this.contracts.Router.getAmountOut(usdcAmountIn, usdcReserve, ethReserve)
        const minWethAmountOut = wethAmountOut.mul(10_000 - slippageBPS).div(10_000)

        console.log('2.2 trade1: USDC -> ETH')
        console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
        console.log('  usdcAmountIn     : %s', formatUnits(usdcAmountIn, 6))
        console.log('  wethAmountOut    : %s', formatUnits(wethAmountOut, 18))
        console.log('  minWethAmountOut : %s', formatUnits(minWethAmountOut, 18))

        // send tx to swap
        const tx = await this.contracts.Router.connect(trader).swapExactTokensForTokens(
          usdcAmountIn,
          minWethAmountOut,
          [this.USDC.address, this.WETH.address],
          trader.address,
          (await time.latest()) + 1000
        )
        await expect(tx).to.changeTokenBalance(this.USDC, trader, usdcAmountIn.mul(-1))
        await expect(tx).to.changeTokenBalance(this.WETH, trader, wethAmountOut)

        console.log('SWAP DONE')
        await kChecker.checkAndSyncAndCheckAndLog('trader1: swap USDC for WETH')

        {
          const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
          const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)
          console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
          console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        }
      }
    }

    /* 3. stake LP (lps0) */
    {
      const lp = this.namedSigners.lps0
      const lpAmount = await this.contracts.Pair_WETH_USDC.balanceOf(lp.address)

      const [beforeReserve0, beforeReserve1] = await this.contracts.Pair_WETH_USDC.getReserves()

      // approve LP to router
      await this.contracts.Pair_WETH_USDC.connect(lp).approve(this.contracts.Router.address, MaxUint256)

      // stake LP to staking
      await this.contracts.Router.connect(lp).stake(this.WETH.address, this.USDC.address, lpAmount, (await time.latest()) + 10)

      // reserves shoult now changed after stake and sync
      await this.contracts.Pair_WETH_USDC.sync()
      const [afterReserve0, afterReserve1] = await this.contracts.Pair_WETH_USDC.getReserves()

      expect(afterReserve0).to.be.eq(beforeReserve0)
      expect(afterReserve1).to.be.eq(beforeReserve1)

      // LP should be zero and STK shoule be gt zero
      expect(await this.contracts.Pair_WETH_USDC.balanceOf(lp.address)).to.be.eq(0)
      expect(await this.contracts.Staking_WETH_USDC.balanceOf(lp.address)).to.be.gt(0)

      await kChecker.checkAndSyncAndCheckAndLog('stake LP (lps0)')
    }

    /* 4. trade after stake (trader0, trader1) */
    {
      console.log('4. trade')
      // trader0: swap ETH for USDC
      {
        const trader = this.namedSigners.trader0
        // try to swap 0.001 ETH
        const ethAmountIn = parseUnits('0.001', 18)

        // calculate min USDC amount
        const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
        const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)

        const usdcAmountOut = await this.contracts.Router.getAmountOut(ethAmountIn, ethReserve, usdcReserve)
        const minUsdcAmountOut = usdcAmountOut.mul(10_000 - slippageBPS).div(10_000)

        console.log('4.1 trade0: ETH -> USDC')
        console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
        console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        console.log('  ethAmount        : %s', formatUnits(ethAmountIn, 18))
        console.log('  usdcAmountOut    : %s', formatUnits(usdcAmountOut, 6))
        console.log('  minUsdcAmountOut : %s', formatUnits(minUsdcAmountOut, 6))

        // send tx to swap
        const tx = await this.contracts.Router.connect(trader).swapExactETHForTokens(
          minUsdcAmountOut,
          [this.WETH.address, this.USDC.address],
          trader.address,
          (await time.latest()) + 1000,
          {
            value: ethAmountIn
          }
        )
        await expect(tx).to.changeEtherBalance(trader, ethAmountIn.mul(-1))
        await expect(tx).to.changeTokenBalance(this.USDC, trader, usdcAmountOut)
        console.log('SWAP DONE')
        await kChecker.checkAndSyncAndCheckAndLog('trader0: swap ETH for USDC')

        {
          const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
          const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)
          console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
          console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        }
      }

      // trader1: swap USDC for WETH
      {
        const trader = this.namedSigners.trader1
        await this.USDC.connect(trader).approve(this.contracts.Router.address, MaxUint256)
        // try to swap 1.6 USDC
        const usdcAmountIn = parseUnits('1.6', 6)

        // calculate min USDC amount
        const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
        const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)

        const wethAmountOut = await this.contracts.Router.getAmountOut(usdcAmountIn, usdcReserve, ethReserve)
        const minWethAmountOut = wethAmountOut.mul(10_000 - slippageBPS).div(10_000)

        console.log('4.2 trade1: USDC -> ETH')
        console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
        console.log('  usdcAmountIn     : %s', formatUnits(usdcAmountIn, 6))
        console.log('  wethAmountOut    : %s', formatUnits(wethAmountOut, 18))
        console.log('  minWethAmountOut : %s', formatUnits(minWethAmountOut, 18))

        // send tx to swap
        const tx = await this.contracts.Router.connect(trader).swapExactTokensForTokens(
          usdcAmountIn,
          minWethAmountOut,
          [this.USDC.address, this.WETH.address],
          trader.address,
          (await time.latest()) + 1000
        )
        await expect(tx).to.changeTokenBalance(this.USDC, trader, usdcAmountIn.mul(-1))
        await expect(tx).to.changeTokenBalance(this.WETH, trader, wethAmountOut)

        console.log('SWAP DONE')
        await kChecker.checkAndSyncAndCheckAndLog('trader1: swap USDC for WETH')

        {
          const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
          const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)
          console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
          console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        }
      }
    }

    /* 5. manipulate price */
    {
      console.log('5. manipulate price')

      await increaseAll_2p(hre)
    }

    /* 6. unstake LP (lps0) */
    {
      console.log('6. unstake LP (lps0)')

      const lp = this.namedSigners.lps0

      // approve STK to router
      await this.contracts.Staking_WETH_USDC.connect(lp).approve(this.contracts.Router.address, MaxUint256)

      // get expected rewards
      const shares = await this.contracts.Staking_WETH_USDC.balanceOf(lp.address)
      expect(shares).to.be.gt(0)
      // NOTE: we cannot but to use callstatic because aggregator cannot calculate previewRedeem because the prices are manipulated in DEXes.
      const {
        lp: lpAmount,
        ethAmount,
        poolETHAmount,
        rewardToStaker
      } = await this.contracts.Router.connect(lp).callStatic.unstake(this.USDC.address, this.WETH.address, shares, (await latest()) + 1000)

      console.log('lpAmount         ', formatUnits(lpAmount, 18))
      console.log('ethAmount        ', formatUnits(ethAmount, 18))
      console.log('poolETHAmount    ', formatUnits(poolETHAmount, 18))
      console.log('rewardToStaker   ', formatUnits(rewardToStaker, 18))

      // TX: unstake
      const tx = await this.contracts.Router.connect(lp).unstake(this.USDC.address, this.WETH.address, shares, (await latest()) + 1000)

      await expect(tx).changeTokenBalance(this.contracts.Pair_WETH_USDC, lp, lpAmount)
      await expect(tx).changeTokenBalance(this.WETH, this.contracts.Pair_WETH_USDC, poolETHAmount)
      // ether balance change checker doesn't work properly. see more blow log
      //     AssertionError: Expected the ether balance of "0x63AA4072218196AFADCb7F0aFCbf3AabEE201c0a" to change by 824190345753832 wei, but it changed by 824190398842923 wei
      // await expect(tx).changeEtherBalance(lp, rewardToStaker)

      await kChecker.checkAndSyncAndCheckAndLog('unstake LP (lps0)')

      expect(await this.contracts.Pair_WETH_USDC.stakedWETHAmount()).to.be.eq(0)
    }

    /* 7. trade after unstake (trader0, trader1) */
    {
      console.log('7. trade after unstake (trader0, trader1)')

      // trader0: swap ETH for USDC
      {
        const trader = this.namedSigners.trader0
        // try to swap 0.001 ETH
        const ethAmountIn = parseUnits('0.001', 18)

        // calculate min USDC amount
        const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
        const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)

        const usdcAmountOut = await this.contracts.Router.getAmountOut(ethAmountIn, ethReserve, usdcReserve)
        const minUsdcAmountOut = usdcAmountOut.mul(10_000 - slippageBPS).div(10_000)

        console.log('7.1 trade0: ETH -> USDC')
        console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
        console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        console.log('  ethAmount        : %s', formatUnits(ethAmountIn, 18))
        console.log('  usdcAmountOut    : %s', formatUnits(usdcAmountOut, 6))
        console.log('  minUsdcAmountOut : %s', formatUnits(minUsdcAmountOut, 6))

        // send tx to swap
        const tx = await this.contracts.Router.connect(trader).swapExactETHForTokens(
          minUsdcAmountOut,
          [this.WETH.address, this.USDC.address],
          trader.address,
          (await time.latest()) + 1000,
          {
            value: ethAmountIn
          }
        )
        await expect(tx).to.changeEtherBalance(trader, ethAmountIn.mul(-1))
        await expect(tx).to.changeTokenBalance(this.USDC, trader, usdcAmountOut)
        console.log('SWAP DONE')
        await kChecker.checkAndSyncAndCheckAndLog('trader0: swap ETH for USDC')

        {
          const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
          const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)
          console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
          console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        }
      }

      // trader1: swap USDC for WETH
      {
        const trader = this.namedSigners.trader1
        await this.USDC.connect(trader).approve(this.contracts.Router.address, MaxUint256)
        // try to swap 1.6 USDC
        const usdcAmountIn = parseUnits('1.6', 6)

        // calculate min USDC amount
        const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
        const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)

        const wethAmountOut = await this.contracts.Router.getAmountOut(usdcAmountIn, usdcReserve, ethReserve)
        const minWethAmountOut = wethAmountOut.mul(10_000 - slippageBPS).div(10_000)

        console.log('7.2 trade1: USDC -> ETH')
        console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
        console.log('  usdcAmountIn     : %s', formatUnits(usdcAmountIn, 6))
        console.log('  wethAmountOut    : %s', formatUnits(wethAmountOut, 18))
        console.log('  minWethAmountOut : %s', formatUnits(minWethAmountOut, 18))

        // send tx to swap
        const tx = await this.contracts.Router.connect(trader).swapExactTokensForTokens(
          usdcAmountIn,
          minWethAmountOut,
          [this.USDC.address, this.WETH.address],
          trader.address,
          (await time.latest()) + 1000
        )
        await expect(tx).to.changeTokenBalance(this.USDC, trader, usdcAmountIn.mul(-1))
        await expect(tx).to.changeTokenBalance(this.WETH, trader, wethAmountOut)

        console.log('SWAP DONE')
        await kChecker.checkAndSyncAndCheckAndLog('trader1: swap USDC for WETH')

        {
          const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
          const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)
          console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
          console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        }
      }
    }

    /* 8. remove liquidity (lps0, lps1) */
    {
      console.log('8. remove liquidity (lps0, lps1)')
      const lps = [this.namedSigners.lps0, this.namedSigners.lps1] // a list of liquidity providers

      // iterate over liquidity providers
      let i = -1
      for (const lp of lps) {
        console.log('8.%s remove liquidity', ++i)

        // approve LP to router
        await this.contracts.Pair_WETH_USDC.connect(lp).approve(this.contracts.Router.address, MaxUint256)

        // remove liquidity
        const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
        const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)

        const lpAmount = await this.contracts.Pair_WETH_USDC.balanceOf(lp.address)
        const lpTotalSupply = await this.contracts.Pair_WETH_USDC.totalSupply()
        const ethAmount = ethReserve.mul(lpAmount).div(lpTotalSupply)
        const usdcAmount = usdcReserve.mul(lpAmount).div(lpTotalSupply)

        console.log('8. remove liquidity')
        console.log('  ethReserve     ', formatUnits(ethReserve, 18))
        console.log('  usdcReserve    ', formatUnits(usdcReserve, 6))
        console.log('  ethAmount      ', formatUnits(ethAmount, 18))
        console.log('  usdcAmount     ', formatUnits(usdcAmount, 6))
        console.log('  lpAmount       ', formatUnits(lpAmount, 18))
        console.log('  lpTotalSupply  ', formatUnits(lpTotalSupply, 18))

        const tx = this.contracts.Router.connect(lp).removeLiquidity(
          this.WETH.address,
          this.USDC.address,
          lpAmount,
          ethAmount,
          usdcAmount,
          lp.address,
          (await time.latest()) + 1000
        )
        console.log('REMOVE LIQUIDITY')

        await expect(tx).to.changeTokenBalance(this.WETH, this.contracts.Pair_WETH_USDC, ethAmount.mul(-1))
        await expect(tx).to.changeTokenBalance(this.WETH, lp, ethAmount)
        await expect(tx).to.changeTokenBalance(this.USDC, this.contracts.Pair_WETH_USDC, usdcAmount.mul(-1))
        await expect(tx).to.changeTokenBalance(this.USDC, lp, usdcAmount)
        await expect(tx).to.changeTokenBalance(this.contracts.Pair_WETH_USDC, lp, lpAmount.mul(-1))

        {
          const [reserve0, reserve1] = await this.contracts.Pair_WETH_USDC.getReserves()
          const [ethReserve, usdcReserve] = sortValueIfSorted(sorted, reserve0, reserve1)
          console.log('  ethReserve       : %s', formatUnits(ethReserve, 18))
          console.log('  usdcReserve      : %s', formatUnits(usdcReserve, 6))
        }
      }
    }
  })
})

function isSorted(token0: string, token1: string) {
  return token0.toLowerCase() < token1.toLowerCase()
}

function sortValueIfSorted<T>(sorted: boolean, valueA: T, valueB: T): [T, T] {
  if (sorted) return [valueA, valueB]
  return [valueB, valueA]
}

function sortValue<T>(token0: string, token1: string, valueA: T, valueB: T): [T, T] {
  return sortValueIfSorted(isSorted(token0, token1), valueA, valueB)
}
