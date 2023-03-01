pragma solidity >=0.5.0;

interface IFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint allPairsLength);

    function aggregator() external view returns (address payable);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function getStaking(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address payable pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}
