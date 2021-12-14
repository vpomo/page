import { abi as FactoryABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { abi as PoolABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    await deploy("PageToken", {
        from: deployer.address,
        args: [process.env.TREASURY_ADDRESS || deployer.address],
        log: true,
        deterministicDeployment: false,
    });
};
func.tags = ["PageToken"];
export default func;
