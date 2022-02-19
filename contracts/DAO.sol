// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/access/AccessControlEnumerable.sol";
import {RewardNFT} from "./RewardNFT.sol";
import {ContributorNFT} from "./ContributorNFT.sol";

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

    RewardNFT public nft;
    ContributorNFT public contributorNFT;
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint8 => bytes32) public all_roles;
 
    //wei to eth unit
    uint256 immutable private UNIT = 10 ** 18;

    modifier _onlyAdmin(){
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "DAO: Must have admin role");
        _;
    }
    
    constructor(uint256 _id, address _erc20Address, string memory _DAO_slug, address[] memory DAO_Admins, address minterOperator, string memory _name, string memory _description, string memory _website){
        require(DAO_Admins.length > 0, "DAO: Admins must be at least one");
        id = _id;
        DAO_slug = _DAO_slug;
        organization_erc20 = _erc20Address;
        description = _description;
        website = _website;
        name = _name;

        nft = new RewardNFT(_name, _DAO_slug,"", DAO_Admins, minterOperator, false);
        contributorNFT = new ContributorNFT(_name, _DAO_slug,"", DAO_Admins, minterOperator, false);

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    
    }

    function set_DAO_slug(string memory _DAO_slug) public _onlyAdmin{
        DAO_slug = _DAO_slug;
    }

}

