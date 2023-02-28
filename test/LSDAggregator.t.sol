// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import 'forge-std/Test.sol';
import { BaseAdaptor } from '../src/adaptor/BaseAdaptor.sol';
import { LSDAggregator } from '../src/LSDAggregator.sol';
import { Constants } from '../src/lib/Constants.sol';
import { IERC20 } from '../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { MinorError } from './lib/MinorError.sol';

import { FraxAdaptor } from '../src/adaptor/FraxAdaptor.sol';
import { LidoAdaptor } from '../src/adaptor/LidoAdaptor.sol';
import { RocketPoolAdaptor } from '../src/adaptor/RocketPoolAdaptor.sol';

contract LSDAggregatorTest is Constants, Test, MinorError {
    // the identifiers of the forks
    uint256 mainnetFork;

    string MAINNET_RPC_URL = vm.envString('MAINNET_RPC_URL');

    LSDAggregator public target;
    BaseAdaptor[] public adaptors;

    uint256[] public weights;

    address user0 = address(102412);
    address user1 = address(102413);

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        //  deploy test contract to mainnet-fork
        vm.selectFork(mainnetFork);

        adaptors.push(new LidoAdaptor());
        adaptors.push(new RocketPoolAdaptor());
        adaptors.push(new FraxAdaptor());

        weights.push(3_000);
        weights.push(2_000);
        weights.push(5_000);

        vm.deal(user0, 10000 ether);
        vm.deal(user1, 10000 ether);

        target = new LSDAggregator(adaptors, weights);
        vm.makePersistent(address(target));

        vm.deal(user0, 10000 ether);
        vm.deal(user1, 10000 ether);
    }

    function testDeposit() public {
        uint96 amount = 1 ether;
        // vm.assume(amount > 0.00001 ether && amount < 100 ether);

        // user0 and user1 deposits
        vm.prank(user0);
        target.depositWithETH{ value: amount }(user0);

        vm.prank(user1);
        target.depositWithETH{ value: amount }(user1);

        console.log('eth balance of user0', user0.balance);
        console.log('eth balance of user1', user1.balance);

        require(target.balanceOf(user0) > 0, 'invalid shares of user0');
        require(target.balanceOf(user1) > 0, 'invalid shares of user1');
        require(target.balanceOf(user0) == target.balanceOf(user1), 'shares mismatch');

        require(address(target).balance < 10, 'unused eth');
        require(WETH().balanceOf(address(target)) < 10, 'unused eth');

        // user0 try to withdraw

        // user1 try to withdraw

        console.log('eth balance of user0', user0.balance);
        console.log('eth balance of user1', user1.balance);
    }
}
