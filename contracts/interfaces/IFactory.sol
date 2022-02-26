// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
    /**
     * Factory functions
     */

    /**
     * @notice Deploys an NFT contract.
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
    ) external returns (address nft);

    // Ownership functions
    function owner() external view returns (address);

    function setOwner(address _newOwner) external returns (address);
}