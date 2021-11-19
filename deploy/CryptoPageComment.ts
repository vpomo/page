import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    await deploy("PageComment", {
        from: deployer.address,
        log: true,
        deterministicDeployment: false,
    });
};
func.tags = ["PageComment"];
export default func;
/*
module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    await deploy("PageComment", {
        from: deployer,
        log: true,
        deterministicDeployment: false,
    });
};

module.exports.tags = ["PageComment"];
*/
