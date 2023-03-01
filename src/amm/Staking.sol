pragma solidity ^0.8.13;

import 'forge-std/console.sol';

import { TransferHelper, IERC20 } from '../lib/TransferHelper.sol';

import { LSDAggregatorInterface } from '../LSDAggregatorInterface.sol';
import { IPair } from './interfaces/IPair.sol';
import { IStaking } from './interfaces/IStaking.sol';
import { LP } from './LP.sol';

import { Constants } from '../lib/Constants.sol';

// TODO: make staking related function to low-level to reduce gas cost
/// @dev Staking contract is entry point of staking and unstaking.
contract Staking is Constants, LP, IStaking {
    address public factory;
    address public aggregator;
    address public pair;
    // address public immutable factory;
    // address public immutable aggregator;
    // address public immutable pair;

    uint256 public stakedETH;

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    receive() external payable {}

    constructor(address _aggregator, address _pair) {
        factory = msg.sender;
        aggregator = _aggregator;
        pair = _pair;
    }

    /// @dev stake LP token to utilize locked ETH by providing it to liquidity aggregator
    // 1. get LP from staker
    // 2. get ETH from pool
    // 3. deposit ETH to aggregator
    function stake(uint256 lp) external lock returns (uint256 shares, uint256 depositAmount) {
        // 1. get LP from staker
        TransferHelper.safeTransferFrom(pair, msg.sender, address(this), lp);

        // 2. get ETH from pool
        IPair(pair).onStake(lp);
        depositAmount = address(this).balance;
        require(depositAmount > 0, 'ZERO_DEPOSIT');

        stakedETH += depositAmount;

        // 3. deposit ETH to aggregator
        shares = LSDAggregatorInterface(payable(aggregator)).deposit{ value: depositAmount }();
        _mint(msg.sender, shares);
    }

    // 1. redeem ETH from aggregator
    // 2. return WETH to pool (The amount should be equal to the deposit.)
    // 3. return ETH reward to staker
    // 4. return LP to staker
    // 그럼 여기서 2번과 3번 물량을 어떻게 구분하지? -- underflow 조건 체크...ㅎ;
    function unstake(
        uint256 shares,
        address staker
    ) external lock returns (uint256 lp, uint256 totalEthForShare, uint256 poolETHAmount, uint256 rewardToStaker) {
        uint256 supply = totalSupply; // gas savings
        lp = (IERC20(pair).balanceOf(address(this)) * shares) / supply;
        poolETHAmount = (stakedETH * shares) / supply;
        _burn(msg.sender, shares);

        // 1. redeem ETH from aggregator (pool ETH + reward ETH)
        totalEthForShare = LSDAggregatorInterface(payable(aggregator)).redeem(shares);
        require(totalEthForShare > poolETHAmount, 'NEGATIVE_STAKE_REWARD');
        rewardToStaker = totalEthForShare - poolETHAmount;

        // 2. return WETH to pool
        stakedETH -= poolETHAmount; // this guarentees that pool doesn't loss it's ETH
        IPair(pair).onUnstake{ value: poolETHAmount }();

        // 3. return ETH reward to staker
        TransferHelper.safeTransferETH(staker, rewardToStaker);

        console.log('rewardToStaker from contract:', rewardToStaker);

        // 4. return LP to staker
        TransferHelper.safeTransfer(pair, staker, lp);
    }
}
