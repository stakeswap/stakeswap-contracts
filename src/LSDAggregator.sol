// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import { BaseAdaptor } from './adaptor/BaseAdaptor.sol';
import { Ownable } from '../lib/openzeppelin-contracts/contracts/access/Ownable.sol';
import { ReentrancyGuard } from '../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol';

import { ERC20, ERC4626, xERC4626 } from '../lib/frxETH-public/lib/ERC4626/src/xERC4626.sol';

import { Constants } from './lib/Constants.sol';

/// @dev An aggregator for liquid staking derivatives such as lido, frax-ether, rocketpool.
/// @dev when user deposits, queued ETH is not staked yet
contract LSDAggregator is Constants, Ownable, ReentrancyGuard, xERC4626 {
    uint256 constant TOTAL_WEIGHT = 10_000;

    BaseAdaptor[] public adaptors;
    mapping(BaseAdaptor => bool) public isAdaptor;
    mapping(BaseAdaptor => uint256) public weights; // NOTE: sum of weights must be 10,000

    modifier andSync() {
        if (block.timestamp >= rewardsCycleEnd) {
            syncRewards();
        }
        _;
    }

    receive() external payable {}

    constructor(
        BaseAdaptor[] memory _adaptors,
        uint256[] memory _weights
    ) ERC4626(ERC20(address(WETH())), 'Aggregated Staking ETH', 'asETH') xERC4626(1024 /* _rewardsCycleLength  */) {
        _setAdaptors(_adaptors, _weights);
        WETH().approve(address(this), type(uint256).max);
    }

    /* ========== ERC4626 ========== */
    function depositWithETH(address receiver) external payable returns (uint256) {
        // convert ETH to WETH
        WETH().deposit{ value: msg.value }();

        // call deposit function as external function because ERC4626 assumes underlying token is ERC20
        return this.deposit(msg.value, receiver);
    }

    /**
     * @dev override to stake ETH to each adaptors when deposit ETH to aggregator.
     * @param assets Amount of WETH depositoed
     * @param shares Amount of shares for asETH receiver
     */
    function afterDeposit(uint256 assets, uint256 shares) internal override {
        super.afterDeposit(assets, shares);

        // convert WETH to ETH
        WETH().withdraw(assets);

        // check adaptors support deposit
        uint256 totalWeight = TOTAL_WEIGHT;
        for (uint256 i = 0; i < adaptors.length; i++) {
            BaseAdaptor a = adaptors[i];
            uint256 weight = weights[a];
            uint256 value = (assets * weight) / TOTAL_WEIGHT;
            if (!a.canDeposit(value)) {
                totalWeight -= weight;
            }
        }

        // buy LSDs according to vault strategy
        for (uint256 i = 0; i < adaptors.length; i++) {
            BaseAdaptor a = adaptors[i];
            uint256 weight = weights[a];
            uint256 value = (assets * weight) / totalWeight;

            // TODO: we may cache the result of a.canDeposit to array in memory.
            if (a.canDeposit(value)) {
                a.deposit{ value: value }();
            }
        }
    }

    function beforeWithdraw(uint256 amount, uint256 shares) internal override {
        super.beforeWithdraw(amount, shares);

        // TODO: we have to convert LSDs to ETH by selling to DEX or by requesting the withdrawal to liquid staking
        // NOTE: we only support selling via DEX until Shanghai upgrade
    }

    /* ========== Adaptor ========== */

    modifier onlyAdaptor() {
        require(isAdaptor[BaseAdaptor(payable(msg.sender))] == true, 'non-adaptor');
        _;
    }

    function setWeights(BaseAdaptor[] calldata _adaptors, uint256[] calldata _weights) external onlyOwner {
        require(_adaptors.length == adaptors.length, 'LENGTH_MISMATCH');
        uint256 accWeight;
        for (uint256 i = 0; i < _adaptors.length; i++) {
            BaseAdaptor a = _adaptors[i];
            require(isAdaptor[a], 'NOT_ADAPTOR');
            weights[a] = _weights[i];
            accWeight += _weights[i];
        }
        require(accWeight == TOTAL_WEIGHT, 'INVALID_DENOMINATOR');
    }

    function setAdaptors(BaseAdaptor[] calldata _adaptors, uint256[] calldata _weights) external onlyOwner {
        return _setAdaptors(_adaptors, _weights);
    }

    // NOTE: Before remove adaptors, we have to liquidate tokens that adaptors support.
    //       But we do not implement it for simplicity.
    function _setAdaptors(BaseAdaptor[] memory _adaptors, uint256[] memory _weights) private {
        require(_adaptors.length == _weights.length, 'Invalid Length');

        // TODO: optimize unset-set process (e.g., approve 0 then approve max, SSTORE 0 then SSTORE 1)
        // TODO: redeem yield-bearing token to ETH if adaptor is permanently removed (those ETH must be re-allocated)
        // reset previous adaptors and weights
        for (uint256 i = 0; i < adaptors.length; i++) {
            BaseAdaptor a = adaptors[i];
            isAdaptor[a] = false;
            weights[a] = 0;
            WETH().approve(address(a), 0);
        }

        // register new adaptors and weights
        adaptors = _adaptors;
        uint256 accWeight;
        for (uint256 i = 0; i < _adaptors.length; i++) {
            BaseAdaptor a = _adaptors[i];
            isAdaptor[a] = true;
            weights[a] = _weights[i];
            accWeight += _weights[i];
            WETH().approve(address(a), type(uint256).max);
        }
        require(accWeight == TOTAL_WEIGHT, 'INVALID_DENOMINATOR');
    }
}
