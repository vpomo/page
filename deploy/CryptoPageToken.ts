import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    const token = await deploy("PageToken", {
        from: deployer.address,
        log: true,
        deterministicDeployment: false,
    });
};
func.tags = ["PageToken"];
export default func;
/*
module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    const token = await deploy("PageToken", {
        from: deployer,
        log: true,
        deterministicDeployment: false,
    });
};

module.exports.tags = ["PageToken"];
*/
