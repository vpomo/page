import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    const nft = await hre.ethers.getContract("PageNFT");
    const tokenMinter = await hre.ethers.getContract("PageTokenMinter");
    const commentMinter = await hre.ethers.getContract("PageCommentMinter");
    // treasury = _treasury;
    // tokenMinter = _tokenMinter;
    // commentMinter = _commentMinter;
    // nft = _nft;

    await deploy("PageNFTMinter", {
        from: deployer.address,
        args: [
            deployer.address,
            tokenMinter.address,
            commentMinter.address,
            nft.address,
        ],
        log: true,
        deterministicDeployment: false,
    });
};
func.tags = ["PageNFTMinter"];
func.dependencies = ["PageNFT", "PageTokenMinter", "PageCommentMinter"];
export default func;
/*
module.exports = async function ({ ethers, getNamedAccounts, deployments }) {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
    const nft = await ethers.getContract("PageNFT");
    console.log("nft", nft.address);
    const tokenMinter = await ethers.getContract("PageTokenMinter");
    console.log("tokenMinter", tokenMinter.address);
    const commentMinter = await ethers.getContract("PageCommentMinter");
    console.log("commentMinter", commentMinter.address);
    await deploy("PageNFTMinter", {
        from: deployer,
        args: [
            deployer,
            tokenMinter.address,
            nft.address,
            commentMinter.address,
        ],
        log: true,
        deterministicDeployment: false,
    });
};

module.exports.tags = ["PageNFTMinter"];
module.exports.dependencies = [
    "PageNFT",
    "PageTokenMinter",
    "PageCommentMinter",
];
*/
