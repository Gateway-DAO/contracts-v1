// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Signature is Ownable {
    using ECDSA for bytes32;

    // Nonce-validation array, for guaranteeing the uniqueness of signatures and mitigate replay attacks.
    mapping(string => bool) private seenNonces;

    address internal SIGNER;

    /**
     * @notice Checks if a signature came from Gateway.
     *
     * @param _signature Gateway signature to validate the deployment
     * @param _nonce A nonce passed by Gateway for validating the deployment
     */
    function validateSignature(bytes memory _signature, string memory _nonce)
        internal
    {
        // Verify if Gateway has given permissions for the minter
        bytes32 hash = keccak256(abi.encodePacked(_nonce));
        bytes32 messageHash = hash.toEthSignedMessageHash();

        // Verify that the message's signer is the owner of the order
        address signer = messageHash.recover(_signature);

        require(
            signer == SIGNER,
            "This message wasn't created by Gateway"
        );
        require(
            !seenNonces[_nonce],
            "This nonce was used on a previous deployment"
        );
        seenNonces[_nonce] = true;
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