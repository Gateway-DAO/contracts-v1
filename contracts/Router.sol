// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";
import "@rari-capital/solmate/src/utils/CREATE3.sol";

import "./Signature.sol";
import "./interfaces/IFactory.sol";

contract Router is Ownable, ReentrancyGuard, Signature {
    // ECDSA
    using ECDSA for bytes32;

    // Factories
    address private REWARD_FACTORY;
    address private CONTRIBUTOR_FACTORY;

    // Types of NFTs
    enum NFTType {
        REWARD,
        CONTRIBUTOR
    }

    event MintRewardNFT(address _address);
    event MintContributorNFT(address _address);

    /**
     * @notice Initializes the contract setting Gateway's signature address and NFT factories.
     *
     * @param _gatewayAddress Gateway's signature address (for permission validation).
     * @param _rewardFactoryAddress RewardNFTFactory's address (for deploying RewardNFT contracts).
     * @param _contributorFactoryAddress ContributorNFTFactory's address (for deploying ContributorNFT contracts).
     */
    constructor(
        address _gatewayAddress,
        address _rewardFactoryAddress,
        address _contributorFactoryAddress
    ) {
        require(
            msg.sender != _gatewayAddress,
            "Verification address can't be the sender's address"
        );
        require(
            IFactory(_rewardFactoryAddress).owner() == msg.sender,
            "Factory isn't owned by Gateway"
        );
        require(
            IFactory(_contributorFactoryAddress).owner() == msg.sender,
            "Factory isn't owned by Gateway"
        );

        SIGNER = _gatewayAddress;
        REWARD_FACTORY = _rewardFactoryAddress;
        CONTRIBUTOR_FACTORY = _contributorFactoryAddress;
    }

    /**
     * @notice Deploys an NFT contract for a DAO
     *
     * @param _name The name of the NFT
     * @param _symbol The symbol of the NFT
     * @param _baseTokenURI The base token URI of the NFT
     * @param _daoAdmins The DAO admins that have permission to mint the NFT
     * @param _allowTransfers A boolean value to authorize/unauthorize NFT transferibility
     * @param _signature Gateway signature to validate the deployment
     * @param _nonce A nonce passed by Gateway for validating the deployment
     * @param _type The type of NFT being deployed (Reward or Contributor)
     */
    function deployNFT(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        address[] memory _daoAdmins,
        bool _allowTransfers,
        bytes memory _signature,
        string memory _nonce,
        NFTType _type
    ) public {
        require(
            _type == NFTType.CONTRIBUTOR || _type == NFTType.REWARD,
            "Must be a Reward or Contributor NFT"
        );

        // Verify if Gateway has given permissions for the minter
        validateSignature(_signature, _nonce);

        IFactory factory = IFactory(
            _type == NFTType.REWARD ? REWARD_FACTORY : CONTRIBUTOR_FACTORY
        );

        require(factory.owner() == owner(), "Factory isn't owned by Gateway");

        address nft = factory.deploy(
            _name,
            _symbol,
            _baseTokenURI,
            _daoAdmins,
            SIGNER,
            _allowTransfers
        );

        if (_type == NFTType.REWARD) {
            emit MintRewardNFT(nft);
        } else if (_type == NFTType.CONTRIBUTOR) {
            emit MintContributorNFT(nft);
        }
    }

    /**
     * Factory Information
     */

    /**
     * @dev Returns the address of the RewardNFT factory.
     */
    function getRewardNFTFactoryAddress() public view returns (address) {
        return REWARD_FACTORY;
    }

    /**
     * @dev Returns the address of the ContributorNFT factory.
     */
    function getContributorNFTFactoryAddress() public view returns (address) {
        return CONTRIBUTOR_FACTORY;
    }
}
