import { task } from 'hardhat/config'
import { increaseAll_2p } from '../test/hardhat/lib/price-manipulator'

task('manipulate-price', 'manipulate price of LSD DEXes').setAction(async (taskArgs, hre, runSuper) => {
  await increaseAll_2p(hre)
})
