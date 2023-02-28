// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

import { ReentrancyGuard } from '../../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol';

abstract contract BaseAdapter is ReentrancyGuard {
    uint256 public constant PRECISION = 1e18;

    event Deposited(address indexed account, uint256 ethAmount);
    event Withdrawn(address indexed account, uint256 ethAmount);

    /// @dev return a name of adaptor
    function adaptorName() public pure virtual returns (string memory);

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    function getTokens() public view virtual returns (address token0, address token1, address token2);

    /// @dev return true if adaptor accepts deposit
    function canDeposit(uint256 amount) public view virtual returns (bool);

    /// @dev external function to convert ETH to yield-bearing token.
    ///      A derived contract must implement `_deposit` function.
    /// @return The amount of yield-bearing token.
    function deposit() external payable nonReentrant returns (uint256) {
        require(msg.value > 0, 'ZERO ETH AMOUNT');
        require(canDeposit(msg.value), 'CANNOT DEPOSIT');

        uint256 res = _deposit();

        (address token, , ) = getTokens();
        SafeERC20.safeTransfer(IERC20(token), msg.sender, res);

        emit Deposited(msg.sender, res);
        return res;
    }

    function _deposit() internal virtual returns (uint256);

    /// @dev return true if adaptor support direct conversion from yield-bearing token to ETH.
    function canWithdraw() public view virtual returns (bool);

    /// @dev external function to convert yield-bearing token to ETH.
    ///      A derived contract must implement `_withdraw` function.
    /// @param amount The amount of yield-bearing token to withdraw.
    /// @return The amount of ETH transfered to msg.sender.
    function withdraw(uint256 amount) external nonReentrant returns (uint256) {
        require(amount > 0, 'ZERO AMOUNT');
        require(canDeposit(amount), 'CANNOT DEPOSIT');
        require(canWithdraw(), 'CANNOT WITHDRAW');

        (address token, , ) = getTokens();
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount);

        uint256 res = _withdraw(amount);

        emit Withdrawn(msg.sender, res);
        return res;
    }

    function _withdraw(uint256 amount) internal virtual returns (uint256);

    /// @dev get APR for liquid staking
    function getAPR() public view virtual returns (uint256);
}
