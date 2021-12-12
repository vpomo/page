import { abi as FactoryABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
const factoryAddress =
    process.env.FACTORY_ADDRESS || "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const tokenBAddress =
    process.env.TOKEN_B_ADDRESS || "0xc778417E063141139Fce010982780140Aa0cD5Ab";
const poolFee = process.env.POOL_FEE || 3000;
const poolInitializePrice = process.env.POOL_INITIALIZE_PRICE || 10 ** 20;

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    await deploy("PageToken", {
        from: deployer.address,
        args: [deployer.address],
        log: true,
        deterministicDeployment: false,
    });
    const token = await hre.ethers.getContract("PageToken");
    const factory = await hre.ethers.getContractAt(FactoryABI, factoryAddress);
    const poolAddress = await factory.getPool(
        token.address,
        tokenBAddress,
        poolFee
    );
    await token.setPool(poolAddress);
};
func.tags = ["PageToken"];
export default func;
