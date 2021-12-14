import hre from "hardhat"
import "@nomiclabs/hardhat-ethers";
import { abi as FactoryABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";

const factoryAddress =
    process.env.FACTORY_ADDRESS || "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const tokenBAddress =
    process.env.TOKEN_B_ADDRESS || "0xc778417E063141139Fce010982780140Aa0cD5Ab";

const USDTAddress = process.env.USDT_ADDRESS || "0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02"
const WETHAddress = process.env.WETH_ADDRESS || tokenBAddress

export async function main() {
    const token = await hre.ethers.getContract("PageToken");
    const factory = await hre.ethers.getContractAt(FactoryABI, factoryAddress);
    const WETHUSDTpoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(WETHAddress),
        hre.ethers.utils.getAddress(USDTAddress),
        500
    );
    const USDTPAGEpoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(USDTAddress),
        hre.ethers.utils.getAddress(token.address),
        500
    );
    await token.setWETHUSDTPool(WETHUSDTpoolAddress)
    await token.setUSDTPAGEPool(USDTPAGEpoolAddress)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
