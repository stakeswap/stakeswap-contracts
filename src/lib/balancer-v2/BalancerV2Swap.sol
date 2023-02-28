// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';

import { SafeERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import { IERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { BalancerV2VaultInterface } from './interfaces/BalancerV2VaultInterface.sol';
import { BalancerV2MetaStablePoolInterface } from './interfaces/BalancerV2MetaStablePoolInterface.sol';
import { Constants } from '../Constants.sol';

// balancer-v2 swap helper
// TODO: rename BalancerV2Lib after adding liquidity functions
contract BalancerV2Swap is Constants {
    // receive ETH
    receive() external payable virtual {}

    /// @dev visibility is public for test purpose.
    function BalancerV2_swap(address fromToken, address toToken, uint256 fromTokenAmount, bytes32 poolId) public payable returns (uint256) {
        BalancerV2VaultInterface vault = BalancerV2Vault();

        BalancerV2VaultInterface.BatchSwapStep[] memory swaps = new BalancerV2VaultInterface.BatchSwapStep[](1);
        swaps[0] = BalancerV2VaultInterface.BatchSwapStep({
            poolId: poolId,
            assetInIndex: 0, // fromToken index
            assetOutIndex: 1, // toToken index
            amount: fromTokenAmount,
            userData: ''
        });

        address[] memory assets = new address[](2);
        assets[0] = fromToken;
        assets[1] = toToken;

        int256[] memory limits = new int256[](2);
        limits[0] = type(int256).max;
        limits[1] = type(int256).max;

        uint256 swapValue;
        if (fromToken == address(0)) swapValue = msg.value;
        else SafeERC20.safeApprove(IERC20(fromToken), address(vault), fromTokenAmount);

        int256[] memory res = vault.batchSwap{ value: swapValue }(
            BalancerV2VaultInterface.SwapKind.GIVEN_IN,
            swaps,
            assets,
            BalancerV2VaultInterface.FundManagement({
                sender: address(this), // use token0 held in `this` contract to swap
                fromInternalBalance: false, // send ERC20 token directly, not updating deposit balance of the pool
                recipient: payable(address(this)), // receive token1 to `this` contract during swap
                toInternalBalance: false // receive ERC20 token directly, not updating deposit balance of the pool
            }),
            limits,
            block.timestamp
        );

        return uint256(res[1] < 0 ? -res[1] : res[1]);
    }

    // TODO: add liquidity

    // TODO: remove liquidity
}
