const { expect, should } = require("chai");
const { ethers } = require("hardhat");

const NFT = {
  name: "Gateway NFT",
  symbol: "GATENFT",
  baseTokenURI:
    "kjzl6cwe1jw147adql2y5p8zsw90m1q79rqvpozq6qn0cecpuxq048iuab8bmxh",
};

describe("Router", function () {
  it("Should deploy a RewardNFT contract", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const gatewayAddress = await addr1.getAddress();

    // 1. deploy router
    const Router = await ethers.getContractFactory("Router");
    const router = await Router.deploy(gatewayAddress);
    await router.deployed();

    // 2. sign a message with a nonce
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

    const contractReceipt = await deployTx.wait();

    const event = contractReceipt.events?.find(
        (event) =>
            event.event ===
            `MintRewardNFT`
    );

    const nftAddr = event?.args?.['_address'];

    expect(nftAddr).to.be.properAddress;
  });

  it("Should deploy a RewardNFT contract only once for the same nonce", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const gatewayAddress = await addr1.getAddress();

    // 1. deploy router
    const Router = await ethers.getContractFactory("Router");
    const router = await Router.deploy(gatewayAddress);
    await router.deployed();

    // 2. sign a message with a nonce
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

    // 1. deploy router
    const Router = await ethers.getContractFactory("Router");
    const router = await Router.deploy(gatewayAddress);
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
        (event) =>
            event.event ===
            `MintContributorNFT`
    );

    const nftAddr = event?.args?.['_address'];

    expect(nftAddr).to.be.properAddress;
  });
});
