// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import 'forge-std/Test.sol';
import { CurveSwap } from '../../../src/lib/curve/CurveSwap.sol';
import { Constants } from '../../../src/lib/Constants.sol';
import { IERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { MinorError } from '../lib/MinorError.sol';

contract CurveSwapTest is Constants, Test, MinorError {
    // the identifiers of the forks
    uint256 mainnetFork;

    string MAINNET_RPC_URL = vm.envString('MAINNET_RPC_URL');

    CurveSwap public target;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        //  deploy test contract to mainnet-fork
        vm.selectFork(mainnetFork);
        target = new CurveSwap();
        vm.makePersistent(address(target));
    }

    function testSwap_ETH_for_stETH(uint96 amount) public {
        vm.assume(amount > 0.00001 ether && amount < 100 ether);

        // ETH -> stETH
        uint256 stAmount = target.Curve_swap{ value: amount }(
            address(0),
            uint256(amount),
            Curve_stETH_ETH_POOL_ADDRESS(),
            Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH(),
            Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH()
        );

        console.log('wstETH().balanceOf(address(target)): %s', stETH().balanceOf(address(target)));
        console.log('wstAmount:                           %s', stAmount);

        // there could be amount error within 10 wei.
        require(withinMinorError(stETH().balanceOf(address(target)), stAmount), 'stETH amount mismatch');

        // stETH -> ETH
        uint256 ethAmount = target.Curve_swap(
            address(stETH()),
            uint256(stAmount),
            Curve_stETH_ETH_POOL_ADDRESS(),
            Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH(),
            Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH()
        );

        require(address(target).balance == ethAmount, 'ETH amount mismatch');
    }
}
