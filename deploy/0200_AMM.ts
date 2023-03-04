import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers } from 'hardhat'
import { Factory, Pair__factory } from '../typechain'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre
  const { deploy, execute } = deployments

  const { deployer } = await getNamedAccounts()

  const pairInitCodeHash = hre.ethers.utils.solidityKeccak256(['bytes'], [Pair__factory.bytecode])
  console.log('Pair init code hash: %s', pairInitCodeHash.slice(2))

  const LSDAggregator = await deployments.get('LSDAggregator')

  // Factory
  await deploy('Factory', {
    from: deployer,
    args: [deployer, LSDAggregator.address],
    log: true
  })

  const factory: Factory = await ethers.getContract('Factory')
  console.log('factory deployed at %s', factory.address)

  // Router
  await deploy('Router', {
    from: deployer,
    args: [factory.address, await factory.WETH()],
    log: true
  })

  // Pair (only WETH-USDC)
  await execute(
    'Factory',
    {
      from: deployer,
      log: true
    },
    'createPair',
    ...[await factory.WETH(), await factory.USDC()]
  )
}
export default func
func.tags = ['LSDAggregator']
