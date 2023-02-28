// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import { BaseAdaptor } from './BaseAdaptor.sol';
import { frxETHMinter as FrxETHMinter } from '../../lib/frxETH-public/src/frxETHMinter.sol';
import { IERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { sfrxETH as SFRX_ETH } from '../../lib/frxETH-public/src/sfrxETH.sol';
import { xERC4626 } from '../../lib/frxETH-public/lib/ERC4626/src/xERC4626.sol';
import { CurveSwap } from '../lib/curve/CurveSwap.sol';

// ETH -> frxETH -- deposit (for validator node)
// frxETH -> sfrxETH -- deposit (for sfrxETH compounding)
// sfrxETH -> frxETH -- redeem (for liquidation)

contract FraxAdaptor is BaseAdaptor, CurveSwap {
    uint256 private constant _serviceStartedAt = 1665022895; // sfrxETH contract created at 1665022895 (block number = 15686046)
    uint256 private immutable _adaptorDeployed = block.timestamp;

    receive() external payable override(BaseAdaptor, CurveSwap) {}

    /// @dev return a name of adaptor
    function adaptorName() public pure override returns (string memory) {
        return 'frax';
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Getter - tokens
    ////////////////////////////////////////////////////////////////////////////////////////////

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    function getTokens() public view override returns (address token0, address token1) {
        token0 = address(0);
        token1 = address(sfrxETH());
    }

    function getETHAmount(uint256 tokenAmount) public view override returns (uint256) {
        return sfrxETH().previewRedeem(tokenAmount);
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
    // swap ETH for wstETH
    //  1. swap ETH for frxETH from Curve
    //  2. convert frxETH to sfrxETH
    function _buyToken() internal override returns (uint256) {
        uint256 frxETHAmount = Curve_swap(
            address(0), // ETH
            msg.value,
            Curve_frxETH_ETH_POOL_ADDRESS(),
            Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH(),
            Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH()
        );

        frxETH().approve(address(sfrxETH()), frxETHAmount);
        uint256 sfrxETHAmount = sfrxETH().deposit(frxETHAmount, address(this));
        return sfrxETHAmount;
    }

    // swap sfrxETH for ETH
    //  2. convert sfrxETH to frxETH
    //  2. swap sfrxETH for ETH from Curve
    function _sellToken(uint256 sfrxETHAmount) internal override returns (uint256) {
        uint256 frxETHAmount = sfrxETH().redeem(sfrxETHAmount, address(this), address(this));

        uint256 ETHAmount = Curve_swap(
            address(frxETH()), // frxETH
            frxETHAmount,
            Curve_frxETH_ETH_POOL_ADDRESS(),
            Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH(),
            Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH()
        );

        return ETHAmount;
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
