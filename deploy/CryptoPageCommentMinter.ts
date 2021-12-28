import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    const token = await hre.ethers.getContract("PageToken");
    await deploy("PageCommentMinter", {
        from: deployer.address,
        log: true,
        deterministicDeployment: false,
        gasPrice: hre.ethers.utils.parseUnits("50", "gwei"),
        gasLimit: 3000000,//1732671 gas
    });
    const commentMinter = await hre.ethers.getContract("PageCommentMinter");
    await commentMinter.initialize(process.env.TREASURY_ADDRESS, token.address);
};
func.tags = ["PageCommentMinter"];
func.dependencies = ["PageToken"];
export default func;
