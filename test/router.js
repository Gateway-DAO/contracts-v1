const { expect, should } = require("chai");
const { ethers } = require("hardhat");

const NFT = {
  name: "Gateway NFT",
  symbol: "GATENFT",
  baseTokenURI:
    "kjzl6cwe1jw147adql2y5p8zsw90m1q79rqvpozq6qn0cecpuxq048iuab8bmxh",
};

describe("Router", function () {
  describe("NFT Factories", function () {
    it("Should deploy a RewardNFTFactory contract", async function () {
      // 1. deploy factory
      const Factory = await ethers.getContractFactory("RewardNFTFactory");
      const factory = await Factory.deploy();
      await factory.deployed();

      expect(factory.address).to.be.properAddress;
    });

    it("Should deploy a ContributorNFTFactory contract", async function () {
      // 1. deploy factory
      const Factory = await ethers.getContractFactory("ContributorNFTFactory");
      const factory = await Factory.deploy();
      await factory.deployed();

      expect(factory.address).to.be.properAddress;
    });
  });

  describe("NFT Deployment", function () {
    it("Should deploy a RewardNFT contract", async function () {
      const [owner, addr1, addr2] = await ethers.getSigners();

      const gatewayAddress = await addr1.getAddress();

      // 1. deploy factories
      const RewardFactory = await ethers.getContractFactory("RewardNFTFactory");
      const factory1 = await RewardFactory.deploy();
      await factory1.deployed();

      const ContributorFactory = await ethers.getContractFactory(
        "ContributorNFTFactory"
      );
      const factory2 = await ContributorFactory.deploy();
      await factory2.deployed();

      // 2. deploy router
      const Router = await ethers.getContractFactory("Router");
      const router = await Router.deploy(
        gatewayAddress,
        factory1.address,
        factory2.address
      );
      await router.deployed();

      // 3. sign a message with a nonce
      let nonce = "54758568967";
      let messageHash = ethers.utils.solidityKeccak256(["string"], [nonce]);
      let sign = await addr1.signMessage(ethers.utils.arrayify(messageHash));

      // 4. call deployRewardNFT
      const deployTx = await router.deployNFT(
        NFT.name,
        NFT.symbol,
        NFT.baseTokenURI,
        [await owner.getAddress(), await addr2.getAddress()],
        true,
        sign,
        nonce,
        0
      );

      const contractReceipt = await deployTx.wait();

      const event = contractReceipt.events?.find(
        (event) => event.event === `MintRewardNFT`
      );

      const nftAddr = event?.args?.["_address"];

      expect(nftAddr).to.be.properAddress;
    });

    it("Should deploy a RewardNFT contract only once for the same nonce", async function () {
      const [owner, addr1, addr2] = await ethers.getSigners();

      const gatewayAddress = await addr1.getAddress();

      // 1. deploy factories
      const RewardFactory = await ethers.getContractFactory("RewardNFTFactory");
      const factory1 = await RewardFactory.deploy();
      await factory1.deployed();

      const ContributorFactory = await ethers.getContractFactory(
        "ContributorNFTFactory"
      );
      const factory2 = await ContributorFactory.deploy();
      await factory2.deployed();

      // 2. deploy router
      const Router = await ethers.getContractFactory("Router");
      const router = await Router.deploy(
        gatewayAddress,
        factory1.address,
        factory2.address
      );
      await router.deployed();

      // 3. sign a message with a nonce
      let nonce = "54758568967";
      let messageHash = ethers.utils.solidityKeccak256(["string"], [nonce]);
      let sign = await addr1.signMessage(ethers.utils.arrayify(messageHash));

      // 3. call deployRewardNFT
      const deployTx = await router.deployNFT(
        NFT.name,
        NFT.symbol,
        NFT.baseTokenURI,
        [await owner.getAddress(), await addr2.getAddress()],
        true,
        sign,
        nonce,
        0
      );

      await deployTx.wait();

      const deployTx2 = router.deployNFT(
        NFT.name,
        NFT.symbol,
        NFT.baseTokenURI,
        [await owner.getAddress(), await addr2.getAddress()],
        true,
        sign,
        nonce,
        0
      );

      await expect(deployTx2).to.be.revertedWith(
        "This nonce was used on a previous deployment"
      );
    });

    it("Should deploy a ContributorNFT contract", async function () {
      const [owner, addr1, addr2] = await ethers.getSigners();

      const gatewayAddress = await addr1.getAddress();

      // 1. deploy factories
      const RewardFactory = await ethers.getContractFactory("RewardNFTFactory");
      const factory1 = await RewardFactory.deploy();
      await factory1.deployed();

      const ContributorFactory = await ethers.getContractFactory(
        "ContributorNFTFactory"
      );
      const factory2 = await ContributorFactory.deploy();
      await factory2.deployed();

      // 2. deploy router
      const Router = await ethers.getContractFactory("Router");
      const router = await Router.deploy(
        gatewayAddress,
        factory1.address,
        factory2.address
      );
      await router.deployed();

      // 2. sign a message with a nonce
      let nonce = "54758568967";
      let messageHash = ethers.utils.solidityKeccak256(["string"], [nonce]);
      let sign = await addr1.signMessage(ethers.utils.arrayify(messageHash));

      // 3. call deployContributorNFT
      const deployTx = await router.deployNFT(
        NFT.name,
        NFT.symbol,
        NFT.baseTokenURI,
        [await owner.getAddress(), await addr2.getAddress()],
        true,
        sign,
        nonce,
        1
      );

      const contractReceipt = await deployTx.wait();

      const event = contractReceipt.events?.find(
        (event) => event.event === `MintContributorNFT`
      );

      const nftAddr = event?.args?.["_address"];

      expect(nftAddr).to.be.properAddress;
    });

    it("Should deploy a ContributorNFT contract only once for the same nonce", async function () {
      const [owner, addr1, addr2] = await ethers.getSigners();

      const gatewayAddress = await addr1.getAddress();

      // 1. deploy factories
      const RewardFactory = await ethers.getContractFactory("RewardNFTFactory");
      const factory1 = await RewardFactory.deploy();
      await factory1.deployed();

      const ContributorFactory = await ethers.getContractFactory(
        "ContributorNFTFactory"
      );
      const factory2 = await ContributorFactory.deploy();
      await factory2.deployed();

      // 2. deploy router
      const Router = await ethers.getContractFactory("Router");
      const router = await Router.deploy(
        gatewayAddress,
        factory1.address,
        factory2.address
      );
      await router.deployed();

      // 3. sign a message with a nonce
      let nonce = "54758568967";
      let messageHash = ethers.utils.solidityKeccak256(["string"], [nonce]);
      let sign = await addr1.signMessage(ethers.utils.arrayify(messageHash));

      // 3. call deployRewardNFT
      const deployTx = await router.deployNFT(
        NFT.name,
        NFT.symbol,
        NFT.baseTokenURI,
        [await owner.getAddress(), await addr2.getAddress()],
        true,
        sign,
        nonce,
        1
      );

      await deployTx.wait();

      const deployTx2 = router.deployNFT(
        NFT.name,
        NFT.symbol,
        NFT.baseTokenURI,
        [await owner.getAddress(), await addr2.getAddress()],
        true,
        sign,
        nonce,
        0
      );

      await expect(deployTx2).to.be.revertedWith(
        "This nonce was used on a previous deployment"
      );
    });
  });
});
