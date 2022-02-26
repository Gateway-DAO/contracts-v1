const hre = require("hardhat");
require("dotenv").config();

async function main() {
  // Deploy RewardNFTFactory
  const RewardFactory = await hre.ethers.getContractFactory("RewardNFTFactory");
  const factory1 = await RewardFactory.deploy();
  await factory1.deployed();

  // Deploy ContributorNFTFactory
  const ContributorFactory = await hre.ethers.getContractFactory(
    "ContributorNFTFactory"
  );
  const factory2 = await ContributorFactory.deploy();
  await factory2.deployed();

  // Deploy Router
  const Router = await hre.ethers.getContractFactory("Router");
  const router = await Router.deploy(
    "0xA8402235B16325B3CD94764246fa289f8d7a0Ed0",
    factory1.address,
    factory2.address
  );

  await router.deployed();

  console.log("Router deployed to:", router.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
