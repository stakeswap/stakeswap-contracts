// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import { BaseAdapter } from './adaptor/BaseAdapter.sol';
import { Ownable } from '../lib/openzeppelin-contracts/contracts/access/Ownable.sol';
import { ReentrancyGuard } from '../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol';

contract LSDAggregator is Ownable, ReentrancyGuard {
    mapping(BaseAdapter => bool) public isAdaptor;
    BaseAdapter[] public adaptorArr;

    mapping(address => uint256) public depositOf;

    constructor() {}

    modifier onlyAdaptor() {
        require(isAdaptor[BaseAdapter(msg.sender)] == true, 'non-adaptor');
        _;
    }

    function addAdaptor(BaseAdapter _adaptor) external onlyOwner {
        require(!isAdaptor[_adaptor], 'existing-adaptor');
        isAdaptor[_adaptor] = true;
        adaptorArr.push(_adaptor);
    }

    function deposit(BaseAdapter[] calldata adaptors, uint256[] calldata amounts) external payable nonReentrant {
        require(adaptors.length > amounts.length, 'length mismatch');
        uint256 accAmount;

        for (uint256 i = 0; i < adaptors.length; i++) {
            adaptors[i].deposit{ value: amounts[i] }();
            depositOf[msg.sender] += amounts[i];
            accAmount += amounts[i];
        }

        require(accAmount == msg.value, 'value mismatch');

        // refund residual ethers
        if (address(this).balance > 0) {
            // TODO: handler return data of `call`
            (bool success, ) = msg.sender.call{ value: address(this).balance }('');
            require(success, 'F2R');
        }
    }
}
