// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MinorError {
    function withinMinorError(uint256 x, uint256 y) internal pure returns (bool) {
        if (y < x) {
            uint256 t = x;
            x = y;
            y = t;
        }

        uint256 diff = y - x;
        return diff < 10;
    }

    function withinError(uint256 x, uint256 y, uint256 err) internal pure returns (bool) {
        if (y < x) {
            uint256 t = x;
            x = y;
            y = t;
        }

        uint256 diff = y - x;
        return diff < err;
    }
}
