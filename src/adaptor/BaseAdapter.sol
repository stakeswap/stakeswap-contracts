// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ReentrancyGuard} from "../../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

abstract contract BaseAdapter is ReentrancyGuard {
    uint256 public constant PRECISION = 1e18;

    uint256 public accDeposit;
    uint256 public accWithdraw;

    /// @dev return a name of adaptor
    function adaptorName() public pure virtual returns (string memory);

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    function getTokens() public view virtual returns (address token0, address token1, address token2);

    /// @dev get the name
    function getDepositAmount(uint256 amount) public view virtual returns (uint256);

    /// @dev return true if adaptor accepts deposit
    function canDeposit(uint256 amount) public view virtual returns (bool);

    /// @dev deposit ETH to adaptor to farm staking reward
    function deposit() public payable virtual returns (uint256);

    /// @dev withdraw token and receive ETH
    function supportWithdraw() public pure virtual returns (bool);

    /// @dev withdraw token and receive ETH
    function withdraw(uint256 amount) public view virtual returns (uint256);

    /// @dev get APR for liquid staking
    function getAPR() public view virtual returns (uint256);
}
