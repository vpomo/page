import { abi as FactoryABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { abi as PoolABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const factoryAddress =
    process.env.FACTORY_ADDRESS || "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const tokenBAddress =
    process.env.TOKEN_B_ADDRESS || "0xc778417E063141139Fce010982780140Aa0cD5Ab";

const USDTAddress =
    process.env.USDT_ADDRESS || "0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02";
const WETHAddress = process.env.WETH_ADDRESS || tokenBAddress;

const nullAddress = "0x0000000000000000000000000000000000000000";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    await deploy("PageToken", {
        from: deployer.address,
        log: true,
        deterministicDeployment: false,
    });
    const token = await hre.ethers.getContract("PageToken");
    // await token.initialize(process.env.TREASURY_ADDRESS);
    const factory = await hre.ethers.getContractAt(FactoryABI, factoryAddress);
    const WETHUSDTPoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(WETHAddress),
        hre.ethers.utils.getAddress(USDTAddress),
        500
    );
    const USDTPAGEPoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(USDTAddress),
        hre.ethers.utils.getAddress(token.address),
        500
    );
    console.log("WETH / USDT Pool Address", WETHUSDTPoolAddress);
    console.log("USDT / PAGE Pool Address", USDTPAGEPoolAddress);
    const TokenWETHUSDTAddress = await token.wethusdtPool();
    const TokenUSDTPAGEAddress = await token.usdtpagePool();
    if (
        WETHUSDTPoolAddress !== nullAddress &&
        WETHUSDTPoolAddress !== TokenWETHUSDTAddress
    ) {
        await token.setWETHUSDTPool(
            hre.ethers.utils.getAddress(WETHUSDTPoolAddress)
        );
        console.log("token.wethusdtPool", await token.wethusdtPool());
        const WETHUSDTPrice = await token.getWETHUSDTPrice();
        console.log("WETH / USDT Price is ", WETHUSDTPrice.toString());
    }
    if (
        USDTPAGEPoolAddress !== nullAddress &&
        USDTPAGEPoolAddress !== TokenUSDTPAGEAddress
    ) {
        await token.setUSDTPAGEPool(
            hre.ethers.utils.getAddress(USDTPAGEPoolAddress)
        );
        console.log("token.usdtpagePool", await token.usdtpagePool());
        const USDTPAGEPrice = await token.getUSDTPAGEPrice();
        console.log("USDT / PAGE Price is ", USDTPAGEPrice.toString());
    }
};
func.tags = ["PageToken"];
export default func;
