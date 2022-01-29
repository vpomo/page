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
import "hardhat-deploy-ethers";
import "hardhat-spdx-license-identifier";
import "hardhat-watcher";
import { HardhatUserConfig } from "hardhat/types";
import "solidity-coverage";

dotenv.config();

const defaultNetwork: string = process.env.NETWORK || "hardhat";
const mnemonic = process.env.MNEMONIC || "your mnemonic";

const infuraAPIKey = process.env.RINKEBY_INFURA_KEY || "your Infura API Key";
const infuraAPISecret = process.env.INFURA_API_KEY;
// optional
const privateKEY = process.env.RINKEBY_DEPLOYER_PRIV_KEY || "";
const pinataAPIKEY = process.env.PINATA_API_KEY;
const pinateAPISecret = process.env.PINATA_API_SECRET;

// networks RPC URLs
const mainnetRPCURL =
    process.env.MAINNET_RPC_URL ||
    `https://mainnet.infura.io/v3/${infuraAPIKey}`;
const rinkebyRPCURL =
    process.env.RINKEBY_RPC_URL ||
    `https://rinkeby.infura.io/v3/${infuraAPIKey}`;
const bscTestnetRPCURL =
    process.env.BSC_TESTNET_RPC_URL ||
    `https://data-seed-prebsc-1-s1.binance.org:8545`;

const kovanRPCURL =
    process.env.KOVAN_RPC_URL || `https://kovan.infura.io/v3/${infuraAPIKey}`;
const etherscanAPIKEY =
    process.env.ETHERSCAN_API_KEY || "TQDPK4XAU4BZT8WQNN6IETRRXXDI37W64Y";
const alchemyMainnetRPCURL = process.env.ALCHEMY_MAINNET_RPC_URL || "";

const config: HardhatUserConfig = {
    defaultNetwork,
    namedAccounts: {
        deployer: {
            default: 0,
        },
        dev: {
            default: 1,
        },
    },
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
                version: "0.8.0",
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
        hardhat: {
            // forking: {
            //     url: 'https://eth-rinkeby.alchemyapi.io/v2/90cSMyQK85W8_-e_7k7te9DycD_v1zEb'
            // }
        },
        ganache: {
            url: "http://127.0.0.1:7545",
            accounts: { mnemonic },
        },
        rinkeby: {
            url: rinkebyRPCURL,
            accounts: { mnemonic },
        },
        kovan: {
            url: kovanRPCURL,
            accounts: { mnemonic },
        },
        bscTestnet: {
            url: bscTestnetRPCURL,
            accounts: { mnemonic },
        },
        mainnet: {
            url: mainnetRPCURL,
            accounts: { mnemonic },
            gasPrice: 555000000000,
        },
    },
    etherscan: {
        apiKey: etherscanAPIKEY,
    },
    mocha: {
        timeout: 100000,
    },
    spdxLicenseIdentifier: {
        overwrite: true,
        runOnCompile: true,
    },
    typechain: {
        outDir: "types",
        target: "ethers-v5",
        alwaysGenerateOverloads: false,
    },
};
export default config;
