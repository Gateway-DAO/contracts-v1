// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// NFT Types
import {RewardNFT} from "./RewardNFT.sol";
import {ContributorNFT} from "./ContributorNFT.sol";

contract Router is Ownable, ReentrancyGuard, AccessControlEnumerable {
    // ECDSA
    using ECDSA for bytes32;

    // Gateway verification address
    address private GATEWAY_ADDRESS;

    // Nonce-validation array, for guaranteeing the uniqueness of signatures and mitigate replay attacks.
    mapping(string => bool) private seenNonces;

    // Wei to ETH conversion
    uint256 private immutable UNIT = 10**18;

    enum NFTType{
        REWARD,
        CONTRIBUTOR
    }

    event MintRewardNFT(address _address);
    event MintContributorNFT(address _address);

    constructor(address _gatewayAddress) {
        require(
            msg.sender != _gatewayAddress,
            "Verification address can't be the sender's address"
        );
        GATEWAY_ADDRESS = _gatewayAddress;
    }

    /**
     * @notice Checks if a signature came from Gateway.
     *
     * @param _signature Gateway signature to validate the deployment
     * @param _nonce A nonce passed by Gateway for validating the deployment
     */
    function validateSignature(bytes memory _signature, string memory _nonce) public {
        // Verify if Gateway has given permissions for the minter
        bytes32 hash = keccak256(abi.encodePacked(_nonce));
        bytes32 messageHash = hash.toEthSignedMessageHash();

        // Verify that the message's signer is the owner of the order
        address signer = messageHash.recover(_signature);

        require(
            signer == GATEWAY_ADDRESS,
            "This message wasn't created by Gateway"
        );
        require(
            !seenNonces[_nonce],
            "This nonce was used on a previous deployment"
        );
        seenNonces[_nonce] = true;
    }

    /**
     * @notice Deploys a Reward NFT contract for a DAO
     *
     * @param _name The name of the NFT
     * @param _symbol The symbol of the NFT
     * @param _baseTokenURI The base token URI of the NFT
     * @param _daoAdmins The DAO admins that have permission to mint the NFT
     * @param _allowTransfers A boolean value to authorize/unauthorize NFT transferibility
     * @param _signature Gateway signature to validate the deployment
     * @param _nonce A nonce passed by Gateway for validating the deployment
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
    ) public returns (address) {
        require(_type == NFTType.CONTRIBUTOR || _type == NFTType.REWARD, "Must be a Reward or Contributor NFT");

        // Verify if Gateway has given permissions for the minter
        this.validateSignature(_signature, _nonce);

        IERC721 nft;

        // Deploy RewardNFT contract
        if (_type == NFTType.REWARD) {
            nft = new RewardNFT(
                _name,
                _symbol,
                _baseTokenURI,
                _daoAdmins,
                GATEWAY_ADDRESS,
                _allowTransfers
            );

            emit MintRewardNFT(address(nft));
        }
        else if (_type == NFTType.CONTRIBUTOR) {
            nft = new ContributorNFT(
                _name,
                _symbol,
                _baseTokenURI,
                _daoAdmins,
                GATEWAY_ADDRESS,
                _allowTransfers
            );

            emit MintContributorNFT(address(nft));
        }

        // Return the contract address, after deploying
        return address(nft);
    }

    /**
     * @notice Cleans nonce array
     * @dev Function only triggable by the owner of this contract.
     *
     * @param _nonce The nonce to clear
     */
    function clearNonce(string memory _nonce) public onlyOwner {
        require(seenNonces[_nonce], "This nonce is clear or not activated");

        // Clear the nonce
        seenNonces[_nonce] = false;
    }
}
