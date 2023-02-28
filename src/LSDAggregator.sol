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

import { LSDAggregatorInterface } from './LSDAggregatorInterface.sol';

/// @dev An aggregator for liquid staking derivatives such as lido, frax-ether, rocketpool.
/// Note that we cannot use ERC4626 with supporting DEX as withdrawal strategy because dex doesn't provide 1-to-1 conversion rate.
contract LSDAggregator is LSDAggregatorInterface, Constants, Ownable, ReentrancyGuard, ERC20 {
    using FixedPointMathLib for uint256;

    uint256 constant TOTAL_WEIGHT = 10_000;

    BaseAdaptor[] public adaptors;
    mapping(BaseAdaptor => bool) public isAdaptor;

    // NOTE: sum of depositWeights and buyWeights must be equal to TOTAL_WEIGHT
    // NOTE: We have separate weights because DEX offers a better price than direct deposit to LSD.
    mapping(BaseAdaptor => uint256) public depositWeights;
    mapping(BaseAdaptor => uint256) public buyWeights;

    receive() external payable {}

    constructor(
        BaseAdaptor[] memory _adaptors,
        uint256[] memory _depositWeights,
        uint256[] memory _buyWeights
    ) ERC20('Aggregated Staking ETH', 'aeETH') {
        _setAdaptors(_adaptors, _depositWeights, _buyWeights);
        // approve max for depositWithETH
        WETH().approve(address(this), type(uint256).max);
    }

    function deposit() public payable virtual returns (uint256 shares) {
        require(msg.value > 0, 'ZERO_VALUE');

        for (uint256 i = 0; i < adaptors.length; i++) {
            BaseAdaptor a = adaptors[i];
            uint256 depositValue = (msg.value * depositWeights[a]) / TOTAL_WEIGHT;
            uint256 buyValue = (msg.value * buyWeights[a]) / TOTAL_WEIGHT;

            // if adaptor doesn't support deposit, buy all token from DEX
            if (!a.canDeposit(depositValue)) {
                buyValue += depositValue;
                depositValue = 0;
            }

            uint256 tokens;
            // NOTE: We can deposit directly to LSD, but not because the price is much better in DEX.
            if (depositValue > 0) tokens += a.deposit{ value: depositValue }();
            if (buyValue > 0) tokens += a.buyToken{ value: buyValue }();

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

    function previewRedeem(uint256 shares) public view returns (uint256 assets) {
        if (shares == 0) return 0;
        uint256 supply = totalSupply();

        for (uint256 i = 0; i < adaptors.length; i++) {
            BaseAdaptor a = adaptors[i];
            (, address token1) = a.getTokens();
            uint256 value = (IERC20(token1).balanceOf(address(this)) * shares) / supply;

            assets += a.getETHAmount(value);
        }
    }

    /* ========== Adaptor ========== */

    modifier onlyAdaptor() {
        require(isAdaptor[BaseAdaptor(payable(msg.sender))] == true, 'non-adaptor');
        _;
    }

    function setWeights(
        BaseAdaptor[] calldata _adaptors,
        uint256[] calldata _depositWeights,
        uint256[] calldata _buyWeights
    ) external onlyOwner {
        require(_adaptors.length == adaptors.length, 'LENGTH_MISMATCH');
        require(_adaptors.length == _depositWeights.length, 'LENGTH_MISMATCH');
        require(_adaptors.length == _buyWeights.length, 'LENGTH_MISMATCH');

        uint256 accWeight;
        for (uint256 i = 0; i < _adaptors.length; i++) {
            BaseAdaptor a = _adaptors[i];
            require(isAdaptor[a], 'NOT_ADAPTOR');
            depositWeights[a] = _depositWeights[i];
            buyWeights[a] = _buyWeights[i];
            accWeight += _depositWeights[i] + _buyWeights[i];
        }
        require(accWeight == TOTAL_WEIGHT, 'INVALID_DENOMINATOR');
    }

    function setAdaptors(
        BaseAdaptor[] calldata _adaptors,
        uint256[] calldata _depositWeights,
        uint256[] calldata _buyWeights
    ) external onlyOwner {
        return _setAdaptors(_adaptors, _depositWeights, _buyWeights);
    }

    // NOTE: Before remove adaptors, we have to liquidate tokens that adaptors support.
    //       But we do not implement it for simplicity.
    function _setAdaptors(BaseAdaptor[] memory _adaptors, uint256[] memory _depositWeights, uint256[] memory _buyWeights) private {
        require(_adaptors.length == _depositWeights.length, 'LENGTH_MISMATCH');
        require(_adaptors.length == _buyWeights.length, 'LENGTH_MISMATCH');

        // TODO: optimize unset-set process (e.g., approve 0 then approve max, SSTORE 0 then SSTORE 1)
        // TODO: redeem yield-bearing token to ETH if adaptor is permanently removed (those ETH must be re-allocated)
        // reset previous adaptors and weights
        for (uint256 i = 0; i < adaptors.length; i++) {
            BaseAdaptor a = adaptors[i];
            isAdaptor[a] = false;
            depositWeights[a] = 0;
            buyWeights[a] = 0;
            WETH().approve(address(a), 0);
        }

        // register new adaptors and weights
        adaptors = _adaptors;
        uint256 accWeight;
        for (uint256 i = 0; i < _adaptors.length; i++) {
            BaseAdaptor a = _adaptors[i];
            isAdaptor[a] = true;
            depositWeights[a] = _depositWeights[i];
            buyWeights[a] = _buyWeights[i];
            accWeight += _depositWeights[i] + _buyWeights[i];
            WETH().approve(address(a), type(uint256).max);
        }
        require(accWeight == TOTAL_WEIGHT, 'INVALID_DENOMINATOR');
    }
}
