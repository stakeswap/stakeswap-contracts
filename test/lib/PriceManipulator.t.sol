// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import { Vm } from 'forge-std/Vm.sol';

import { Constants } from '../../src/lib/Constants.sol';
import { PriceManipulator } from './PriceManipulator.sol';
import { MinorError } from './MinorError.sol';

contract PriceManipulatorTest is Constants, Test, MinorError {
    // the identifiers of the forks
    uint256 mainnetFork;

    string MAINNET_RPC_URL = vm.envString('MAINNET_RPC_URL');

    PriceManipulator pm;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
        pm = new PriceManipulator();
        vm.makePersistent(address(pm));
        vm.deal(address(this), 10000 ether);
    }

    function testMintWstETH() public {
        require(wstETH().balanceOf(address(this)) == 0, 'H');

        uint256 value = 1 ether;
        pm.LIDO_mintWstETH(address(this), value);

        require(wstETH().balanceOf(address(this)) == value, 'failed');
    }

    function testWstETHPriceManipulation() public {
        uint256 price0 = 1e36 / pm.la().buyToken{ value: 1 ether }();

        pm.increaseWstETHprice_2p();
        uint256 price1 = 1e36 / pm.la().buyToken{ value: 1 ether }();

        pm.decreaseWstETHprice_2p();
        uint256 price2 = 1e36 / pm.la().buyToken{ value: 1 ether }();

        console.log('price0: %s', price0);
        console.log('price1: %s', price1);
        console.log('price2: %s', price2);

        console.log('increase price change in BPS: %s', ((price1 - price0) * 10000) / price0);
        console.log('decrease price change in BPS: %s', ((price1 - price2) * 10000) / price1);

        require(price0 < price1, 'failed to increase');
        require(price2 < price1, 'failed to decrease');

        require(withinError((price0 * 102) / 100, price1, (price0 * 5) / 1000), 'price not increased about 2%');
        require(withinError(price0, price2, (price0 * 10) / 1000), 'price0 and price2 differs more than 1%');
    }

    function testRETHPriceManipulation() public {
        uint256 price0 = 1e36 / pm.ra().buyToken{ value: 1 ether }();

        pm.increaseRETHprice_2p();
        uint256 price1 = 1e36 / pm.ra().buyToken{ value: 1 ether }();

        pm.decreaseRETHprice_2p();
        uint256 price2 = 1e36 / pm.ra().buyToken{ value: 1 ether }();

        console.log('price0: %s', price0);
        console.log('price1: %s', price1);
        console.log('price2: %s', price2);

        console.log('increase price change in BPS: %s', ((price1 - price0) * 10000) / price0);
        console.log('decrease price change in BPS: %s', ((price1 - price2) * 10000) / price1);

        require(price0 < price1, 'failed to increase');
        require(price2 < price1, 'failed to decrease');

        require(withinError((price0 * 102) / 100, price1, (price0 * 5) / 1000), 'price not increased about 2%');
        require(withinError(price0, price2, (price0 * 10) / 1000), 'price0 and price2 differs more than 1%');
    }

    function testSfrxETHPriceManipulation() public {
        uint256 price0 = 1e36 / pm.fa().buyToken{ value: 1 ether }();

        pm.increaseSfrxETHprice_2p();
        uint256 price1 = 1e36 / pm.fa().buyToken{ value: 1 ether }();

        pm.decreaseSfrxETHprice_2p();
        uint256 price2 = 1e36 / pm.fa().buyToken{ value: 1 ether }();

        console.log('price0: %s', price0);
        console.log('price1: %s', price1);
        console.log('price2: %s', price2);

        console.log('increase price change in BPS: %s', ((price1 - price0) * 10000) / price0);
        console.log('decrease price change in BPS: %s', ((price1 - price2) * 10000) / price1);

        require(price0 < price1, 'failed to increase');
        require(price2 < price1, 'failed to decrease');

        require(withinError((price0 * 102) / 100, price1, (price0 * 5) / 1000), 'price not increased about 2%');
        require(withinError(price0, price2, (price0 * 10) / 1000), 'price0 and price2 differs more than 1%');
    }
}
