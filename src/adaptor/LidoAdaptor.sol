// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import { BaseAdaptor } from './BaseAdaptor.sol';
import { ILido as ST_ETH } from '../lib/ILido.sol';
import { IWstETH as WST_ETH } from '../lib/IWstETH.sol';
import { CurveSwap } from '../lib/curve/CurveSwap.sol';

// deposit: ETH -> wstETH
//
contract LidoAdaptor is BaseAdaptor, CurveSwap {
    uint256 private constant _serviceStartedAt = 1608242396; // stETH contract created at 1608242396 (block number = 11473216)
    uint256 private immutable _adaptorDeployed = block.timestamp;

    receive() external payable override(BaseAdaptor, CurveSwap) {}

    /// @dev return a name of adaptor
    function adaptorName() public pure override returns (string memory) {
        return 'lido';
    }

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    function getTokens() public view override returns (address token0, address token1) {
        token0 = address(0);
        token1 = address(wstETH());
    }

    function getETHAmount(uint256 tokenAmount) public view override returns (uint256) {
        return wstETH().getStETHByWstETH(tokenAmount);
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

        // stETH -> wstETH
        stETH().approve(address(wstETH()), shares);
        uint256 wstETHAmount = wstETH().wrap(shares);
        return wstETHAmount;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Withdraw
    ////////////////////////////////////////////////////////////////////////////////////////////

    function canWithdraw(uint256 amount) public pure override returns (bool) {
        return false;
    }

    // direct converting stETH to ETH in lido system is not supported yet.
    // instead, use Curve's stETH-ETH pool
    function _withdraw(uint256) internal pure override returns (uint256) {
        revert('NOT_IMPLEMENTD');
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // BUY-SELL
    ////////////////////////////////////////////////////////////////////////////////////////////

    // swap ETH for wstETH
    //  1. buy stETH with ETH from Curve
    //  2. wrap stETH to wstETH
    function _buyToken() internal override returns (uint256) {
        uint256 stETHAmount = Curve_swap(
            address(0), // ETH
            msg.value,
            Curve_stETH_ETH_POOL_ADDRESS(),
            Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH(),
            Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH()
        );

        stETH().approve(address(wstETH()), stETHAmount);
        uint256 wstETHAmount = wstETH().wrap(stETHAmount);
        return wstETHAmount;
    }

    // swap wstETH for ETH
    //  1. unwrap wstETH to stETH
    //  2. buy ETH with stETH from Curve
    function _sellToken(uint256 wstETHAmount) internal override returns (uint256) {
        uint256 stETHAmount = wstETH().unwrap(wstETHAmount);

        uint256 ETHAmount = Curve_swap(
            address(stETH()), // stETH
            stETHAmount,
            Curve_stETH_ETH_POOL_ADDRESS(),
            Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH(),
            Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH()
        );

        return ETHAmount;
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
