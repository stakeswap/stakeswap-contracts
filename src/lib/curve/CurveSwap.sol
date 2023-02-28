// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';

import { SafeERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import { IERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { CurveStableSwapInterface } from './interfaces/CurveStableSwapInterface.sol';
import { Constants } from '../Constants.sol';

//  swap helper
// TODO: rename CurveLib after adding liquidity functions
contract CurveSwap is Constants {
    // receive ETH
    receive() external payable virtual {}

    /// @dev visibility is public for test purpose.
    function Curve_swap(
        address fromToken,
        uint256 fromTokenAmount,
        address pool,
        int128 fromTokenIndex,
        int128 toTokenIndex
    ) public payable returns (uint256) {
        uint256 swapValue;
        if (fromToken == address(0)) swapValue = msg.value;
        else SafeERC20.safeApprove(IERC20(fromToken), pool, fromTokenAmount);

        return CurveStableSwapInterface(pool).exchange{ value: swapValue }(fromTokenIndex, toTokenIndex, fromTokenAmount, 0);
    }

    // function Curve_quote(
    //     address fromToken,
    //     uint256 fromTokenAmount,
    //     address pool,
    //     int128 fromTokenIndex,
    //     int128 toTokenIndex
    // ) public view returns (uint256) {
    //     fromToken;
    //     return CurveStableSwapInterface(pool).get_dy(fromTokenIndex, toTokenIndex, fromTokenAmount);
    // }

    // TODO: add liquidity

    // TODO: remove liquidity
}
