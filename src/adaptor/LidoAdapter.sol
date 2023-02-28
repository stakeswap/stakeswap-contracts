// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import { BaseAdapter } from './BaseAdapter.sol';
import { ILido as ST_ETH } from '../lib/ILido.sol';
import { IWstETH as WST_ETH } from '../lib/IWstETH.sol';

// deposit: ETH -> wstETH
//
contract LidoAdapter is BaseAdapter {
    uint256 private constant _serviceStartedAt = 1608242396; // stETH contract created at 1608242396 (block number = 11473216)
    uint256 private immutable _adaptorDeployed = block.timestamp;

    /// @dev return a name of adaptor
    function adaptorName() public pure override returns (string memory) {
        return 'lido';
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Getter - tokens
    ////////////////////////////////////////////////////////////////////////////////////////////

    function stETH() public view returns (ST_ETH) {
        if (block.chainid == 1) return ST_ETH(payable(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84));
        if (block.chainid == 5) return ST_ETH(payable(0x1643E812aE58766192Cf7D2Cf9567dF2C37e9B7F));
        revert('unknown chain id');
    }

    function wstETH() public view returns (WST_ETH) {
        if (block.chainid == 1) return WST_ETH(payable(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0));
        if (block.chainid == 5) return WST_ETH(payable(0x6320cD32aA674d2898A68ec82e869385Fc5f7E2f));
        revert('unknown chain id');
    }

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    function getTokens() public view override returns (address token0, address token1, address token2) {
        token0 = address(wstETH());
        token1 = address(stETH());
        token2 = address(0);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Deposit
    ////////////////////////////////////////////////////////////////////////////////////////////

    // https://github.com/lidofinance/lido-dao/blob/master/contracts/0.4.24/Lido.sol#L670-L705
    function canDeposit(uint256 amount) public view override returns (bool) {
        if (amount == 0) return false;

        (
            bool isStakingPaused,
            bool isStakingLimitSet,
            uint256 currentStakeLimit,
            uint256 maxStakeLimit,
            uint256 maxStakeLimitGrowthBlocks,
            uint256 prevStakeLimit,
            uint256 prevStakeBlockNumber
        ) = stETH().getStakeLimitFullInfo();

        maxStakeLimit;
        maxStakeLimitGrowthBlocks;
        prevStakeLimit;
        prevStakeBlockNumber;

        if (isStakingPaused) return false;

        if (isStakingLimitSet) {
            if (amount > currentStakeLimit) return false;
        }

        return true;
    }

    /// @dev deposit ETH to receive sfrxETH.
    function _deposit() internal override returns (uint256) {
        // ETH -> stETH
        uint256 shares = stETH().submit{ value: msg.value }(address(0));
        stETH().approve(address(wstETH()), shares);

        // stETH -> wstETH
        uint256 wstETHAmount = wstETH().wrap(shares);
        return wstETHAmount;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Withdraw
    ////////////////////////////////////////////////////////////////////////////////////////////

    function canWithdraw() public pure override returns (bool) {
        return false;
    }

    function _withdraw(uint256) internal pure override returns (uint256) {
        // direct converting stETH to ETH in lido system is not supported.
        // instead, use Curve's stETH-ETH pool
        return 0;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // MISC
    ////////////////////////////////////////////////////////////////////////////////////////////

    /// @dev returns APR since Lido staking launch
    function getAPR() public view override returns (uint256) {
        uint256 stEthPerToken = wstETH().stEthPerToken();

        uint256 feeBPS = stETH().getFee();

        if (stEthPerToken == 0) return 0;
        uint256 span = block.timestamp - _serviceStartedAt;

        // NOTE: this returns 4.5%, but lido frontend shows 4.9%...
        return
            // accumulated reward ratio (in wei)
            ((((stEthPerToken - 1 ether) * (365.25 days)) / span) * (10000 - feeBPS)) /
            // fee deduction (in bps)
            10000;
    }
}
