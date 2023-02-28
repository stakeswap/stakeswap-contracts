// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import 'forge-std/Test.sol';
import '../../src/adaptor/RocketPoolAdapter.sol';
import { IERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

// https://github.com/foundry-rs/forge-std/blob/master/src/Vm.sol

contract RocketPoolAdapterTest is Test {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 goerliFork;

    string MAINNET_RPC_URL = vm.envString('MAINNET_RPC_URL');
    string GOERLI_RPC_URL = vm.envString('GOERLI_RPC_URL');

    RocketPoolAdapter public adapter;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        goerliFork = vm.createFork(GOERLI_RPC_URL);

        //  deploy test contract to mainnet-fork
        vm.selectFork(mainnetFork);
        adapter = new RocketPoolAdapter();
        vm.makePersistent(address(adapter));
    }

    function testCanDeposit() public {
        vm.selectFork(mainnetFork);
        require(adapter.canDeposit(1 ether) == true, 'cannot deposit');
    }

    function testMaxAmount() public {
        // mainnet-fork
        vm.selectFork(mainnetFork);
        uint256 minDeposit = adapter.getRocketDAOProtocolSettingsDeposit().getMinimumDeposit();
        uint256 maximumDepositPoolSize = adapter.getRocketDAOProtocolSettingsDeposit().getMaximumDepositPoolSize();

        console.log('minDeposit:              %s', minDeposit);
        console.log('maximumDepositPoolSize:  %s', maximumDepositPoolSize);
    }

    function testRETHTotalSupply() public {
        {
            // mainnet-fork
            vm.selectFork(mainnetFork);

            require(adapter.rETH().totalSupply() > 0, 'invalid total supply of rETH');
        }

        // {
        //     // goerli-fork
        //     vm.selectFork(goerliFork);
        //     IERC20 rETH = fraxAdapter.rETH();
        //     require(rETH.totalSupply() > 0, "invalid total supply of rETH");
        // }
    }

    // NOTE: deposit not working...
    // function testDeposit32ETH() public {
    //     uint256 amount = 32 ether;

    //     {
    //         // mainnet-fork
    //         vm.selectFork(mainnetFork);
    //         _testDeposit(amount);
    //     }

    // NOTE: deposit not working...
    //     // {
    //     //     // goerli-fork
    //     //     vm.selectFork(goerliFork);
    //     //     _testDeposit(amount);
    //     // }
    // }

    // NOTE: deposit not working...
    // function testDeposit1ETH() public {
    //     uint256 amount = 1 ether;

    //     {
    //         // mainnet-fork
    //         vm.selectFork(mainnetFork);
    //         _testDeposit(amount);
    //     }

    //     // {
    //     //     // goerli-fork
    //     //     vm.selectFork(goerliFork);
    //     //     _testDeposit(amount);
    //     // }
    // }

    // function testDepositFuzz(uint96 amount) public {
    //     vm.assume(amount > 0.00001 ether && amount < 100 ether);

    //     vm.selectFork(mainnetFork);
    //     _testDeposit(amount);
    // }

    function _testDeposit(uint256 amount) internal {
        amount = adapter.deposit{ value: amount }();
        require(amount > 0, 'zero-amount');

        require(adapter.rETH().balanceOf(address(this)) == amount, 'deposit misiatch');
    }

    function testAPR() public {
        vm.selectFork(mainnetFork);
        console.log('adapter.getAPR(): %s', adapter.getAPR());
        require(adapter.getAPR() > 0, 'invalid APR');
    }

    function testBuyAndSell(uint96 _amount) public {
        vm.assume(_amount > 0.00001 ether && _amount < 100 ether);
        vm.selectFork(mainnetFork);

        uint256 amount = _amount;
        uint256 rETHAmount; // amount of rETH when buy with ETH
        uint256 ethAmount; // amount of ETH when sell with rETH

        // 1. buy rETH
        {
            rETHAmount = adapter.buyToken{ value: amount }();

            console.log('amount          : %s', amount);
            console.log('rETHAmount      : %s', rETHAmount);
            console.log('diff            : %s', amount - rETHAmount);
            console.log('diff (bps)      : %s', ((amount - rETHAmount) * 10000) / amount);

            require(rETHAmount > 0, 'failed to buy');
        }

        // 1. sell rETH
        {
            adapter.rETH().approve(address(adapter), rETHAmount);
            ethAmount = adapter.sellToken(rETHAmount);

            console.log('rETHAmount      : %s', rETHAmount);
            console.log('ethAmount       : %s', ethAmount);
            console.log('diff            : %s', ethAmount - rETHAmount);
            console.log('diff (bps)      : %s', ((ethAmount - rETHAmount) * 10000) / ethAmount);

            require(rETHAmount > 0, 'failed to buy');
        }
    }
}
