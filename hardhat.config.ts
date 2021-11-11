/**
 * @type import('hardhat/config').HardhatUserConfig
 */
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-solhint";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import * as dotenv from "dotenv";
import "hardhat-deploy";
import "hardhat-watcher";
import { HardhatUserConfig } from "hardhat/types";
import "solidity-coverage";

const MAINNET_RPC_URL =
    process.env.MAINNET_RPC_URL ||
    process.env.ALCHEMY_MAINNET_RPC_URL ||
    "https://eth-mainnet.alchemyapi.io/v2/your-api-key";
const RINKEBY_RPC_URL =
    process.env.RINKEBY_RPC_URL ||
    "https://eth-rinkeby.alchemyapi.io/v2/your-api-key";
const KOVAN_RPC_URL =
    process.env.KOVAN_RPC_URL ||
    "https://eth-kovan.alchemyapi.io/v2/your-api-key";
const MNEMONIC = process.env.MNEMONIC || "your mnemonic";
const ETHERSCAN_API_KEY =
    process.env.ETHERSCAN_API_KEY || "Your etherscan API key";
// optional
const PRIVATE_KEY = process.env.PRIVATE_KEY || "your private key";
const PINATA_API_KEY = process.env.PINATA_API_KEY;
const PINATA_API_SECRET = process.env.PINATA_API_SECRET;
// url: `https://rinkeby.infura.io/v3/${process.env.RINKEBY_INFURA_KEY}`,

dotenv.config();

const config: HardhatUserConfig = {
    defaultNetwork: "ganache",
    watcher: {
        compilation: {
            tasks: ["compile"],
            files: ["./contracts"],
            verbose: true,
        },
    },
    solidity: {
        compilers: [
            {
                version: "0.8.4",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    networks: {
        rinkeby: {
            url: RINKEBY_RPC_URL,
            accounts: { mnemonic: MNEMONIC },
            // saveDeployments: true,
        },
        ganache: {
            url: "http://127.0.0.1:7545",
            accounts: { mnemonic: MNEMONIC },
            saveDeployments: true,
        },
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
    },
    mocha: {
        timeout: 100000,
    },
    typechain: {
        outDir: 'typechain-types',
        target: 'ethers-v5',
        alwaysGenerateOverloads: false, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
        // externalArtifacts: ['externalArtifacts/*.json'], // optional array of glob patterns with external artifacts to process (for example external libs from node_modules)
      },
};
export default config;
