// Modified factory contracrt based on UniswapV2Factory
pragma solidity ^0.8.13;

import { IFactory } from './interfaces/IFactory.sol';
import { Pair } from './Pair.sol';

import { Staking } from './Staking.sol';

import { Constants } from '../lib/Constants.sol';
import { LSDAggregatorInterface } from '../LSDAggregatorInterface.sol';

contract Factory is IFactory, Constants {
    address public feeTo;
    address public feeToSetter;

    address payable public aggregator;

    mapping(address => mapping(address => address)) public getPair;
    mapping(address => mapping(address => address)) public getStaking;
    address[] public allPairs;
    address[] public allStakings;

    constructor(address _feeToSetter, address payable _aggregator) {
        feeToSetter = _feeToSetter;
        aggregator = _aggregator;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function allStakingsLength() external view returns (uint) {
        return allStakings.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address payable pair) {
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        Staking staking = new Staking(aggregator, pair);
        Pair(pair).initialize(token0, token1, address(staking));

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        getStaking[token0][token1] = address(staking);
        getStaking[token1][token0] = address(staking);
        allPairs.push(pair);
        allStakings.push(address(staking));
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
