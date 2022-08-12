//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

contract CredentialNFT is ERC721URIStorage, ERC2771Context, Pausable, Ownable {
    using Counters for Counters.Counter;

    mapping(string => bool) userMetaDataURIMinted;

    event MintedNFT(uint256 indexed tokenId, address indexed holder, string uri);
    event BurnedNFT(uint256 indexed tokenId);

    Counters.Counter private tokenIdTracker;

    constructor(address _trustedForwarder) ERC721("Credential NFT", "GNFT") ERC2771Context(_trustedForwarder) {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev A method to mint NFT
     * 		Same NFT Mint is allowed only once for the same user.
     * @param to : Address to be minted
     * 		_tokenURI: metadataURI for NFT
     */
    function mint(address to, string memory _tokenURI) external whenNotPaused virtual {
        require(
            userMetaDataURIMinted[_tokenURI] == false,
            "CredentialNFT: you're not allowed to mint a credential more than once."
        );
        tokenIdTracker.increment();
        _mint(to, tokenIdTracker.current());
        _setTokenURI(tokenIdTracker.current(), _tokenURI);
        userMetaDataURIMinted[_tokenURI] = true;
        emit MintedNFT(tokenIdTracker.current(), to, _tokenURI);
    }

    /**
     * @dev A method to burn NFT by holder of NFT
     * @param _tokenId: NFT Id to be burned
     */
    function burn(uint256 _tokenId) public {
        require(_exists(_tokenId), "CredentialNFT: Requested to burn for non-existent token");
        _burn(_tokenId);
        tokenIdTracker.decrement();
        emit BurnedNFT(_tokenId);
    }

    /**
     * @dev Override to make non-transferable for NFT
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721) {
        require(
            from == address(0) || to == address(0),
            "NonTransferrableERC721Token: non transferrable"
        );
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Overrided from Context, ERC2771Context
     */
    function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            /// @solidity memory-safe-assembly
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    /**
     * @dev Overrided from Context, ERC2771Context
     */
    function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
}
