import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers } from 'hardhat'
import { setStorageAt } from '@nomicfoundation/hardhat-network-helpers'
import { parseUnits } from 'ethers/lib/utils'
import { ERC20 } from '../typechain'
import invariant from 'invariant'

// export contract deployment to `contract-deployment.json` file
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre
  const { deploy } = deployments

  const networkName = deployments.getNetworkName()

  // only run this script hardhat, localhost network
  if (networkName !== 'hardhat' && networkName !== 'localhost') return
  console.log('Try to manipulate USDC token balance')

  const { trader0, trader1, trader2, lps0, lps1 } = await getNamedAccounts()

  const holders = [trader0, trader1, trader2, lps0, lps1]

  const USDC: ERC20 = await ethers.getContractAt(
    'lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol:ERC20',
    '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'
  )

  for (const holder of holders) {
    const slot = ethers.utils.solidityKeccak256(
      ['uint256', 'uint256'],
      [holder, 9] // key, slot
    )
    await setStorageAt(USDC.address, slot, parseUnits('10000', 6))

    const balance = await USDC.balanceOf(holder)
    invariant(balance.gt(0), 'balance not increased')
  }
}
export default func
func.tags = ['manipulate_usdc']

/**
 * 
 * 

[ 0 ]    address private _owner;
[ 1 ]    address public pauser;
[ 1 ]    bool public paused = false;
[ 2 ]    address public blacklister;
[ 3 ]    mapping(address => bool) internal blacklisted;
[ 4 ]    string public name;
[ 5 ]    string public symbol;
[ 6 ]    uint8 public decimals;
[ 7 ]    string public currency;
[ 8 ]    address public masterMinter;
[ 8 ]    bool internal initialized;
[ 9 ]    mapping(address => uint256) internal balances;

 */
