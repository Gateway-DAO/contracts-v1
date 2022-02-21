// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Signature {
    /**
     * @notice Hashes the message with keccak256
     *
     * @param _message The message passed by the backend as a string
     */
    function hashMessage(string memory _message) public pure returns (bytes32) {
        bytes32 encoded = keccak256(abi.encodePacked(_message));
        return encoded;
    }
    
    /**
     * @notice Hashes the hashed message, but as a signed message
     * @param _hash The message hash
     */
    function hashSignedMessage(bytes32 _hash) public pure returns (bytes32) {
        bytes32 encoded = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
        return encoded;
    }

    /**
     * @notice Verifies if the provided message was created by Gateway
     *
     * @param _messageHash The hash of the message
     * @param _signer The signer of the message
     * @param _v Recovery ID of the signature
     * @param _r Output from the ECDSA signature
     * @param _s Output from the ECDSA signature
     */
    function verifyMessageAuthenticity(bytes32 _messageHash, address _signer, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (bool) {
        require(_signer != address(0), "The verification address is empty");
        address recovered = ecrecover(_messageHash, _v, _r, _s);
        return _signer == recovered;
    }
}