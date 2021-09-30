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
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  // mocha options can be set here
  mocha: {
    // timeout: "300s",
  },
};
export default config;
