// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//import "./DAO.sol";

contract DAOCreation is  ReentrancyGuard, AccessControlEnumerable {
/*
    using Counters for Counters.Counter;
    
    Counters.Counter private dao_counter;
    mapping(uint256 => DAO) private dao;

    constructor(){
         _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /*===================================

        VIEWS

    =====================================

     function getDAO(uint256 idx) external view returns(DAO){
        return dao[idx];
    }

     /*===================================

        Setters

    =====================================

    function createDAO(address _erc20Address, string memory DAO_slug,  string memory name, string memory description, string memory website, address[] memory DAO_Admins, address minterOperator) public{
        dao[dao_counter.current()] = new DAO(dao_counter.current(), _erc20Address, DAO_slug, DAO_Admins, minterOperator, name, description, website);
        dao_counter.increment();
    }

    */
}
