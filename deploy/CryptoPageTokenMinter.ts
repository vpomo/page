// const { ethers } = require("ethers")

// await token.transferOwnership(tokenMinter.address);
/*
module.exports = async function ({ ethers, getNamedAccounts, deployments }) {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
    // const MINTER_ROLE = ethers.utils.id("MINTER_ROLE")
    // const BURNER_ROLE = ethers.utils.id("BURNER_ROLE")
    // const nftMinter = await ethers.getContract("PageNFTMinter")
    const token = await ethers.getContract("PageToken");
    const tokenMinter = await deploy("PageTokenMinter", {
        from: deployer,
        args: [token.address],
        log: true,
        deterministicDeployment: false,
    });
    await token.transferOwnership(tokenMinter.address)
};

module.exports.tags = ["PageTokenMinter"];
module.exports.dependencies = ["PageToken"];
*/
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    const token = await hre.ethers.getContract("PageToken");
    const tokenMinter = await deploy("PageTokenMinter", {
        from: deployer.address,
        args: [token.address],
        log: true,
        deterministicDeployment: false,
    });
    // await token.transferOwnership(tokenMinter.address);
};
func.tags = ["PageToken"];
func.dependencies = ["PageTokenMinter"];

export default func;
