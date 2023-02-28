// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { WETHInterface } from './WETHInterface.sol';

import { ILido as ST_ETH } from './ILido.sol';
import { IWstETH as WST_ETH } from './IWstETH.sol';

import { frxETHMinter as FrxETHMinter } from '../../lib/frxETH-public/src/frxETHMinter.sol';
import { IERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { sfrxETH as SFRX_ETH } from '../../lib/frxETH-public/src/sfrxETH.sol';

import { IrETH as R_ETH } from './IrETH.sol';

import { BalancerV2VaultInterface } from './balancer-v2/interfaces/BalancerV2VaultInterface.sol';

contract Constants {
    ////////////////////////////////////////////////////////////////
    // WETH
    ////////////////////////////////////////////////////////////////
    function WETH() public view returns (WETHInterface) {
        if (block.chainid == 1) return WETHInterface(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        if (block.chainid == 5) return WETHInterface(payable(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6));
        revert('unknown chain id');
    }

    ////////////////////////////////////////////////////////////////
    // Lido Finance
    ////////////////////////////////////////////////////////////////

    function stETH() public view returns (ST_ETH) {
        if (block.chainid == 1) return ST_ETH(payable(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84));
        if (block.chainid == 5) return ST_ETH(payable(0x1643E812aE58766192Cf7D2Cf9567dF2C37e9B7F));
        revert('unknown chain id');
    }

    function wstETH() public view returns (WST_ETH) {
        if (block.chainid == 1) return WST_ETH(payable(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0));
        if (block.chainid == 5) return WST_ETH(payable(0x6320cD32aA674d2898A68ec82e869385Fc5f7E2f));
        revert('unknown chain id');
    }

    ////////////////////////////////////////////////////////////////
    // frax-ether
    ////////////////////////////////////////////////////////////////
    function frxETH() public view returns (IERC20) {
        if (block.chainid == 1) return IERC20(0x5E8422345238F34275888049021821E8E08CAa1f);
        if (block.chainid == 5) return IERC20(0x3E04888B1C07a9805861c19551f7ed53145BD8D4); // frx finance - dev
        revert('unknown chain id');
    }

    function sfrxETH() public view returns (SFRX_ETH) {
        if (block.chainid == 1) return SFRX_ETH(0xac3E018457B222d93114458476f3E3416Abbe38F);
        if (block.chainid == 5) return SFRX_ETH(0x3E04888B1C07a9805861c19551f7ed53145BD8D4); // TODO: find actual sfrxETH on goerli
        revert('unknown chain id');
    }

    function frxETHMinter() public view returns (FrxETHMinter) {
        if (block.chainid == 1) return FrxETHMinter(payable(0xbAFA44EFE7901E04E39Dad13167D089C559c1138));
        if (block.chainid == 5) return FrxETHMinter(payable(0x6421d1Ca6Cd35852362806a2Ded2A49b6fa8bEF5)); // frx finance - dev
        revert('unknown chain id');
    }

    ////////////////////////////////////////////////////////////////
    // RocketPool
    ////////////////////////////////////////////////////////////////

    function rETH() public view returns (R_ETH) {
        if (block.chainid == 1) return R_ETH(payable(0xae78736Cd615f374D3085123A210448E74Fc6393));
        if (block.chainid == 5) return R_ETH(payable(0xae78736Cd615f374D3085123A210448E74Fc6393));
        revert('unknown chain id');
    }

    ////////////////////////////////////////////////////////////////
    // BalancerV2
    ////////////////////////////////////////////////////////////////

    function BalancerV2Vault() public view returns (BalancerV2VaultInterface) {
        if (block.chainid == 1) return BalancerV2VaultInterface(payable(0xBA12222222228d8Ba445958a75a0704d566BF2C8));
        if (block.chainid == 5) return BalancerV2VaultInterface(payable(0xBA12222222228d8Ba445958a75a0704d566BF2C8));
        revert('unknown chain id');
    }

    function BalancerV2_wstETH_WETH_POOL_ID() public view returns (bytes32) {
        if (block.chainid == 1) return 0x32296969ef14eb0c6d29669c550d4a0449130230000200000000000000000080;
        revert('unknown chain id');
    }

    function BalancerV2_rETH_ETH_POOL_ID() public view returns (bytes32) {
        if (block.chainid == 1) return 0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112;
        revert('unknown chain id');
    }

    ////////////////////////////////////////////////////////////////
    // Curve
    ////////////////////////////////////////////////////////////////

    function Curve_stETH_ETH_POOL_ADDRESS() public view returns (address) {
        if (block.chainid == 1) return 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
        revert('unknown chain id');
    }

    // coins[0] = ETH
    // coins[1] = stETH
    function Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH() public view returns (int128) {
        if (block.chainid == 1) return 0;
        revert('unknown chain id');
    }

    function Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH() public view returns (int128) {
        if (block.chainid == 1) return 1;
        revert('unknown chain id');
    }

    function Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS() public view returns (address) {
        if (block.chainid == 1) return 0x06325440D014e39736583c165C2963BA99fAf14E;
        revert('unknown chain id');
    }
}
