import hre, { deployments, ethers, getNamedAccounts } from 'hardhat'
import { expect } from 'chai'

describe('AMM', function () {
  beforeEach('setup contracts and signers', async function () {
    await deployments.fixture()
  })

  it('should deploy contracts', async function () {})
})
