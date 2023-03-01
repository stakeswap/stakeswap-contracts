pragma solidity >=0.5.0;

import { ILP } from './ILP.sol';

interface IStaking is ILP {
    function factory() external view returns (address);

    function aggregator() external view returns (address);

    function pair() external view returns (address);

    function stake(uint256 lp) external returns (uint256 shares, uint256 depositAmount);

    function unstake(
        uint256 shares,
        address staker
    ) external returns (uint256 lp, uint256 totalEthForShare, uint256 poolETHAmount, uint256 rewardToStaker);
}
