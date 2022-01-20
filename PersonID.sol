// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./NFTMember.sol";

contract PersonId is Ownable, ReentrancyGuard, AccessControlEnumerable, Pausable {
    
    //SafeMath
    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _personTracker;

    struct Person{
        address wallet;
        string gateway_id;
        string name;
        string log;
        address[] associated_addresses; 
    }

    mapping(address => Person) public person;
    mapping(address => mapping(address => bool)) public approve_association_by;
    mapping(address =>uint256) public creationDate;
 
    modifier _onlyAdmin(){
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "DAO: Must have admin role");
        _;
    }

  /*   modifier _onlyPerson(uint256 _personId){
         require(msg.sender == person[_personId].wallet, "GatewayV1: ");
        _;
    }*/
    
    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    
    }

    function setName(address _personId, string memory _name) public{
        person[_personId].name = _name;
    }

     function setLogs(address _personId, string memory _log) public{
        person[_personId].log = _log;
    }

    function getLogs(address _personId) external view returns(string memory){
        return person[_personId].log;
    }

  /*  function setApprovedforAssociation(address addr){
        require(person[_msgSender] == address(0), "");
        approve_association_by[msg.sender][addr] = true;
    }

    function addWalletAssociated(address _personId, address addr) external _onlyPerson(_personId) {
        require(person[_personId].associated_addresses.length < 8, "");
        address[] storage n = person[_personId].associated_addresses;
        n.push(addr);
        person[_personId].associated_addresses = n;
         
    }

    function getWalletAssociated(uint256 idx) external view  {
           person[_personId].associated_addresses[idx];
    }*/




    function personCreation(string memory _gatewayId, string memory _name, string memory _logs) external whenNotPaused {
        require(creationDate[msg.sender] == 0, "Person identification already created");
        address[] memory n;
        person[msg.sender] = Person( msg.sender, _gatewayId, _name, _logs, n);
        _personTracker.increment();
    }

    
}


