// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/console.sol';

import { IERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

import { ReentrancyGuard } from '../../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol';

import { WETHInterface } from '../lib/WETHInterface.sol';
import { Constants } from '../lib/Constants.sol';

abstract contract BaseAdaptor is ReentrancyGuard, Constants {
    uint256 public constant PRECISION = 1e18;

    event Deposited(address indexed account, uint256 ethAmount);
    event Withdrawn(address indexed account, uint256 ethAmount);

    receive() external payable virtual {
        // require(msg.sender == address(WETH()), 'NOT WETH');
    }

    /// @dev return a name of adaptor
    function adaptorName() public pure virtual returns (string memory);

    /// @dev get a list of tokens. returned `token0` must be yield-bearing token.
    /// @param token0 Address of token that user deposit (e.g., ETH, WETH)
    /// @param token1 Address of token that yield-bearing token (e.g., wstETH, sfrxETH)
    function getTokens() public view virtual returns (address token0, address token1);

    /// @dev return true if adaptor accepts deposit
    function canDeposit(uint256 amount) public view virtual returns (bool);

    /// @dev external function to convert ETH directly to yield-bearing token via adaptor.
    ///      A derived contract must implement `_deposit` function.
    /// @return The amount of yield-bearing token.
    function deposit() external payable nonReentrant returns (uint256) {
        require(msg.value > 0, 'ZERO ETH AMOUNT');
        require(canDeposit(msg.value), 'CANNOT DEPOSIT');

        uint256 res = _deposit();

        (, address token) = getTokens();
        SafeERC20.safeTransfer(IERC20(token), msg.sender, res);

        emit Deposited(msg.sender, res);
        return res;
    }

    function _deposit() internal virtual returns (uint256);

    /// @dev return true if adaptor support direct conversion from yield-bearing token to ETH.
    function canWithdraw(uint256 amount) public view virtual returns (bool);

    /// @dev return amount of ETH worth as the amout of yield-bearing token
    function getETHAmount(uint256 tokenAmount) public view virtual returns (uint256);

    function getTokenAmount(uint256 ethAmount) public view returns (uint256) {
        // TODO: consider rounding error
        return ((ethAmount * 1e18) / getETHAmount(1 ether)) / 1e18;
    }

    /// @dev external function to convert yield-bearing token directly to ETH via adaptor.
    ///      A derived contract must implement `_withdraw` function.
    /// @param amount The amount of yield-bearing token to withdraw.
    /// @return The amount of ETH transfered to msg.sender.
    function withdraw(uint256 amount) external nonReentrant returns (uint256) {
        require(amount > 0, 'ZERO AMOUNT');
        require(canWithdraw(amount), 'CANNOT WITHDRAW');

        (, address token) = getTokens();
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount);

        uint256 res = _withdraw(amount);

        // TODO: safer way to transfer ETH
        payable(msg.sender).transfer(res);

        emit Withdrawn(msg.sender, res);
        return res;
    }

    function _withdraw(uint256 amount) internal virtual returns (uint256);

    /// @dev buy yield-bearing token from a recommended dex
    function buyToken() external payable nonReentrant returns (uint256) {
        require(msg.value > 0, 'ZERO ETH AMOUNT');

        uint256 res = _buyToken();

        (, address token) = getTokens();
        SafeERC20.safeTransfer(IERC20(token), msg.sender, res);

        return res;
    }

    function _buyToken() internal virtual returns (uint256);

    /// @dev sell yield-bearing token from a recommended dex
    function sellToken(uint256 amount) external nonReentrant returns (uint256) {
        require(amount > 0, 'ZERO AMOUNT');

        // retrieve yield-bearing token from user
        (, address token) = getTokens();
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount);

        uint256 res = _sellToken(amount);

        // TODO: safer way to transfer ETH
        // transfer ETH to msg.sender
        payable(msg.sender).transfer(res);

        return res;
    }

    function _sellToken(uint256 amount) internal virtual returns (uint256);

    /// @dev get APR for liquid staking
    function getAPR() public view virtual returns (uint256);
}
