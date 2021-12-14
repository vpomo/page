import hre from "hardhat"
import "@nomiclabs/hardhat-ethers";

export async function main() {
    const token = await hre.ethers.getContract("PageToken");
    const nft = await hre.ethers.getContract("PageNFT")
    const commentMinter = await hre.ethers.getContract("PageCommentMinter");
  
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
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

