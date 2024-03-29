require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
const { ethers } = require('ethers');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true
    },
    rinkeby: {
      allowUnlimitedContractSize: true,
      accounts: [process.env.PRIVATE_KEY_1],
      url: process.env.RINKEBY_URL,
      chainId: 4
    },
    goerli: {
      allowUnlimitedContractSize: true,
      accounts: [process.env.PRIVATE_KEY_1],
      url: process.env.GORLI_URL,
      chainId: 5
    },
    polygon: {
      allowUnlimitedContractSize: true,
      accounts: [process.env.PRIVATE_KEY_1],
      url: process.env.POLYGON_URL,
      chainId: 137,
      gasPrice: 35000000000,
      saveDeployments: true,
    }
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 88800
      }
    }
  }
};
