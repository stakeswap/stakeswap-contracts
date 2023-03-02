import { parseEther } from 'ethers/lib/utils'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
// import { FraxAdaptor, LidoAdaptor, RocketPoolAdaptor } from '../../../typechain'

export async function increaseAll_2p(hre: HardhatRuntimeEnvironment) {
  await increaseWstETH_2p(hre)
  await increaseRETHprice_2p(hre)
  await increaseSfrxETHprice_2p(hre)
}

export async function increaseWstETH_2p(hre: HardhatRuntimeEnvironment) {
  const [signer] = await hre.ethers.getSigners()

  const la = await hre.ethers.getContract('LidoAdaptor')

  await la.connect(signer).buyToken({ value: parseEther('140000') })
}

export async function increaseRETHprice_2p(hre: HardhatRuntimeEnvironment) {
  const [signer] = await hre.ethers.getSigners()

  const ra = await hre.ethers.getContract('RocketPoolAdaptor')

  await ra.connect(signer).buyToken({ value: parseEther('6130') })
}

export async function increaseSfrxETHprice_2p(hre: HardhatRuntimeEnvironment) {
  const [signer] = await hre.ethers.getSigners()

  const fa = await hre.ethers.getContract('FraxAdaptor')

  await fa.connect(signer).buyToken({ value: parseEther('23000') })
}
