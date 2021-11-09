import { task } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import { HardhatUserConfig } from 'hardhat/types';
import * as dotenv from "dotenv";
import "hardhat-watcher";


dotenv.config();


/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const config: HardhatUserConfig = {
  defaultNetwork: "rinkeby",
  watcher: {    
    compilation: {
      tasks: ["compile"],
      files: ["./contracts"],
      verbose: true
    }
  },
  solidity: {
    compilers: [{ version: "0.8.4", settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      }
    } }],
  },
  networks: {
    rinkeby: {
       url: `https://rinkeby.infura.io/v3/${process.env.RINKEBY_INFURA_KEY}`,
       accounts: [`${process.env.RINKEBY_DEPLOYER_PRIV_KEY}`],
    },
    ganache: {
      url: `http://127.0.0.1:8545`,
      accounts: ['0xc48cb9e0cf5a4e8c8e7427a8278f0cd7149b46eb9aad89aef1de88a46608fa85']
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  // mocha options can be set here
  mocha: {
    timeout: "300s",
  },
};
export default config;
