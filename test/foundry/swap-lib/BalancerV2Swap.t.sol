// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import 'forge-std/Test.sol';
import { BalancerV2VaultInterface } from '../../../src/lib/balancer-v2/interfaces/BalancerV2VaultInterface.sol';
import { BalancerV2Swap } from '../../../src/lib/balancer-v2/BalancerV2Swap.sol';
import { Constants } from '../../../src/lib/Constants.sol';
import { IERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

contract BalancerV2SwapTest is Constants, Test {
    // the identifiers of the forks
    uint256 mainnetFork;

    string MAINNET_RPC_URL = vm.envString('MAINNET_RPC_URL');

    BalancerV2Swap public target;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        //  deploy test contract to mainnet-fork
        vm.selectFork(mainnetFork);
        target = new BalancerV2Swap();
        vm.makePersistent(address(target));
    }

    function testSwap_ETH_for_wstETH(uint96 amount) public {
        vm.assume(amount > 0.00001 ether && amount < 100 ether);

        // ETH -> wstETH
        uint256 wstAmount = target.BalancerV2_swap{ value: amount }(
            address(0),
            address(wstETH()),
            uint256(amount),
            BalancerV2_wstETH_WETH_POOL_ID()
        );

        console.log('wstETH().balanceOf(address(target)): %s', wstETH().balanceOf(address(target)));
        console.log('wstAmount: %s', wstAmount);

        require(wstETH().balanceOf(address(target)) == wstAmount, 'wstETH amount mismatch');

        // wstETH -> ETH
        uint256 ethAmount = target.BalancerV2_swap(address(wstETH()), address(0), uint256(wstAmount), BalancerV2_wstETH_WETH_POOL_ID());

        require(address(target).balance == ethAmount, 'ETH amount mismatch');
    }
}
