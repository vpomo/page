import { abi as FACTORY_ABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { PageBank, PageComment, PageNFT, PageToken } from "../types";

const factoryAddress =
    process.env.FACTORY_ADDRESS || "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const USDTAddress =
    process.env.USDT_ADDRESS || "0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02";
const WETHAddress =
    process.env.WETH_ADDRESS || "0xc778417E063141139Fce010982780140Aa0cD5Ab";
const nullAddress = "0x0000000000000000000000000000000000000000";
const treasuryAddress = process.env.TREASURY_ADDRESS;

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const PageBankFactory = await hre.ethers.getContractFactory("PageBank");
    const PageTokenFactory = await hre.ethers.getContractFactory("PageToken");
    const PageCommentFactory = await hre.ethers.getContractFactory(
        "PageComment"
    );
    const PageNFTFactory = await hre.ethers.getContractFactory("PageNFT");

    console.log("");

    /*
     * Deploy CryptoPageBank contract
     */
    const bankProxy = (await hre.upgrades.deployProxy(PageBankFactory, [
        treasuryAddress,
        1000,
    ])) as PageBank;
    await bankProxy.deployed();
    console.log("PAGE_BANK_PROXY_ADDRESS", bankProxy.address);

    /*
     * Deploy CryptoPageToken contract
     */
    const tokenProxy = (await hre.upgrades.deployProxy(PageTokenFactory, [
        treasuryAddress,
        bankProxy.address,
    ])) as PageToken;
    await tokenProxy.deployed();
    console.log("PAGE_TOKEN_PROXY_ADDRESS", tokenProxy.address);
    await bankProxy.setToken(bankProxy.address);

    /*
     * Deploy CryptoPageComment contract
     */
    const commentProxy = (await hre.upgrades.deployProxy(PageCommentFactory, [
        bankProxy.address,
    ])) as PageComment;
    await commentProxy.deployed();
    console.log("PAGE_COMMENT_PROXY_ADDRESS", commentProxy.address);

    /*
     * Deploy CryptoPageNFT contract
     */
    const nftProxy = (await hre.upgrades.deployProxy(PageNFTFactory, [
        commentProxy.address,
        bankProxy.address,
        "https://ipfs.io/ipfs/",
    ])) as PageNFT;
    await nftProxy.deployed();
    console.log("PAGE_NFT_PROXY_ADDRESS", nftProxy.address);

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
        console.log("MINTER_ROLE_GRANT_FOR_NFT", nftProxy.address);
    }

    /*
     * Grant BURNER_ROLE for CryptoPageNFT
     */
    if (!(await bankProxy.hasRole(BURNER_ROLE, nftProxy.address))) {
        await bankProxy.grantRole(BURNER_ROLE, nftProxy.address, {
            gasPrice: hre.ethers.utils.parseUnits("1", "gwei"),
            gasLimit: 2500000,
        });
        console.log("BURNER_ROLE_GRANT_FOR_NFT", nftProxy.address);
    }

    /*
     * Grant MINTER_ROLE for CryptoPageComment
     */
    if (!(await bankProxy.hasRole(MINTER_ROLE, commentProxy.address))) {
        await bankProxy.grantRole(MINTER_ROLE, commentProxy.address, {
            gasPrice: hre.ethers.utils.parseUnits("1", "gwei"),
            gasLimit: 2500000,
        });
        console.log("MINTER_ROLE_GRANT_FOR_COMMENT", commentProxy.address);
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
    const WETHUSDTPoolAddress = await uniswapV3Factory.getPool(
        WETHAddress,
        USDTAddress,
        500
    );
    console.log("WETH / USDT Pool Address", WETHUSDTPoolAddress);

    const USDTPAGEPoolAddress = await uniswapV3Factory.getPool(
        USDTAddress,
        tokenProxy.address,
        500
    );

    console.log("USDT / PAGE Pool Address", USDTPAGEPoolAddress);

    if (WETHUSDTPoolAddress !== nullAddress) {
        await bankProxy.setWETHUSDTPool(WETHUSDTPoolAddress.address);
        console.log("WETH / USDT Pool Was Set Successfully");
    }
    if (USDTPAGEPoolAddress !== nullAddress) {
        await bankProxy.setUSDTPAGEPool(USDTPAGEPoolAddress.address);
        console.log("USDT / PAGE Pool Was Set Successfully");
    }
};
func.tags = [];
func.dependencies = [];
export default func;
