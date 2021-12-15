import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    const token = await hre.ethers.getContract("PageToken");
    const commentMinter = await hre.ethers.getContract("PageCommentMinter");
    await deploy("PageNFT", {
        from: deployer.address,
        args: [
            process.env.TREASURY_ADDRESS  || deployer.address,
            token.address,
            commentMinter.address
        ],
        log: true,
        deterministicDeployment: false,
    });

    const nft = await hre.ethers.getContract("PageNFT")
  
    const MINTER_ROLE = hre.ethers.utils.id("MINTER_ROLE");
    const BURNER_ROLE = hre.ethers.utils.id("BURNER_ROLE");

    if (!(await token.hasRole(MINTER_ROLE, commentMinter.address))) {
        await token.grantRole(MINTER_ROLE, commentMinter.address);
    }
    if (!(await token.hasRole(MINTER_ROLE, nft.address))) {
        await token.grantRole(MINTER_ROLE, nft.address);
    }
    if (!(await token.hasRole(BURNER_ROLE, nft.address))) {
        await token.grantRole(BURNER_ROLE, nft.address);
    }
};
func.tags = ["PageNFT"];
func.dependencies = ["PageToken", "PageCommentMinter"];
export default func;
