// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';

import { IERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import { ILido as ST_ETH } from '../lib/ILido.sol';
import { IWstETH as WST_ETH } from '../lib/IWstETH.sol';

import { BaseAdaptor } from './BaseAdaptor.sol';
import { IrETH as R_ETH } from '../lib/IrETH.sol';
import { RocketStorageInterface } from '../lib/RocketStorageInterface.sol';
import { RocketDepositPoolInterface } from '../lib/RocketDepositPoolInterface.sol';
import { RocketDAOProtocolSettingsDepositInterface } from '../lib/RocketDAOProtocolSettingsDepositInterface.sol';
import { RocketVaultInterface } from '../lib/RocketVaultInterface.sol';
import { frxETHMinter as FrxETHMinter } from '../../lib/frxETH-public/src/frxETHMinter.sol';
import { BalancerV2VaultInterface } from '../lib/balancer-v2/interfaces/BalancerV2VaultInterface.sol';
import { WETHInterface } from '../lib/WETHInterface.sol';

// deposit: ETH -> rETH
//
contract RocketPoolAdaptor is BaseAdaptor {
    uint256 private constant _serviceStartedAt = 1632980091; // rETH contract created at 1632980091 (block number = 13325250)
    uint256 private immutable _adaptorDeployed = block.timestamp;

    /// @dev return a name of adaptor
    function adaptorName() public pure override returns (string memory) {
        return 'rocketpool';
    }

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    function getTokens() public view override returns (address token0, address token1) {
        token0 = address(0);
        token1 = address(rETH());
    }

    function getETHAmount(uint256 tokenAmount) public view override returns (uint256) {
        return rETH().getEthValue(tokenAmount);
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

    function canWithdraw(uint256 amount) public pure override returns (bool) {
        return false;
    }

    function _withdraw(uint256) internal pure override returns (uint256) {
        // direct converting rETH to ETH in lido system is not supported.
        // instead, use Curve's rETH-ETH pool
        return 0;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // BUY-SELL
    ////////////////////////////////////////////////////////////////////////////////////////////

    /// @dev use Balancer's WETH-rETH pool to buy rETH
    function _buyToken() internal override returns (uint256) {
        BalancerV2VaultInterface _BalancerV2Vault = BalancerV2Vault();

        BalancerV2VaultInterface.SingleSwap memory singleSwap;
        singleSwap.poolId = BalancerV2_rETH_ETH_POOL_ID(); // https://etherscan.io/address/0x1e19cf2d73a72ef1332c882f20534b6519be0276/advanced#readContract
        singleSwap.kind = BalancerV2VaultInterface.SwapKind.GIVEN_IN;
        singleSwap.assetIn = address(0); // ETH
        singleSwap.assetOut = address(rETH()); // rETH
        singleSwap.amount = msg.value;
        singleSwap.userData = ''; // set empty bytes to avoid invoking `onSwap` hook of the pool

        BalancerV2VaultInterface.FundManagement memory funds;
        funds.sender = address(this); // use token0 held in `this` contract to swap
        funds.fromInternalBalance = false; // send ERC20 token directly, not updating deposit balance of the pool
        funds.recipient = payable(address(this)); // receive token1 to `this` contract during swap
        funds.toInternalBalance = false; // receive ERC20 token directly, not updating deposit balance of the pool

        return _BalancerV2Vault.swap{ value: msg.value }(singleSwap, funds, 0, block.timestamp);
    }

    /// @dev use Balancer's WETH-rETH pool to sell rETH for WETH
    function _sellToken(uint256 amount) internal override returns (uint256) {
        BalancerV2VaultInterface _BalancerV2Vault = BalancerV2Vault();

        rETH().approve(address(_BalancerV2Vault), amount);

        BalancerV2VaultInterface.SingleSwap memory singleSwap;
        singleSwap.poolId = BalancerV2_rETH_ETH_POOL_ID();
        singleSwap.kind = BalancerV2VaultInterface.SwapKind.GIVEN_IN;
        singleSwap.assetIn = address(rETH()); // rETH
        singleSwap.assetOut = address(WETH()); // WETH
        singleSwap.amount = amount;
        singleSwap.userData = ''; // set empty bytes to avoid invoking `onSwap` hook of the pool

        BalancerV2VaultInterface.FundManagement memory funds;
        funds.sender = address(this); // use token0 held in `this` contract to swap
        funds.fromInternalBalance = false; // send ERC20 token directly, not updating deposit balance of the pool
        funds.recipient = payable(address(this)); // receive token1 to `this` contract during swap
        funds.toInternalBalance = false; // receive ERC20 token directly, not updating deposit balance of the pool

        // rETH -> WETH
        uint256 wethAmount = _BalancerV2Vault.swap(singleSwap, funds, 0, block.timestamp);

        // WETH -> ETH
        WETH().withdraw(wethAmount);

        return wethAmount;
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
