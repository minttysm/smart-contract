// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IMinttyCollectionManager.sol";
import "./access/Ownable.sol";

contract MinttyCollectionManager is IMinttyCollectionManager, Ownable {
    mapping(address => bool) public _operators;
    mapping(string => address) public _minttyCollectionTracking;

    modifier onlyOperator() {
        require(_operators[msg.sender] || _operators[tx.origin], "Forbidden");
        _;
    }

    constructor() {
        _operators[msg.sender] = true;
    }

    function setCollectionTracking(
        string calldata id,
        address collectionAddress
    ) external override onlyOperator {
        bytes calldata strBytes = bytes(id);
        require(strBytes.length > 0, "Invalid id");
        require(collectionAddress != address(0), "zero address");
        require(_minttyCollectionTracking[id] == address(0), "exist");
        _minttyCollectionTracking[id] = collectionAddress;
        emit CollectionCreated(id, collectionAddress);
    }

    function checkCollectionAddress(string calldata id)
        external
        view
        override
        returns (address)
    {
        return _minttyCollectionTracking[id];
    }

    function setOperator(address operatorAddress, bool value)
        external
        onlyOwner
    {
        require(
            operatorAddress != address(0),
            "operatorAddress is zero address"
        );
        _operators[operatorAddress] = value;
    }
}
