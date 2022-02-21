// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/access/AccessControlEnumerable.sol";

// NFT Types
import {RewardNFT} from "./RewardNFT.sol";
import {ContributorNFT} from "./ContributorNFT.sol";

contract Router is Ownable, ReentrancyGuard, AccessControlEnumerable {
    // SafeMath
    using SafeMath for uint256;
    
    // Gateway verification address
    address private GATEWAY_ADDRESS;

    // Nonce-validation array, for guaranteeing the uniqueness of signatures and mitigate replay attacks.
    mapping(string => bool) private seenNonces;
 
    // Wei to ETH conversion
    uint256 immutable private UNIT = 10 ** 18;

    /**
     * @notice Hashes the message with keccak256
     *
     * @param _message The message passed by the backend as a string
     */
    function hashMessage(string memory _message) public view returns (bytes32) {
        bytes32 encoded = keccak256(abi.encodePacked(_message));
        return encoded;
    }
    
    /**
     * @notice Hashes the hashed message, but as a signed message
     * @param _hash The message hash
     */
    function hashSignedMessage(bytes32 _hash) public view returns (bytes32) {
        bytes32 encoded = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
        return encoded;
    }

    /**
     * @notice Verifies if the provided message was created by Gateway
     *
     * @param _MmessageHash The hash of the message
     * @param _v Recovery ID of the signature
     * @param _r Output from the ECDSA signature
     * @param _s Output from the ECDSA signature
     */
    function verifyMessageAuthenticity(bytes32 _messageHash, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (bool) {
        require(GATEWAY_ADDRESS == address(0), "ROUTER: The verification address is empty");
        address recovered = ecrecover(_messageHash, _v, _r, _s);
        return GATEWAY_ADDRESS == recovered;
    }
    
    constructor(address _gatewayAddress) {
        require(msg.sender != _gatewayAddress, "ROUTER: Verification address can't be the sender's address");
        GATEWAY_ADDRESS = _gatewayAddress;
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
    function deployContributorNFT(string memory _name, string memory _symbol,
        string memory _baseTokenURI, address[] memory _daoAdmins, bool _allowTransfers, uint8 _v, bytes32 _r, bytes32 _s, string memory _nonce) public returns (address) {
        // Verify if Gateway has given permissions for the minter
        bytes32 messageHash = this.hashMessage(_nonce);
        bytes32 signedMessageHash = this.hashSignedMessage(messageHash);
        require(this.verifyMessageAuthenticity(signedMessageHash, _v, _r, _s, SIGNING_ADDRESS), "ROUTER: This message wasn't created by Gateway");
        require(!seenNonces[_nonce], "ROUTER: This nonce was used on a previous deployment");
        seenNonces[_nonce] = true;

        // Deploy ContributorNFT contract
        ContributorNFT nft = ContributorNFT(_name, _symbol, _baseTokenURI, _daoAdmins, GATEWAY_ADDRESS, _allowTransfers);

        // Return the contract address, after deploying
        return address(nft);
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
    function deployRewardNFT(string memory _name, string memory _symbol,
        string memory _baseTokenURI, address[] memory _daoAdmins, bool _allowTransfers, uint8 _v, bytes32 _r, bytes32 _s, string memory _nonce) public returns (address) {
        // Verify if Gateway has given permissions for the minter
        bytes32 messageHash = this.hashMessage(_nonce);
        bytes32 signedMessageHash = this.hashSignedMessage(messageHash);
        require(this.verifyMessageAuthenticity(signedMessageHash, _v, _r, _s, SIGNING_ADDRESS), "ROUTER: This message wasn't created by Gateway");
        require(!seenNonces[_nonce], "ROUTER: This nonce was used on a previous deployment");
        seenNonces[_nonce] = true;

        // Deploy RewardNFT contract
        RewardNFT nft = RewardNFT(_name, _symbol, _baseTokenURI, _daoAdmins, GATEWAY_ADDRESS, _allowTransfers);

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
        require(seenNonces[_nonce], "ROUTER: This nonce is clear or not activated");

        // Clear the nonce
        seenNonces[_nonce] = false;
    }
}

