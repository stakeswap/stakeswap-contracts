// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import { IERC20 } from '../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { ERC20 } from '../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';
import { SafeERC20 } from '../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import { BaseAdaptor } from './adaptor/BaseAdaptor.sol';
import { Ownable } from '../lib/openzeppelin-contracts/contracts/access/Ownable.sol';
import { ReentrancyGuard } from '../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol';

import { IERC4626 } from '../lib/forge-std/src/interfaces/IERC4626.sol';
import { FixedPointMathLib } from '../lib/frxETH-public/lib/solmate/src/utils/FixedPointMathLib.sol';

import { Constants } from './lib/Constants.sol';

/// @dev An aggregator for liquid staking derivatives such as lido, frax-ether, rocketpool.
/// Note that we cannot use ERC4626 with supporting DEX as withdrawal strategy because dex doesn't provide 1-to-1 conversion rate.
contract LSDAggregator is Constants, Ownable, ReentrancyGuard, ERC20 {
    using FixedPointMathLib for uint256;

    uint256 constant TOTAL_WEIGHT = 10_000;

    BaseAdaptor[] public adaptors;
    mapping(BaseAdaptor => bool) public isAdaptor;
    mapping(BaseAdaptor => uint256) public weights; // NOTE: sum of weights must be 10,000

    receive() external payable {}

    constructor(BaseAdaptor[] memory _adaptors, uint256[] memory _weights) ERC20('Aggregated Staking ETH', 'aeETH') {
        _setAdaptors(_adaptors, _weights);
        // approve max for depositWithETH
        WETH().approve(address(this), type(uint256).max);
    }

    function deposit() public payable virtual returns (uint256 shares) {
        require(msg.value > 0, 'ZERO_VALUE');

        for (uint256 i = 0; i < adaptors.length; i++) {
            BaseAdaptor a = adaptors[i];
            uint256 weight = weights[a];
            uint256 value = (msg.value * weight) / TOTAL_WEIGHT;

            uint256 tokens;

            if (a.canDeposit(value)) {
                tokens = a.deposit{ value: value }();
            } else {
                tokens = a.buyToken{ value: value }();
            }
            shares += a.getETHAmount(tokens);
        }

        _mint(msg.sender, shares);

        // emit Deposit(msg.sender, receiver, assets, shares);
    }

    function redeem(uint256 shares) public virtual returns (uint256 assets) {
        require(shares > 0, 'ZERO_SHARE');
        uint256 supply = totalSupply();

        for (uint256 i = 0; i < adaptors.length; i++) {
            BaseAdaptor a = adaptors[i];
            (, address token1) = a.getTokens();
            uint256 value = (IERC20(token1).balanceOf(address(this)) * shares) / supply;

            if (a.canWithdraw(value)) {
                assets += (a.withdraw(value));
            } else {
                SafeERC20.safeApprove(IERC20(token1), address(a), value);
                assets += (a.sellToken(value));
            }
        }

        _burn(msg.sender, shares);

        // TODO: safer way to transfer
        payable(msg.sender).transfer(assets);

        // emit Deposit(msg.sender, receiver, assets, shares);
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
