// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import 'forge-std/Test.sol';
import '../../../src/adaptor/FraxAdaptor.sol';
import { IERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { Constants } from '../../../src/lib/Constants.sol';
import { MinorError } from '../lib/MinorError.sol';

// https://github.com/foundry-rs/forge-std/blob/master/src/Vm.sol

contract FraxAdaptorTest is Test, Constants, MinorError {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 goerliFork;

    string MAINNET_RPC_URL = vm.envString('MAINNET_RPC_URL');
    string GOERLI_RPC_URL = vm.envString('GOERLI_RPC_URL');

    FraxAdaptor public adaptor;

    receive() external payable {}

    function setUp() public {
        console.log('MAINNET_RPC_URL: %s', MAINNET_RPC_URL);
        console.log('GOERLI_RPC_URL: %s', GOERLI_RPC_URL);

        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        goerliFork = vm.createFork(GOERLI_RPC_URL);

        //  deploy test contract to mainnet-fork
        vm.selectFork(mainnetFork);
        adaptor = new FraxAdaptor();
        vm.makePersistent(address(adaptor));
    }

    function testCanDeposit() public {
        vm.selectFork(mainnetFork);
        require(adaptor.canDeposit(1 ether) == true, 'cannot deposit');
    }

    function testFrxETHTotalSupply() public {
        {
            // mainnet-fork
            vm.selectFork(mainnetFork);
            IERC20 frxETH = adaptor.frxETH();
            require(frxETH.totalSupply() > 0, 'invalid total supply of frxETH');
        }

        // {
        //     // goerli-fork
        //     vm.selectFork(goerliFork);
        //     IERC20 frxETH = adaptor.frxETH();
        //     require(frxETH.totalSupply() > 0, "invalid total supply of frxETH");
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
        amount = adaptor.deposit{ value: amount }();
        require(amount > 0, 'zero-amount');

        require(adaptor.sfrxETH().balanceOf(address(this)) == amount, 'deposit misiatch');
    }

    function testBuySellFuzz(uint96 amount) public {
        vm.assume(amount > 0.00001 ether && amount < 100 ether);
        vm.selectFork(mainnetFork);

        // buy
        uint256 sfrxETHAmount = adaptor.buyToken{ value: amount }();
        require(sfrxETHAmount == sfrxETH().balanceOf(address(this)), 'sfrxETH buy amount mismatch');

        // check getETHAmount -- error less than 0.5%
        require(withinError(amount, adaptor.getETHAmount(sfrxETHAmount), (amount * 5) / 1000), 'getETHAmount diff too big');

        // sell
        uint256 beforeETHBalance = address(this).balance;
        sfrxETH().approve(address(adaptor), sfrxETHAmount);
        uint256 ETHAmount = adaptor.sellToken(sfrxETHAmount);
        uint256 afterETHBalance = address(this).balance;

        require(afterETHBalance - beforeETHBalance == ETHAmount, 'sfrxETH sell amount mismatch');
        require(withinError(amount, ETHAmount, (amount * 1) / 100), 'price impact too big');
    }

    function testAPR() public {
        vm.selectFork(mainnetFork);
        console.log('adaptor.getAPR(): %s', adaptor.getAPR());
        require(adaptor.getAPR() > 0, 'invalid APR');
    }
}
