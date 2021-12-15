import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    /*
    const token = await hre.ethers.getContract("PageToken");
    await deploy("PageCommentMinter", {
        from: deployer.address,
        args: [
            process.env.TREASURY_ADDRESS || deployer.address,
            token.address
        ],
        log: true,
        deterministicDeployment: false,
    });
    */
};
func.tags = ["PageCommentMinter"];
func.dependencies = ["PageToken"];
export default func;
