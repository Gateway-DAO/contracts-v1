const hre = require("hardhat");
require("dotenv").config();

const BICONOMY = {
  polygon: "0x86C80a8aa58e0A4fa09A69624c31Ab2a6CAD56b8",
  goerli: "0xE041608922d06a4F26C0d4c27d8bCD01daf1f792",
  rinkeby: "0xFD4973FeB2031D4409fB57afEE5dF2051b171104"
}

async function main() {
  // Deploy Router
  console.log(BICONOMY[hre.network.name]);

  const CredentialNFT = await hre.ethers.getContractFactory("CredentialNFT");
  const nft = await CredentialNFT.deploy(
    BICONOMY[hre.network.name],
  );

  await nft.deployed();

  console.log(`CredentialNFT deployed to ${nft.address} on "${hre.network.name}"`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
