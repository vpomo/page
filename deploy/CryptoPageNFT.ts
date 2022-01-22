import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const treasuryAddress = process.env.TREASURY_ADDRESS;

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();
    const commentProxy = await hre.ethers.getContract("PageComment");
    const bankProxy = await hre.ethers.getContract("PageBank");

    await deploy("PageNFT", {
        from: deployer,
        proxy: {
            proxyContract: "OpenZeppelinTransparentProxy",
            execute: {
                methodName: "initialize",
                args: [
                    commentProxy.address,
                    bankProxy.address,
                    "https://ipfs.io/ipfs/",
                ],
            },
        },
        log: true,
    });
};

func.tags = ["PageNFT"];
func.dependencies = ["PageBank", "PageComment"];
export default func;
