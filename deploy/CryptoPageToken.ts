import { abi as FactoryABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const factoryAddress =
    process.env.FACTORY_ADDRESS || "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const tokenBAddress =
    process.env.TOKEN_B_ADDRESS || "0xc778417E063141139Fce010982780140Aa0cD5Ab";

const USDTAddress =
    process.env.USDT_ADDRESS || "0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02";
const WETHAddress = process.env.WETH_ADDRESS || tokenBAddress;

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    console.log("WETHAddress", WETHAddress);
    console.log("USDTAddress", USDTAddress);
    const token = await hre.ethers.getContract("PageToken");
    console.log("PAGEAddress", token.address);
    const WETHUSDTPrice = await token.getWETHUSDTPrice();
    const USDTPAGEPrice = await token.getUSDTPAGEPrice();
    console.log("WETHUSDTPrice", WETHUSDTPrice.toString());
    console.log("USDTPAGEPrice", USDTPAGEPrice.toString());
    

    /*    
    await deploy("PageToken", {
        from: deployer.address,
        args: [process.env.TREASURY_ADDRESS || deployer.address],
        log: true,
        deterministicDeployment: false,
    });
    */
    const factory = await hre.ethers.getContractAt(FactoryABI, factoryAddress);

    const WETHUSDTpoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(WETHAddress),
        hre.ethers.utils.getAddress(USDTAddress),
        500
    );

    console.log("WETHUSDTpoolAddress", WETHUSDTpoolAddress);

    if (
        WETHUSDTpoolAddress !== "0x0000000000000000000000000000000000000000" &&
        WETHUSDTpoolAddress.toNumber() == 0
    ) {
        await token.setWETHUSDTPool(WETHUSDTpoolAddress);
    }

    const USDTPAGEpoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(USDTAddress),
        hre.ethers.utils.getAddress(token.address),
        500
    );

    console.log("USDTPAGEpoolAddress", USDTPAGEpoolAddress);

    if (
        USDTPAGEpoolAddress !== "0x0000000000000000000000000000000000000000" &&
        USDTPAGEPrice.toNumber() !== 100
    ) {
        await token.setUSDTPAGEPool(USDTPAGEpoolAddress);
    }

    // const WETHUSDTPrice = await token.getWETHUSDTPrice();
    // const USDTPAGEPrice = await token.getUSDTPAGEPrice();
    /*
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
    */
};
func.tags = ["PageToken"];
export default func;
