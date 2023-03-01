pragma solidity ^0.8.13;

import { IERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import { ReentrancyGuard } from 'openzeppelin-contracts/contracts/security/ReentrancyGuard.sol';

import { LSDAggregatorInterface } from '../LSDAggregatorInterface.sol';
import { IPair } from './interfaces/IPair.sol';
import { IStaking } from './interfaces/IStaking.sol';
import { LP } from './LP.sol';

import { Constants } from '../lib/Constants.sol';

/// @dev Staking contract is entry point of staking and unstaking.
contract Staking is ReentrancyGuard, Constants, LP, IStaking {
    address public immutable factory;
    address public immutable aggregator;
    address public immutable pair;

    mapping(address => uint256) private _stakedETHOf;

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
    function stake(uint256 lp) external nonReentrant returns (uint256 shares, uint256 depositAmount) {
        // 1. get LP from staker
        SafeERC20.safeTransferFrom(IERC20(pair), msg.sender, address(this), lp);

        // 2. get ETH from pool
        IPair(pair).onStake(lp);
        depositAmount = address(this).balance;
        require(depositAmount > 0, 'ZERO_DEPOSIT');

        _stakedETHOf[msg.sender] += depositAmount;

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
        uint256 shares
    ) external nonReentrant returns (uint256 lp, uint256 ethAmount, uint256 poolETHAmount, uint256 rewardToStaker) {
        lp = (IERC20(pair).balanceOf(address(this)) * shares) / totalSupply;
        uint256 stakedETHOfStaker = _stakedETHOf[msg.sender];
        uint256 sharesOfStaker = balanceOf[msg.sender];

        require(sharesOfStaker > shares, 'INSUFFICIENT_SHARES');

        // 1. redeem ETH from aggregator
        ethAmount = LSDAggregatorInterface(payable(aggregator)).redeem(shares);
        poolETHAmount = (stakedETHOfStaker * shares) / sharesOfStaker;
        require(ethAmount > poolETHAmount, 'NEGATIVE_STAKE_REWARD');
        rewardToStaker = ethAmount - poolETHAmount;

        // 2. return WETH to pool
        WETH().deposit{ value: poolETHAmount }();
        WETH().transfer(pair, poolETHAmount);

        // 3. return ETH reward to staker
        payable(msg.sender).transfer(rewardToStaker);

        // 4. return LP to staker
        SafeERC20.safeTransfer(IERC20(pair), msg.sender, lp);

        _burn(msg.sender, shares);

        IPair(pair).onUnstake(poolETHAmount);
    }

    function getEffectiveETHAmount(uint256 lp) external view returns (uint256 ethAmount) {
        return (getTotalEffectiveETHAmount() * lp) / totalSupply;
    }

    function getTotalEffectiveETHAmount() public view returns (uint256 ethAmount) {
        return LSDAggregatorInterface(aggregator).previewRedeem(LSDAggregatorInterface(aggregator).balanceOf(address(this)));
    }
}
