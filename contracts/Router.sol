// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

// NFT Types
import {RewardNFT} from "./RewardNFT.sol";
import {ContributorNFT} from "./ContributorNFT.sol";

import {Signature} from "./Signature.sol";

contract Router is Ownable, ReentrancyGuard, AccessControlEnumerable {
    // SafeMath
    using SafeMath for uint256;

    // Gateway verification address
    address private GATEWAY_ADDRESS;

    // Nonce-validation array, for guaranteeing the uniqueness of signatures and mitigate replay attacks.
    mapping(string => bool) private seenNonces;

    // Wei to ETH conversion
    uint256 private immutable UNIT = 10**18;

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
     * @param _v Recovery ID of the signature
     * @param _r Output from the ECDSA signature
     * @param _s Output from the ECDSA signature
     * @param _nonce A nonce passed by Gateway for validating the deployment
     */
    function validateSignature(
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        string memory _nonce
    ) public {
        // Verify if Gateway has given permissions for the minter
        bytes32 messageHash = Signature.hashMessage(_nonce);
        bytes32 signedMessageHash = Signature.hashSignedMessage(messageHash);
        require(
            Signature.verifyMessageAuthenticity(
                signedMessageHash,
                GATEWAY_ADDRESS,
                _v,
                _r,
                _s
            ),
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
     * @param _v Recovery ID of the signature
     * @param _r Output from the ECDSA signature
     * @param _s Output from the ECDSA signature
     * @param _nonce A nonce passed by Gateway for validating the deployment
     */
    function deployRewardNFT(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        address[] memory _daoAdmins,
        bool _allowTransfers,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        string memory _nonce
    ) public returns (address) {
        // Verify if Gateway has given permissions for the minter
        this.validateSignature(_v, _r, _s, _nonce);

        // Deploy RewardNFT contract
        RewardNFT nft = new RewardNFT(
            _name,
            _symbol,
            _baseTokenURI,
            _daoAdmins,
            GATEWAY_ADDRESS,
            _allowTransfers
        );

        // Return the contract address, after deploying
        return address(nft);
    }

    /**
     * @notice Deploys a Contributor NFT contract for a DAO
     *
     * @param _name The name of the NFT
     * @param _symbol The symbol of the NFT
     * @param _baseTokenURI The base token URI of the NFT
     * @param _daoAdmins The DAO admins that have permission to mint the NFT
     * @param _allowTransfers A boolean value to authorize/unauthorize NFT transferibility
     * @param _v Recovery ID of the signature
     * @param _r Output from the ECDSA signature
     * @param _s Output from the ECDSA signature
     * @param _nonce A nonce passed by Gateway for validating the deployment
     */
    function deployContributorNFT(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        address[] memory _daoAdmins,
        bool _allowTransfers,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        string memory _nonce
    ) public returns (address) {
        // Verify if Gateway has given permissions for the minter
        this.validateSignature(_v, _r, _s, _nonce);

        // Deploy ContributorNFT contract
        ContributorNFT nft = new ContributorNFT(
            _name,
            _symbol,
            _baseTokenURI,
            _daoAdmins,
            GATEWAY_ADDRESS,
            _allowTransfers
        );

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
        require(
            seenNonces[_nonce],
            "This nonce is clear or not activated"
        );

        // Clear the nonce
        seenNonces[_nonce] = false;
    }
}
