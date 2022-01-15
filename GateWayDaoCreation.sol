// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Dao.sol";

contract DAOCreation is Ownable, ReentrancyGuard, AccessControlEnumerable {

    using Counters for Counters.Counter;
    
    Counters.Counter private dao_counter;
    mapping(uint256 => DAO) private dao;

    constructor(){
         _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createDAO(address _erc20Address, string memory DAO_slug,  string memory name, string memory description, string memory website ) public{
        dao[dao_counter.current()] = new DAO(dao_counter.current(), _erc20Address, DAO_slug, name, description, website);
        dao_counter.increment();
    }
}
