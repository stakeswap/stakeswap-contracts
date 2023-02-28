// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import 'forge-std/Test.sol';
import '../../src/adaptor/RocketPoolAdaptor.sol';
import { IERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { Constants } from '../../src/lib/Constants.sol';
import { MinorError } from '../lib/MinorError.sol';

// https://github.com/foundry-rs/forge-std/blob/master/src/Vm.sol

contract RocketPoolAdaptorTest is Test, Constants, MinorError {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 goerliFork;

    string MAINNET_RPC_URL = vm.envString('MAINNET_RPC_URL');
    string GOERLI_RPC_URL = vm.envString('GOERLI_RPC_URL');

    RocketPoolAdaptor public adaptor;

    receive() external payable {}

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        goerliFork = vm.createFork(GOERLI_RPC_URL);

        //  deploy test contract to mainnet-fork
        vm.selectFork(mainnetFork);
        adaptor = new RocketPoolAdaptor();
        vm.makePersistent(address(adaptor));
    }

    function testCanDeposit() public {
        vm.selectFork(mainnetFork);
        require(adaptor.canDeposit(1 ether) == true, 'cannot deposit');
    }

    function testMaxAmount() public {
        // mainnet-fork
        vm.selectFork(mainnetFork);
        uint256 minDeposit = adaptor.getRocketDAOProtocolSettingsDeposit().getMinimumDeposit();
        uint256 maximumDepositPoolSize = adaptor.getRocketDAOProtocolSettingsDeposit().getMaximumDepositPoolSize();

        console.log('minDeposit:              %s', minDeposit);
        console.log('maximumDepositPoolSize:  %s', maximumDepositPoolSize);
    }

    function testRETHTotalSupply() public {
        {
            // mainnet-fork
            vm.selectFork(mainnetFork);

            require(adaptor.rETH().totalSupply() > 0, 'invalid total supply of rETH');
        }

        // {
        //     // goerli-fork
        //     vm.selectFork(goerliFork);
        //     IERC20 rETH = fraxAdaptor.rETH();
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
        amount = adaptor.deposit{ value: amount }();
        require(amount > 0, 'zero-amount');

        require(adaptor.rETH().balanceOf(address(this)) == amount, 'deposit misiatch');
    }

    function testAPR() public {
        vm.selectFork(mainnetFork);
        console.log('adaptor.getAPR(): %s', adaptor.getAPR());
        require(adaptor.getAPR() > 0, 'invalid APR');
    }

    function testBuySellFuzz(uint96 amount) public {
        vm.assume(amount > 0.00001 ether && amount < 100 ether);
        vm.selectFork(mainnetFork);

        // buy
        uint256 rETHAmount = adaptor.buyToken{ value: amount }();
        require(rETHAmount == rETH().balanceOf(address(this)), 'rETH buy amount mismatch');

        // sell
        uint256 beforeETHBalance = address(this).balance;
        rETH().approve(address(adaptor), rETHAmount);
        uint256 ETHAmount = adaptor.sellToken(rETHAmount);
        uint256 afterETHBalance = address(this).balance;

        require(afterETHBalance - beforeETHBalance == ETHAmount, 'rETH sell amount mismatch');
        require(withinError(amount, ETHAmount, (amount * 1) / 100), 'price impact too big');
    }
}
