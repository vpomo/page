import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    await deploy("PageCommentMinter", {
        from: deployer.address,
        log: true,
        deterministicDeployment: false,
    });
};
func.tags = ["PageCommentMinter"];
export default func;
/*
module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    await deploy("PageCommentMinter", {
        from: deployer,
        log: true,
        deterministicDeployment: false,
    });
};

module.exports.tags = ["PageCommentMinter"];
*/
