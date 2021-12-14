import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    const token = await hre.ethers.getContract("PageToken");
    const commentMinter = await hre.ethers.getContract("PageCommentMinter");
    await deploy("PageNFT", {
        from: deployer.address,
        args: [
            process.env.TREASURY_ADDRESS  || deployer.address,
            token.address,
            commentMinter.address
        ],
        log: true,
        deterministicDeployment: false,
    });
};
func.tags = ["PageNFT"];
func.dependencies = ["PageToken", "PageCommentMinter"];
export default func;
