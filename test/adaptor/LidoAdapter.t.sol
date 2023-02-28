// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import 'forge-std/Test.sol';
import '../../src/adaptor/LidoAdapter.sol';
import { IERC20 } from '../../lib/forge-std/src/interfaces/IERC20.sol';

// https://github.com/foundry-rs/forge-std/blob/master/src/Vm.sol

contract LidoAdaptorTest is Test {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 goerliFork;

    string MAINNET_RPC_URL = vm.envString('MAINNET_RPC_URL');
    string GOERLI_RPC_URL = vm.envString('GOERLI_RPC_URL');

    LidoAdapter public adapter;

    function setUp() public {
        console.log('MAINNET_RPC_URL: %s', MAINNET_RPC_URL);
        console.log('GOERLI_RPC_URL: %s', GOERLI_RPC_URL);

        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        goerliFork = vm.createFork(GOERLI_RPC_URL);

        //  deploy test contract to mainnet-fork
        vm.selectFork(mainnetFork);
        adapter = new LidoAdapter();
        vm.makePersistent(address(adapter));
    }

    function testCanDeposit() public {
        vm.selectFork(mainnetFork);
        require(adapter.canDeposit(1 ether) == true, 'cannot deposit');
    }

    function testStETHTotalSupply() public {
        {
            // mainnet-fork
            vm.selectFork(mainnetFork);

            require(adapter.stETH().totalSupply() > 0, 'invalid total supply of stETH');
        }

        // {
        //     // goerli-fork
        //     vm.selectFork(goerliFork);
        //     IERC20 stETH = fraxAdapter.stETH();
        //     require(stETH.totalSupply() > 0, "invalid total supply of stETH");
        // }
    }

    function testDeposit32ETH() public {
        uint256 amount = 32 ether;

        {
            // mainnet-fork
            vm.selectFork(mainnetFork);
            _testDeposit(amount);
        }

        // {
        //     // goerli-fork
        //     vm.selectFork(goerliFork);
        //     _testDeposit(amount);
        // }
    }

    function testDeposit1ETH() public {
        uint256 amount = 1 ether;

        {
            // mainnet-fork
            vm.selectFork(mainnetFork);
            _testDeposit(amount);
        }

        // {
        //     // goerli-fork
        //     vm.selectFork(goerliFork);
        //     _testDeposit(amount);
        // }
    }

    function testDepositFuzz(uint96 amount) public {
        vm.assume(amount > 0.00001 ether && amount < 100 ether);

        vm.selectFork(mainnetFork);
        _testDeposit(amount);
    }

    function _testDeposit(uint256 amount) internal {
        amount = adapter.deposit{ value: amount }();
        require(amount > 0, 'zero-amount');

        require(adapter.wstETH().balanceOf(address(this)) == amount, 'deposit misiatch');
    }

    function testAPR() public {
        vm.selectFork(mainnetFork);
        console.log('adapter.getAPR(): %s', adapter.getAPR());
        require(adapter.getAPR() > 0, 'invalid APR');
    }
}
