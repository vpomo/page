import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const treasuryAddress = process.env.TREASURY_ADDRESS;

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();
    // const bankProxy = await hre.ethers.getContract("PageBank")

    await deploy("PageComment", {
        from: deployer,
        proxy: {
            proxyContract: "OpenZeppelinTransparentProxy",
            execute: {
                methodName: "initialize",
                args: [treasuryAddress],
            },
        },
        log: true,
    });
};

func.tags = ["PageComment"];
func.dependencies = [];
export default func;
