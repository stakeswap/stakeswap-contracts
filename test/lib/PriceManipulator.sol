// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import { Vm } from 'forge-std/Vm.sol';
import { LidoAdaptor } from '../../src/adaptor/LidoAdaptor.sol';
import { FraxAdaptor } from '../../src/adaptor/FraxAdaptor.sol';
import { RocketPoolAdaptor } from '../../src/adaptor/RocketPoolAdaptor.sol';
import { Constants } from '../../src/lib/Constants.sol';

// As of now, liquidating LSDs are only possible via DEX. So we buy LSD to increase price and
// sell LSD to decrease price.
contract PriceManipulator is Constants, Test {
    using stdStorage for StdStorage;

    LidoAdaptor public la;
    FraxAdaptor public fa;
    RocketPoolAdaptor public ra;

    receive() external payable {}

    constructor() {
        la = new LidoAdaptor();
        fa = new FraxAdaptor();
        ra = new RocketPoolAdaptor();
    }

    function LIDO_mintWstETH(address target, uint256 value) external {
        deal(address(wstETH()), target, value);
    }

    // NOTE: amount are depends on the bonding curve and liquidity of a pool

    function increaseWstETHprice_2p() external {
        uint256 ethAmount = 140000 ether;
        deal(address(this), ethAmount);
        la.buyToken{ value: ethAmount }();
    }

    function decreaseWstETHprice_2p() external {
        uint256 ethAmount = 140000 ether;
        uint256 tokenAmount = la.getETHAmount(ethAmount);
        deal(address(wstETH()), address(this), tokenAmount);
        wstETH().approve(address(la), type(uint256).max);

        la.sellToken(tokenAmount);
    }

    function increaseRETHprice_2p() external {
        uint256 ethAmount = 6130 ether;
        deal(address(this), ethAmount);
        ra.buyToken{ value: ethAmount }();
    }

    function decreaseRETHprice_2p() external {
        uint256 ethAmount = 6130 ether;
        uint256 tokenAmount = ra.getTokenAmount(ethAmount);
        deal(address(rETH()), address(this), tokenAmount);
        rETH().approve(address(ra), type(uint256).max);

        ra.sellToken(tokenAmount);
    }

    function increaseSfrxETHprice_2p() external {
        uint256 ethAmount = 23000 ether;
        deal(address(this), ethAmount);
        fa.buyToken{ value: ethAmount }();
    }

    function decreaseSfrxETHprice_2p() external {
        uint256 ethAmount = 23000 ether;
        uint256 tokenAmount = ra.getTokenAmount(ethAmount);
        deal(address(sfrxETH()), address(this), tokenAmount);
        sfrxETH().approve(address(fa), type(uint256).max);

        fa.sellToken(tokenAmount);
    }
}
