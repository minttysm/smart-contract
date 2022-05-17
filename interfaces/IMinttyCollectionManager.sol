// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMinttyCollectionManager {
    event CollectionCreated(
        string indexed id,
        address indexed collectionAddress
    );

    function setCollectionTracking(
        string calldata id,
        address collectionAddress
    ) external;

    function checkCollectionAddress(string calldata id)
        external
        view
        returns (address);
}
