const hre = require("hardhat");
require('dotenv').config();

async function main() {
  // We get the contract to deploy
  const Router = await hre.ethers.getContractFactory("Router");
  const router = await Router.deploy("0xA8402235B16325B3CD94764246fa289f8d7a0Ed0");

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
