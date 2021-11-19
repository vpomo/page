import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    /*
    await deploy("PageComment", {
        from: deployer.address,
        log: true,
        deterministicDeployment: false,
    });
    */
    const MINTER_ROLE = hre.ethers.utils.id("MINTER_ROLE");
    const BURNER_ROLE = hre.ethers.utils.id("BURNER_ROLE");

    const token = await hre.ethers.getContract("PageToken");
    const nft = await hre.ethers.getContract("PageNFT");
    const tokenMinter = await hre.ethers.getContract("PageTokenMinter");
    const nftMinter = await hre.ethers.getContract("PageNFTMinter");

    await deploy("PageAdmin", {
        from: deployer.address,
        args: [deployer, tokenMinter.address, nftMinter.address],
        log: true,
        deterministicDeployment: false,
    });
    await token.transferOwnership(tokenMinter.address);
    await nft.transferOwnership(nftMinter.address);
    await tokenMinter.grantRole(MINTER_ROLE, nftMinter.address);
    await tokenMinter.grantRole(BURNER_ROLE, nftMinter.address);
};
func.tags = ["PageAdmin"];
func.dependencies = [
    "PageToken",
    "PageNFT",
    "PageTokenMinter",
    "PageNFTMinter",
];
export default func;

/*
module.exports = async function ({ ethers, getNamedAccounts, deployments }) {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    const MINTER_ROLE = ethers.utils.id("MINTER_ROLE");
    const BURNER_ROLE = ethers.utils.id("BURNER_ROLE");

    const token = await ethers.getContract("PageToken");
    const nft = await ethers.getContract("PageNFT");
    const tokenMinter = await ethers.getContract("PageTokenMinter");
    const nftMinter = await ethers.getContract("PageNFTMinter");

    await deploy("PageAdmin", {
        from: deployer,
        args: [deployer, tokenMinter.address, nftMinter.address],
        log: true,
        deterministicDeployment: false,
    });
    await token.transferOwnership(tokenMinter.address)
    await nft.transferOwnership(nftMinter.address)
    await tokenMinter.grantRole(MINTER_ROLE, nftMinter.address)
    await tokenMinter.grantRole(BURNER_ROLE, nftMinter.address)
};

module.exports.tags = ["PageAdmin"];
module.exports.dependencies = [
    "PageToken",
    "PageNFT",
    "PageTokenMinter",
    "PageNFTMinter",
];
*/
