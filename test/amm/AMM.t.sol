// Modified factory contracrt based on UniswapV2Factory
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import 'forge-std/Test.sol';

import { IERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

import { BaseAdaptor } from '../../src/adaptor/BaseAdaptor.sol';
import { FraxAdaptor } from '../../src/adaptor/FraxAdaptor.sol';
import { LidoAdaptor } from '../../src/adaptor/LidoAdaptor.sol';
import { RocketPoolAdaptor } from '../../src/adaptor/RocketPoolAdaptor.sol';
import { LSDAggregator } from '../../src/LSDAggregator.sol';

import { Factory } from '../../src/amm/Factory.sol';
import { Pair } from '../../src/amm/Pair.sol';
import { Router } from '../../src/amm/Router.sol';

import { Constants } from '../../src/lib/Constants.sol';
import { MinorError } from '../lib/MinorError.sol';

contract AMMTest is Constants, Test, MinorError {
    // network
    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString('MAINNET_RPC_URL');

    // users
    address user0 = address(102412);
    address user1 = address(102413);

    // LSD Aggregator
    BaseAdaptor[] public adaptors;
    LidoAdaptor lidoAdaptor;
    RocketPoolAdaptor rocketPoolAdaptor;
    FraxAdaptor fraxAdaptor;

    LSDAggregator public aggregator;
    uint256[] public depositWeights;
    uint256[] public buyWeights;

    // AMM
    Factory public factory;
    Router public router;

    Pair public pair_WETH_DAI;
    Pair public pair_WETH_USDC;
    Pair public pair_DAI_USDC;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        vm.deal(user0, 10000 ether);
        vm.deal(user1, 10000 ether);

        // mint tokens
        deal(address(WETH()), user0, 10000 ether);
        deal(address(WETH()), user1, 10000 ether);
        deal(address(DAI()), user0, 10000 ether);
        deal(address(DAI()), user1, 10000 ether);
        deal(address(USDC()), user0, 10000e6);
        deal(address(USDC()), user1, 10000e6);

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

        aggregator = new LSDAggregator(adaptors, depositWeights, buyWeights);
        vm.makePersistent(address(aggregator));

        factory = new Factory(address(0), payable(aggregator));
        router = new Router(address(factory), payable(WETH()));

        pair_WETH_DAI = Pair(factory.createPair(address(WETH()), address(DAI())));
        pair_WETH_USDC = Pair(factory.createPair(address(WETH()), address(USDC())));
        pair_DAI_USDC = Pair(factory.createPair(address(DAI()), address(USDC())));

        // approve tokens to pair
        vm.startPrank(user0);
        DAI().approve(address(router), type(uint256).max);
        WETH().approve(address(router), type(uint256).max);
        USDC().approve(address(router), type(uint256).max);
        vm.stopPrank();
        vm.startPrank(user1);
        DAI().approve(address(router), type(uint256).max);
        WETH().approve(address(router), type(uint256).max);
        USDC().approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_pair_WETH_DAI() public {
        Pair pair = pair_WETH_DAI;
        // add liquidity from users
        vm.startPrank(user0);
        (, , uint256 lp0) = router.addLiquidity(
            address(WETH()),
            address(DAI()),
            100e18,
            10000e18,
            100e18,
            10000e18,
            user0,
            block.timestamp
        );
        vm.stopPrank();
        vm.startPrank(user1);
        (, , uint256 lp1) = router.addLiquidity(
            address(WETH()),
            address(DAI()),
            100e18,
            10000e18,
            100e18,
            10000e18,
            user1,
            block.timestamp
        );
        vm.stopPrank();

        console.log('lp0: %s', lp0);
        console.log('lp1: %s', lp1);

        require(lp0 > 0, 'zero lp0');
        require(lp1 > 0, 'zero lp1');
        // require(lp0 == lp1, 'lp0 != lp1');
        require(withinError(lp0, lp1, lp0 / 1000000), 'lp0 and lp1 differs a lot');

        require(WETH().balanceOf(address(pair)) > 0, "pair doesn't received WETH");
        require(DAI().balanceOf(address(pair)) > 0, "pair doesn't received DAI");
    }
}
