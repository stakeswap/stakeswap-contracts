import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers } from 'hardhat'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre
  const { deploy } = deployments

  const { deployer } = await getNamedAccounts()

  // Adaptors
  const FraxAdaptorRes = await deploy('FraxAdaptor', {
    from: deployer,
    args: [],
    log: true
  })

  const LidoAdaptorRes = await deploy('LidoAdaptor', {
    from: deployer,
    args: [],
    log: true
  })

  const RocketPoolAdaptorRes = await deploy('RocketPoolAdaptor', {
    from: deployer,
    args: [],
    log: true
  })

  // aggregator

  const adaptors = [FraxAdaptorRes.address, LidoAdaptorRes.address, RocketPoolAdaptorRes.address]
  const depositWeights = [
    500, // frax
    250, // lido
    250 // rocket pool
  ]
  const buyWeights = [
    3_000, // frax
    2_000, // lido
    4_000 // rocket pool
  ]

  const LSDAggregatorRes = await deploy('LSDAggregator', {
    from: deployer,
    args: [adaptors, depositWeights, buyWeights],
    log: true
  })
}
export default func
func.tags = ['LSDAggregator']
