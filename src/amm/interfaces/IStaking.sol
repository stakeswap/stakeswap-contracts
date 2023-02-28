pragma solidity >=0.5.0;

import { ILP } from './ILP.sol';

interface IStaking is ILP {
    function factory() external view returns (address);

    function aggregator() external view returns (address);

    function pair() external view returns (address);

    function getEffectiveETHAmount(uint256 lp) external view returns (uint256 ethAmount);

    function getTotalEffectiveETHAmount() external view returns (uint256 ethAmount);
}
