import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();

    // const MINTER_ROLE = hre.ethers.utils.id("MINTER_ROLE");
    // const BURNER_ROLE = hre.ethers.utils.id("BURNER_ROLE");

    const token = await hre.ethers.getContract("PageToken");
    const nft = await hre.ethers.getContract("PageNFT");

    await deploy("PageAdmin", {
        from: deployer.address,
        args: [deployer.address, token.address, nft.address],
        log: true,
        deterministicDeployment: false,
    });
    /*
    if (tokenOwner === deployer.address) {
        await token.transferOwnership(tokenMinter.address);
    }
    if (nftOwner === deployer.address) {
        await nft.transferOwnership(nftMinter.address);
    }
    if (tokenMinterOwner === deployer.address) {
        await tokenMinter.grantRole(MINTER_ROLE, nftMinter.address);
        await tokenMinter.grantRole(BURNER_ROLE, nftMinter.address);
    }
    */
};
func.tags = ["PageAdmin"];
func.dependencies = ["PageToken", "PageNFT"];
export default func;
