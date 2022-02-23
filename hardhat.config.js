require('dotenv').config();
require("@nomiclabs/hardhat-waffle");

const ALCHEMY_API_KEY = "EII64kuRZzGukRQBcZmAqwo-YTuPuzmj";
const RINKEBY_PRIVATE_KEY = "04fffa27ef01a038fb295bde2bea08988235936160468f5d11a94cb6b82ebcfe";

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
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },  
  paths: {
    artifacts: './src/artifacts'
  },
  networks: {
    hardhat: {
      chainId: +process.env.HARDHAT_CHAIN_ID || 1337,
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_API_KEY}`
      }
    },
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`${RINKEBY_PRIVATE_KEY}`]
    }
  }
  // defaultNetwork: "localMainNet",
  // networks: {
    // hardhat: {
      // chainId: +process.env.HARDHAT_CHAIN_ID || 1337,
      // chainId: 1331,
    // }, 
    // localhost: {
    //   forking: {
    //     url: 'https://eth-mainnet.alchemyapi.io/v2/EII64kuRZzGukRQBcZmAqwo-YTuPuzmj'
    //   }
    // }
    // 'localMainNet': {
    //   url: "https://eth-mainnet.alchemyapi.io/v2/EII64kuRZzGukRQBcZmAqwo-YTuPuzmj",
    //   hardfork: 'london'
    //   // forking: {
    //   //   url: "https://eth-mainnet.alchemyapi.io/v2/EII64kuRZzGukRQBcZmAqwo-YTuPuzmj",
    //   //   hardFork: 'london'
    //   // }
    // },
    // rinkeby: {
    //   url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
    //   accounts: [`${RINKEBY_PRIVATE_KEY}`]
    // }
  // },
  // etherscan: {
  //   apiKey: "ZUZCW39NGWDG2WNKRG5YPR8B3FIJ6MIY8X"
  // }
};

// Original
// module.exports = {
//   solidity: "0.8.4",
//   paths: {
//     artifacts: './src/artifacts'
//   },
//   networks: {
//     hardhat: {
//       chainId: +process.env.HARDHAT_CHAIN_ID || 1337
//     },
//   }
// };
