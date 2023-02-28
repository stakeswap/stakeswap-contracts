// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { IERC20 } from '../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { BaseAdaptor } from './adaptor/BaseAdaptor.sol';

interface LSDAggregatorInterface is IERC20 {
    function adaptors(uint256 index) external view returns (BaseAdaptor);

    function isAdaptor(BaseAdaptor a) external view returns (bool);

    function depositWeights(BaseAdaptor a) external view returns (uint256);

    function buyWeights(BaseAdaptor a) external view returns (uint256);

    // receive() external payable;

    function deposit() external payable returns (uint256 shares);

    function redeem(uint256 shares) external returns (uint256 assets);

    function previewRedeem(uint256 shares) external view returns (uint256 assets);
}
