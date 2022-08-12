const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CredentialNFT", function() {
    it("Should deploy a CredentialNFT contract", async function() {
        const [owner, addr1, addr2] = await ethers.getSigners();
    
        const gatewayAddress = await addr1.getAddress();
        const BICONOMY_FORWARDER_RINKEBY = "0xFD4973FeB2031D4409fB57afEE5dF2051b171104";
    
        // 1. deploy contract
        const CredentialNFT = await ethers.getContractFactory("CredentialNFT");
        const contract = await CredentialNFT.deploy(BICONOMY_FORWARDER_RINKEBY);
        await contract.deployed();
    
        expect(contract.address).to.be.properAddress;
    });
});