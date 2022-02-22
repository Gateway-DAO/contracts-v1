const hre = require("hardhat");
require('dotenv').config();

async function main() {
  // We deploy the Signature library first
  const Signature = await hre.ethers.getContractFactory("Signature");
  const signature = await Signature.deploy();

  await signature.deployed();

  // We get the contract to deploy
  const Router = await hre.ethers.getContractFactory("Router", {
    libraries: {
      Signature: signature.address
    }
  });
  const router = await Router.deploy(process.env.PRIVATE_KEY_GATEWAY);

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
