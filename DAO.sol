// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./NFTMember.sol";

contract DAO is Ownable, ReentrancyGuard, AccessControlEnumerable {
    
    //SafeMath
    using SafeMath for uint256;

     //description
    uint256 public id;
    string public gateway_id;
    string public DAO_slug;
    string public name;
    string  public description;
    string public website;
    address public organization_erc20;

    NFTMember public nft;
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    mapping(uint8 => bytes32) public all_roles;
 
    //wei to eth unit
    uint256 immutable private UNIT = 10 ** 18;

    modifier _onlyAdmin(){
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "DAO: Must have admin role");
        _;
    }
    
    constructor(uint256 _id, address _erc20Address, string memory _DAO_slug, string memory _name, string memory _description, string memory _website){
        
        id = _id;
        DAO_slug = _DAO_slug;
        organization_erc20 = _erc20Address;
        description = _description;
        website = _website;
        name = _name;

        nft = new NFTMember(_name, _DAO_slug, "", address(this));

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    
    }

    function set_DAO_slug(string memory _DAO_slug) public _onlyAdmin{
        DAO_slug = _DAO_slug;
    }


     /**
     * @dev Add Roler
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `DEFAULT_ADMIN_ROLE`.
     */
    function addRoleUser(bytes32 _role, address user) public virtual _onlyAdmin{
        _setupRole(_role, user);
    }


     function batchMintMembers(address[] calldata to, string[] memory _tokenURIS) public {
         uint8 i = 0;
         while( i < to.length){
              nft.mint(to[i], _tokenURIS[i]);
              i++;
         }
    }

    function mintMember(address to, string memory _tokenURI) public{
            nft.mint(to, _tokenURI);
    }
    
}

