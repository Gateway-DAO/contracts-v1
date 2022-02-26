// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IFactory.sol";

import "../RewardNFT.sol";

contract RewardNFTFactory is IFactory {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    /**
     * @notice Deploys a RewardNFT contract.
     *
     * @param _name The name of the NFT
     * @param _symbol The symbol of the NFT
     * @param _baseTokenURI The base token URI of the NFT
     * @param _daoAdmins The DAO admins that have permission to mint the NFT
     * @param _allowTransfers A boolean value to authorize/unauthorize NFT transferibility
     * @param _minterAllowerAddr The address of the signature validator (by default, Gateway)
     */
    function deploy(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        address[] memory _daoAdmins,
        address _minterAllowerAddr,
        bool _allowTransfers
    ) public override(IFactory) returns (address nft) {
        nft = address(new RewardNFT(_name, _symbol, _baseTokenURI, _daoAdmins, _minterAllowerAddr, _allowTransfers));
    }

    function owner() public view virtual override(IFactory) returns (address) {
        return _owner;
    }

    function setOwner(address _newOwner) public override(IFactory) returns (address) {
        require(msg.sender == _owner, "Not the owner");
        _owner = _newOwner;
    }
}