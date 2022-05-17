// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IMinttyCollectionManager.sol";
import "./interfaces/IMinttyNFT.sol";
import "./ERC1155.sol";
import "./utils/Address.sol";
import "./access/Ownable.sol";

contract MinttyNFT is ERC1155, IMinttyNFT, Ownable {
    using Address for address;

    // Contract name
    string public name;

    // Contract symbol
    string public symbol;

    // Total NFT
    uint256 public total;

    // Mapping from token ID to creator address
    mapping(uint256 => address) public _creators;

    // Mapping from token ID to custom uri
    mapping(uint256 => string) _customUris;

    // Mapping from cex ID to Nft ID
    mapping(string => uint256) _cexNftIds;

    mapping(address => bool) public _operators;

    modifier onlyOperator() {
        require(_operators[msg.sender], "Forbidden");
        _;
    }

    constructor(
        string memory _id,
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address collectionManagerAddress
    ) ERC1155(_uri) {
        name = _name;
        symbol = _symbol;
        _operators[msg.sender] = true;
        IMinttyCollectionManager(collectionManagerAddress)
            .setCollectionTracking(_id, address(this));
    }

    function uri(uint256 _id) public view override returns (string memory) {
        require(_exists(_id), "MinttyNFT: NONEXISTENT_TOKEN");
        // We have to convert string to bytes to check for existence
        bytes memory customUriBytes = bytes(_customUris[_id]);
        if (customUriBytes.length > 0) {
            return _customUris[_id];
        } else {
            return super.uri(_id);
        }
    }

    function mint(
        address _to,
        address _creator,
        string calldata _id,
        uint256 _amount,
        string calldata _uri,
        bytes calldata _data
    ) external override onlyOperator {
        require(_cexNftIds[_id] == 0, string(abi.encodePacked("exist: ", _id)));
        total += 1;
        _cexNftIds[_id] = total;
        _mint(_to, total, _amount, _data);
        if (_creator == address(0)) {
            _creators[total] = _to;
        } else {
            _creators[total] = _creator;
        }
        _customUris[total] = _uri;
        emit MintNft(_id, total);
    }

    function mintBatch(
        address _to,
        address[] calldata _nftCreators,
        string[] calldata _ids,
        uint256[] calldata _amounts,
        string[] calldata _uris,
        bytes calldata _data
    ) external override onlyOperator {
        require(
            _nftCreators.length == _ids.length,
            "MinttyNFT: ids and creators length mismatch"
        );
        uint256[] memory nftIds = new uint256[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            require(
                _cexNftIds[_ids[i]] == 0,
                string(abi.encodePacked("exist: ", _ids[i]))
            );
            total += 1;
            _cexNftIds[_ids[i]] = total;
            nftIds[i] = total;
            if (_nftCreators[i] == address(0)) {
                _creators[total] = _to;
            } else {
                _creators[total] = _nftCreators[i];
            }
            _customUris[total] = _uris[i];
        }
        _mintBatch(_to, nftIds, _amounts, _data);
        emit MintBatchNft(_ids, nftIds);
    }

    function multipleMintBatch(
        address[] calldata _tos,
        address[] calldata _nftCreators,
        string[] calldata _ids,
        uint256[] calldata _amounts,
        string[] calldata _uris
    ) external override onlyOperator {
        require(
            _nftCreators.length == _ids.length,
            "MinttyNFT: ids and creators length mismatch"
        );
        uint256[] memory nftIds = new uint256[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            require(
                _cexNftIds[_ids[i]] == 0,
                string(abi.encodePacked("exist: ", _ids[i]))
            );
            total += 1;
            _cexNftIds[_ids[i]] = total;
            nftIds[i] = total;
            if (_nftCreators[i] == address(0)) {
                _creators[total] = _tos[i];
            } else {
                _creators[total] = _nftCreators[i];
            }
            _customUris[total] = _uris[i];
        }
        _multipleMintBatch(_tos, nftIds, _amounts);
        emit MintBatchNft(_ids, nftIds);
    }

    function burn(
        address _owner,
        uint256 _id,
        uint256 _amount
    ) external override onlyOwner {
        _burn(_owner, _id, _amount);
    }

    function burnBatch(
        address _owner,
        uint256[] calldata _ids,
        uint256[] calldata _amounts
    ) external override onlyOwner {
        _burnBatch(_owner, _ids, _amounts);
    }

    function setOperator(address operatorAddress, bool value)
        external
        onlyOwner
    {
        _operators[operatorAddress] = value;
    }

    function creator(uint256 _id) external view override returns (address) {
        return _creators[_id];
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return _creators[_id] != address(0);
    }
}
