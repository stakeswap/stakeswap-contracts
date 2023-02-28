// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';

import { BaseAdapter } from './BaseAdapter.sol';
import { IrETH as R_ETH } from '../lib/IrETH.sol';
import { RocketStorageInterface } from '../lib/RocketStorageInterface.sol';
import { RocketDepositPoolInterface } from '../lib/RocketDepositPoolInterface.sol';
import { RocketDAOProtocolSettingsDepositInterface } from '../lib/RocketDAOProtocolSettingsDepositInterface.sol';
import { RocketVaultInterface } from '../lib/RocketVaultInterface.sol';

// deposit: ETH -> rETH
//
contract RocketPoolAdapter is BaseAdapter {
    uint256 private constant _serviceStartedAt = 1632980091; // rETH contract created at 1632980091 (block number = 13325250)
    uint256 private immutable _adaptorDeployed = block.timestamp;

    /// @dev return a name of adaptor
    function adaptorName() public pure override returns (string memory) {
        return 'rocketpool';
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Getter - tokens
    ////////////////////////////////////////////////////////////////////////////////////////////

    function rETH() public view returns (R_ETH) {
        if (block.chainid == 1) return R_ETH(payable(0xae78736Cd615f374D3085123A210448E74Fc6393));
        if (block.chainid == 5) return R_ETH(payable(0xae78736Cd615f374D3085123A210448E74Fc6393));
        revert('unknown chain id');
    }

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    function getTokens() public view override returns (address token0, address token1, address token2) {
        token0 = address(rETH());
        token1; // = address(0);
        token2; // = address(0);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Getter - Rocket Pool system
    ////////////////////////////////////////////////////////////////////////////////////////////

    // get RocketStorage
    function rocketPoolStorage() public view returns (RocketStorageInterface) {
        if (block.chainid == 1) return RocketStorageInterface((0x1d8f8f00cfa6758d7bE78336684788Fb0ee0Fa46));
        // if (block.chainid == 5) return RocketStorageInterface((0xae78736Cd615f374D3085123A210448E74Fc6393));
        revert('unknown chain id');
    }

    // get RocketDrocketDepositPool
    function getRocketDrocketDepositPool() public view returns (RocketDepositPoolInterface) {
        return RocketDepositPoolInterface(payable(getRocketPoolContractAddresst('rocketDepositPool')));
    }

    // get RocketDAOProtocolSettingsDeposit
    function getRocketDAOProtocolSettingsDeposit() public view returns (RocketDAOProtocolSettingsDepositInterface) {
        return RocketDAOProtocolSettingsDepositInterface(getRocketPoolContractAddresst('rocketDAOProtocolSettingsDeposit'));
    }

    // get RocketVault
    function getRocketVault() public view returns (RocketVaultInterface) {
        return RocketVaultInterface(getRocketPoolContractAddresst('rocketVault'));
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Deposit
    ////////////////////////////////////////////////////////////////////////////////////////////

    // https://github.com/rocket-pool/rocketpool/blob/master/contracts/contract/deposit/RocketDepositPool.sol#L73-L91
    function canDeposit(uint256 amount) public view override returns (bool) {
        RocketDAOProtocolSettingsDepositInterface rocketDAOProtocolSettingsDeposit = getRocketDAOProtocolSettingsDeposit();

        if (!rocketDAOProtocolSettingsDeposit.getDepositEnabled()) return false;
        if (amount < rocketDAOProtocolSettingsDeposit.getMinimumDeposit()) return false;

        RocketVaultInterface rocketVault = getRocketVault();
        if (rocketVault.balanceOf('rocketDepositPool') + amount > rocketDAOProtocolSettingsDeposit.getMaximumDepositPoolSize())
            return false;

        return true;
    }

    // TODO: cannot implement and test now since rocket pool doesn't accept deposit now; revert with reason string: "The deposit pool size after depositing exceeds the maximum size"
    // Rocket Pool frontend buy rETH from DEX instead of deposit to RocketDepositPool contract
    /// @dev deposit ETH to receive sfrxETH.
    function _deposit() internal override returns (uint256) {
        // ETH -> rETH
        getRocketDrocketDepositPool().deposit{ value: msg.value }();

        // TODO: get the exact amount fo rETH
        return 0;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Withdraw
    ////////////////////////////////////////////////////////////////////////////////////////////

    function canWithdraw() public pure override returns (bool) {
        return false;
    }

    function _withdraw(uint256) internal pure override returns (uint256) {
        // direct converting rETH to ETH in lido system is not supported.
        // instead, use Curve's rETH-ETH pool
        return 0;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // MISC
    ////////////////////////////////////////////////////////////////////////////////////////////

    /// @dev returns APR since Lido staking launch
    function getAPR() public view override returns (uint256) {
        uint256 exchangeRate = rETH().getExchangeRate();

        if (exchangeRate == 0) return 0;
        uint256 span = block.timestamp - _serviceStartedAt;

        return
            // accumulated reward ratio (in wei)
            ((exchangeRate - 1 ether) * (365.25 days)) / span;
    }

    /////////////////////////////////////////////////////////////////////
    // MISC: Rocket Pool contract address getter
    /////////////////////////////////////////////////////////////////////

    /// @dev Get the address of a network contract by name
    function getRocketPoolContractAddresst(string memory _contractName) public view returns (address) {
        // Get the current contract address
        address contractAddress = _getRocketPoolAddress(keccak256(abi.encodePacked('contract.address', _contractName)));
        // Check it
        require(contractAddress != address(0x0), 'Contract not found');
        // Return
        return contractAddress;
    }

    function _getRocketPoolAddress(bytes32 _key) private view returns (address) {
        return rocketPoolStorage().getAddress(_key);
    }
}
