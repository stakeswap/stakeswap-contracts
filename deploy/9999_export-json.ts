import fs, { promises as fsAsync } from 'fs'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers } from 'hardhat'
import path from 'path'
import { formatEther } from 'ethers/lib/utils'

const FILE = path.join(__dirname, '../contract-deployment.json')

// export contract deployment to `contract-deployment.json` file
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre
  const { deploy } = deployments

  const networkName = deployments.getNetworkName()

  // // short circuit for hardhat network
  // if (networkName === "hardhat") return;

  const contracts = await deployments.all()
  const namedAccounts = await getNamedAccounts()
  const { chainId } = await ethers.provider.getNetwork()

  const content = fs.existsSync(FILE) ? await fsAsync.readFile(FILE, 'utf-8') : ''
  const parsed = content ? JSON.parse(content) : {}
  parsed[networkName] = {
    chainId,
    namedAccounts,
    contracts: Object.entries(contracts).reduce((acc, [name, deployment]) => ({ ...acc, [name]: deployment.address }), {})
  }

  console.log('update %s', FILE)
  await fsAsync.writeFile(FILE, JSON.stringify(parsed, null, 2))

  // // log used gas
  // const usedGas = Object.values(contracts).reduce((acc, c) => {
  //   console.log('c.gasEstimates', c.gasEstimates)

  //   return acc + c.gasEstimates
  // }, 0)
  // console.log('usedGas', usedGas)
  // console.log('usedGas (ETH, gasPrice = 1 gwei)', formatEther(usedGas * 1e9))
  // console.log('usedGas (ETH, gasPrice = 20gwei)', formatEther(usedGas * 20e9))
}
export default func
func.tags = ['export-json']
