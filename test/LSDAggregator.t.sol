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

    LidoAdaptor lidoAdaptor;
    RocketPoolAdaptor rocketPoolAdaptor;
    FraxAdaptor fraxAdaptor;

    uint256[] public depositWeights;
    uint256[] public buyWeights;

    address user0 = address(102412);
    address user1 = address(102413);

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        //  deploy test contract to mainnet-fork
        vm.selectFork(mainnetFork);

        adaptors.push(lidoAdaptor = new LidoAdaptor());
        adaptors.push(rocketPoolAdaptor = new RocketPoolAdaptor());
        adaptors.push(fraxAdaptor = new FraxAdaptor());

        // deposit is quite much
        depositWeights.push(500);
        depositWeights.push(250); // rocket pool doesn't support deposit so buyWeight will increase
        depositWeights.push(250);

        buyWeights.push(3_000);
        buyWeights.push(2_000);
        buyWeights.push(4_000);

        vm.deal(user0, 10000 ether);
        vm.deal(user1, 10000 ether);

        target = new LSDAggregator(adaptors, depositWeights, buyWeights);
        vm.makePersistent(address(target));
    }

    // test simple deposit and withdraw without staking reward
    function testDirectDepositAndWithdraw() public {
        uint96 amount = 1 ether;
        // vm.assume(amount > 0.00001 ether && amount < 100 ether);

        // 1. user0 and user1 deposits
        vm.startPrank(user0, user0);
        target.deposit{ value: amount }();
        vm.stopPrank();

        vm.startPrank(user1, user1);
        target.deposit{ value: amount }();
        vm.stopPrank();

        console.log('user0        ', user0);
        console.log('user1        ', user1);
        console.log('target       ', address(target));
        console.log('test runner  ', address(this));

        console.log('eth balance of user0', user0.balance);
        console.log('eth balance of user1', user1.balance);
        console.log('vault share of user0', target.balanceOf(user0));
        console.log('vault share of user1', target.balanceOf(user1));
        console.log('vault share of user0 in ETH', target.previewRedeem(target.balanceOf(user0)));
        console.log('vault share of user1 in ETH', target.previewRedeem(target.balanceOf(user1)));

        uint256 shares0 = target.balanceOf(user0);

        console.log('[user0] stETH  ~', (lidoAdaptor.getETHAmount(shares0) * 3_000) / 10_000);
        console.log('[user0] rETH   ~', (rocketPoolAdaptor.getETHAmount(shares0) * 2_000) / 10_000);
        console.log('[user0] frxETH ~', (fraxAdaptor.getETHAmount(shares0) * 5_000) / 10_000);

        require(target.balanceOf(user0) > 0, 'invalid shares of user0');
        require(target.balanceOf(user1) > 0, 'invalid shares of user1');
        // NOTE: shares could be different if buy tokens from dex
        // require(target.balanceOf(user0) == target.balanceOf(user1), 'shares mismatch');

        require(address(target).balance < 10, 'unused ETH');
        require(WETH().balanceOf(address(target)) < 10, 'unused WETH');

        require(wstETH().balanceOf(address(target)) > 0, 'wstETH == 0');
        require(rETH().balanceOf(address(target)) > 0, 'rETH == 0');
        require(sfrxETH().balanceOf(address(target)) > 0, 'sfrxETH == 0');

        // 2.1 user0 try to withdraw all shares
        uint256 user0BeforeETHBalance = address(user0).balance;
        vm.startPrank(user0, user0); // vm.prank doesn't work here...
        uint256 user0WithdrawalAmount = target.redeem(target.balanceOf(user0));
        vm.stopPrank();
        uint256 user0AfterETHBalance = address(user0).balance;

        console.log('user0BeforeETHBalance           ', user0BeforeETHBalance);
        console.log('user0WithdrawalAmount           ', user0WithdrawalAmount);
        console.log('user0WithdrawalAmount (error)   ', amount - user0WithdrawalAmount);
        console.log('user0AfterETHBalance            ', user0AfterETHBalance);

        require(user0WithdrawalAmount == user0AfterETHBalance - user0BeforeETHBalance, 'redeem error');

        // 2.2 user1 try to withdraw
        uint256 user1BeforeETHBalance = address(user1).balance;
        vm.startPrank(user1, user1); // vm.prank doesn't work here...
        uint256 user1WithdrawalAmount = target.redeem(target.balanceOf(user1));
        vm.stopPrank();
        uint256 user1AfterETHBalance = address(user1).balance;

        console.log('user1BeforeETHBalance           ', user1BeforeETHBalance);
        console.log('user1WithdrawalAmount           ', user1WithdrawalAmount);
        console.log('user1WithdrawalAmount (error)   ', amount - user1WithdrawalAmount);
        console.log('user1AfterETHBalance            ', user1AfterETHBalance);

        require(user1WithdrawalAmount == user1AfterETHBalance - user1BeforeETHBalance, 'redeem error');

        require(wstETH().balanceOf(address(target)) == 0, 'wstETH != 0');
        require(rETH().balanceOf(address(target)) == 0, 'rETH != 0');
        require(sfrxETH().balanceOf(address(target)) == 0, 'sfrxETH != 0');
        require(target.totalSupply() == 0, 'total supply != 0');

        console.log('eth balance of user0', user0.balance);
        console.log('eth balance of user1', user1.balance);

        // allow 4% eth amount reduction...
        require(withinError(amount, user0WithdrawalAmount, (amount * 400) / 10_000), 'withdrawal amount error is too big');
        require(withinError(amount, user1WithdrawalAmount, (amount * 400) / 10_000), 'withdrawal amount error is too big');
    }
}
