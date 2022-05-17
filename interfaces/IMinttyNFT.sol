// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMinttyNFT {
    event MintNft(string id, uint256 nftId);

    event MintBatchNft(string[] ids, uint256[] nftIds);

    function mint(
        address _to,
        address _creator,
        string calldata _id,
        uint256 _amount,
        string calldata _uri,
        bytes calldata _data
    ) external;

    function multipleMintBatch(
        address[] calldata _tos,
        address[] calldata _nftCreators,
        string[] calldata _ids,
        uint256[] calldata _amounts,
        string[] calldata _uris
    ) external;

    function mintBatch(
        address _to,
        address[] calldata _nftCreators,
        string[] calldata _ids,
        uint256[] calldata _amounts,
        string[] calldata _uris,
        bytes calldata _data
    ) external;

    function burn(
        address _owner,
        uint256 _id,
        uint256 _amount
    ) external;

    function burnBatch(
        address _owner,
        uint256[] calldata _ids,
        uint256[] calldata _amounts
    ) external;

    function creator(uint256 id) external view returns (address);
}
