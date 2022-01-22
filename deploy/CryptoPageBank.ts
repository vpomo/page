import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const treasuryAddress = process.env.TREASURY_ADDRESS;
const treasuryFee = process.env.TREASURY_FEE || 1000;

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();

    await deploy("PageBank", {
        from: deployer,
        proxy: {
            proxyContract: "OpenZeppelinTransparentProxy",
            execute: {
                methodName: "initialize",
                args: [treasuryAddress, treasuryFee],
            },
        },
        log: true,
    });
};

func.tags = ["PageBank"];
func.dependencies = [];
export default func;
