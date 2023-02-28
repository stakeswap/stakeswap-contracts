// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import { BaseAdapter } from './BaseAdapter.sol';
import { frxETHMinter as FrxETHMinter } from '../../lib/frxETH-public/src/frxETHMinter.sol';
import { IERC20 } from '../../lib/forge-std/src/interfaces/IERC20.sol';
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

    function frxETH() public view returns (IERC20) {
        if (block.chainid == 1) return IERC20(0x5E8422345238F34275888049021821E8E08CAa1f);
        if (block.chainid == 5) return IERC20(0x3E04888B1C07a9805861c19551f7ed53145BD8D4); // frx finance - dev
        revert('unknown chain id');
    }

    function sfrxETH() public view returns (SFRX_ETH) {
        if (block.chainid == 1) return SFRX_ETH(0xac3E018457B222d93114458476f3E3416Abbe38F);
        if (block.chainid == 5) return SFRX_ETH(0x3E04888B1C07a9805861c19551f7ed53145BD8D4); // TODO: find actual sfrxETH on goerli
        revert('unknown chain id');
    }

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    function getTokens() public view override returns (address token0, address token1, address token2) {
        token0 = address(sfrxETH());
        token1 = address(frxETH());
        token2 = address(0);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Getter - Frax Finance system
    ////////////////////////////////////////////////////////////////////////////////////////////

    function frxETHMinter() public view returns (FrxETHMinter) {
        if (block.chainid == 1) return FrxETHMinter(payable(0xbAFA44EFE7901E04E39Dad13167D089C559c1138));
        if (block.chainid == 5) return FrxETHMinter(payable(0x6421d1Ca6Cd35852362806a2Ded2A49b6fa8bEF5)); // frx finance - dev
        revert('unknown chain id');
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
