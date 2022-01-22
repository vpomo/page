import { abi as FACTORY_ABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const factoryAddress =
    process.env.FACTORY_ADDRESS || "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const USDTAddress =
    process.env.USDT_ADDRESS || "0x3B00Ef435fA4FcFF5C209a37d1f3dcff37c705aD";
const WETHAddress =
    process.env.WETH_ADDRESS || "0xc778417E063141139Fce010982780140Aa0cD5Ab";
const nullAddress = "0x0000000000000000000000000000000000000000";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const bankProxy = await hre.ethers.getContract("PageBank");
    const tokenProxy = await hre.ethers.getContract("PageToken");
    const commentProxy = await hre.ethers.getContract("PageComment");
    const nftProxy = await hre.ethers.getContract("PageNFT");

    console.log();

    const MINTER_ROLE = hre.ethers.utils.id("MINTER_ROLE");
    const BURNER_ROLE = hre.ethers.utils.id("BURNER_ROLE");

    /*
     * Grant MINTER_ROLE for CryptoPageNFT
     */
    if (!(await bankProxy.hasRole(MINTER_ROLE, nftProxy.address))) {
        await bankProxy.grantRole(MINTER_ROLE, nftProxy.address, {
            gasPrice: hre.ethers.utils.parseUnits("1", "gwei"),
            gasLimit: 2500000,
        });
        console.log("Grant MINTER ROLE For CryptoPageNFT", nftProxy.address);
    }

    /*
     * Grant BURNER_ROLE for CryptoPageNFT
     */
    if (!(await bankProxy.hasRole(BURNER_ROLE, nftProxy.address))) {
        await bankProxy.grantRole(BURNER_ROLE, nftProxy.address, {
            gasPrice: hre.ethers.utils.parseUnits("1", "gwei"),
            gasLimit: 2500000,
        });
        console.log("Grant BURNER_ROLE For CryptoPageNFT", nftProxy.address);
    }

    /*
     * Grant MINTER_ROLE for CryptoPageComment
     */
    if (!(await bankProxy.hasRole(MINTER_ROLE, commentProxy.address))) {
        await bankProxy.grantRole(MINTER_ROLE, commentProxy.address, {
            gasPrice: hre.ethers.utils.parseUnits("1", "gwei"),
            gasLimit: 2500000,
        });
        console.log(
            "Grant MINTER_ROLE For CryptoPageComment",
            commentProxy.address
        );
    }

    console.log();
    console.log("WETH ADDRESS", WETHAddress);
    console.log("USDT ADDRESS", USDTAddress);
    console.log();

    const uniswapV3Factory = new hre.ethers.Contract(
        factoryAddress,
        FACTORY_ABI,
        hre.ethers.getDefaultProvider()
    );

    console.log("uniswapV3Factory", uniswapV3Factory)

    const WETHUSDTPoolAddress = await uniswapV3Factory.getPool(
        WETHAddress,
        USDTAddress,
        3000
    );
    const USDTPAGEPoolAddress = await uniswapV3Factory.getPool(
        USDTAddress,
        tokenProxy.address,
        3000
    );
    console.log("WETH / USDT Pool Address", WETHUSDTPoolAddress);
    console.log("USDT / PAGE Pool Address", USDTPAGEPoolAddress);

    if (WETHUSDTPoolAddress !== nullAddress) {
        await bankProxy.setWETHUSDTPool(WETHUSDTPoolAddress.address);
        console.log("WETH / USDT Pool Set Successfully");
    }
    if (USDTPAGEPoolAddress !== nullAddress) {
        await bankProxy.setUSDTPAGEPool(USDTPAGEPoolAddress.address);
        console.log("USDT / PAGE Pool Set Successfully");
    }
};
func.tags = [];
func.dependencies = ["PageBank", "PageToken", "PageComment", "PageNFT"];
export default func;
