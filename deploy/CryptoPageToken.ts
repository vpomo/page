import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const treasuryAddress = process.env.TREASURY_ADDRESS;

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();
    const bankProxy = await hre.ethers.getContract("PageBank");

    await deploy("PageToken", {
        from: deployer,
        proxy: {
            proxyContract: "OpenZeppelinTransparentProxy",
            execute: {
                methodName: "initialize",
                args: [treasuryAddress, bankProxy.address],
            },
        },
        log: true,
    });
};

func.tags = ["PageToken"];
func.dependencies = ["PageBank"];
export default func;
