// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import { BaseAdapter } from './BaseAdapter.sol';
import { frxETHMinter as FrxETHMinter } from '../../lib/frxETH-public/src/frxETHMinter.sol';
import { IERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { sfrxETH as SFRX_ETH } from '../../lib/frxETH-public/src/sfrxETH.sol';
import { xERC4626 } from '../../lib/frxETH-public/lib/ERC4626/src/xERC4626.sol';

// ETH -> frxETH -- deposit (for validator node)
// frxETH -> sfrxETH -- deposit (for sfrxETH compounding)
// sfrxETH -> frxETH -- redeem (for liquidation)

contract FraxAdapter is BaseAdapter {
    uint256 private constant _serviceStartedAt = 1665022895; // sfrxETH contract created at 1665022895 (block number = 15686046)
    uint256 private immutable _adaptorDeployed = block.timestamp;

    /// @dev return a name of adaptor
    function adaptorName() public pure override returns (string memory) {
        return 'frax';
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Getter - tokens
    ////////////////////////////////////////////////////////////////////////////////////////////

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    function getTokens() public view override returns (address token0, address token1, address token2) {
        token0 = address(sfrxETH());
        token1 = address(frxETH());
        token2 = address(0);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Deposit
    ////////////////////////////////////////////////////////////////////////////////////////////

    // https://github.com/FraxFinance/frxETH-public/blob/master/src/frxETHMinter.sol#L67-L82
    function canDeposit(uint256 amount) public view override returns (bool) {
        if (amount == 0) return false;
        FrxETHMinter fme = frxETHMinter();
        if (fme.submitPaused()) return false;

        return true;
    }

    function _deposit() internal override returns (uint256) {
        // ETH -> sfrxETH
        uint256 sfrxAmount = frxETHMinter().submitAndDeposit{ value: msg.value }(address(this));
        return sfrxAmount;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Withdraw
    ////////////////////////////////////////////////////////////////////////////////////////////

    function canWithdraw() public pure override returns (bool) {
        return false;
    }

    function _withdraw(uint256) internal pure override returns (uint256) {
        // direct converting (s)frxETH to ETH in frax system is not supported.
        // instead, use Curve's frxETH-ETH pool
        return 0;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // BUY-SELL
    ////////////////////////////////////////////////////////////////////////////////////////////
    function _buyToken() internal override returns (uint256) {
        revert('NOT_IMPLEMENTD');
    }

    function _sellToken(uint256 amount) internal override returns (uint256) {
        revert('NOT_IMPLEMENTD');
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // MISC
    ////////////////////////////////////////////////////////////////////////////////////////////

    /// @dev returns APR for a last cycle
    function getAPR() public view override returns (uint256) {
        SFRX_ETH _sfrxETH = sfrxETH();
        uint256 totalSupply = _sfrxETH.totalSupply();

        // return zero in case of no deposit
        if (totalSupply == 0) return 0;

        // return APR according to collected rewards during last cycle
        return (((_sfrxETH.lastRewardAmount() * (365.25 days)) / _sfrxETH.rewardsCycleLength()) * 1e18) / totalSupply;
    }
}
