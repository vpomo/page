import { abi as FactoryABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { abi as PoolABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
const factoryAddress =
    process.env.FACTORY_ADDRESS || "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const tokenBAddress =
    process.env.TOKEN_B_ADDRESS || "0xc778417E063141139Fce010982780140Aa0cD5Ab";
const poolFee = process.env.POOL_FEE || 3000;
const poolInitializePrice = process.env.POOL_INITIALIZE_PRICE || 10 ** 20;

const USDTAddress = "0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02"
const WETHAddress = tokenBAddress

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.ethers.getNamedSigners();
    await deploy("PageToken", {
        from: deployer.address,
        args: [deployer.address],
        log: true,
        deterministicDeployment: false,
    });
    
    const token = await hre.ethers.getContract("PageToken");
    const factory = await hre.ethers.getContractAt(FactoryABI, factoryAddress);
    const WETHUSDTpoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(WETHAddress),
        hre.ethers.utils.getAddress(USDTAddress),
        500
    );
    const USDTPAGEpoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(USDTAddress),
        hre.ethers.utils.getAddress(token.address),
        500
    );
    // console.log('USDTPAGEpoolAddress', USDTPAGEpoolAddress)
    // await token.setWETHUSDTPool(WETHUSDTpoolAddress)
    // await token.setUSDTPAGEPool(USDTPAGEpoolAddress)

    // let WETHUSDTPrice = await token.getWETHUSDTPrice();
    // console.log('WETHUSDTPrice', WETHUSDTPrice.toString())
    // let USDTPAGEPrice = await token.getUSDTPAGEPrice();
    // console.log('USDTPAGEPrice', USDTPAGEPrice.toString())   

    /*
    console.log('token.address', hre.ethers.utils.getAddress(token.address))
    console.log('USDTAddress', hre.ethers.utils.getAddress(USDTAddress))
    console.log('WETHAddress', hre.ethers.utils.getAddress(WETHAddress))

 

    const WETHUSDTpoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(WETHAddress),
        hre.ethers.utils.getAddress(USDTAddress),
        500
    );
    console.log('WETHUSDTpoolAddress', WETHUSDTpoolAddress)
    const USDTPAGEpoolAddress = await factory.getPool(
        hre.ethers.utils.getAddress(USDTAddress),
        hre.ethers.utils.getAddress(token.address),
        500
    );
    console.log('USDTPAGEpoolAddress', USDTPAGEpoolAddress)
    await token.setWETHUSDTPool(WETHUSDTpoolAddress)
    await token.setUSDTPAGEPool(USDTPAGEpoolAddress)

    WETHUSDTPrice = await token.getWETHUSDTPrice();
    console.log('WETHUSDTPrice', WETHUSDTPrice.toString())
    USDTPAGEPrice = await token.getUSDTPAGEPrice();
    console.log('USDTPAGEPrice', USDTPAGEPrice.toString())

    const pool = await hre.ethers.getContractAt(PoolABI, WETHUSDTpoolAddress);
    const slot0 = await pool.slot0();
    console.log("slot0", slot0);
    console.log("normalPrice", String(slot0.normalPrice))
    const sqrtPriceX96 = Number(slot0.sqrtPriceX96);
    // (sqrtPriceX96 ** sqrtPriceX96)
    console.log("sqrtPriceX96", sqrtPriceX96);
    const normalPrice = sqrtPriceX96 ** 2 / (2 ** 96) ** 2;
    console.log("normalPrice", normalPrice);
    */

    /*
    const poolAddress = await factory.getPool(
        token.address,
        tokenBAddress,
        poolFee
    );
    */
    // await token.setPool(poolAddress);
    // await token.setWETHPool(WETHpoolAddress)
    // await token.setUSDTPool(USDTpoolAddress)
    // const WETHUSDTPrice = await token.getWETHUSDTPrice();
    // console.log('WETHUSDTPrice', WETHUSDTPrice)
    // const USDTPAGEPrice = await token.getUSDTPAGEPrice();
    // console.log('USDTPAGEPrice', USDTPAGEPrice)
    // console.log("price", price.toNumber());
    /*
    const factory = await hre.ethers.getContractAt(FactoryABI, factoryAddress);
    const token = await hre.ethers.getContract("PageToken");
    const poolAddress = await factory.getPool(
        token.address,
        tokenBAddress,
        poolFee
    );
    console.log("poolAddress", poolAddress);
    await token.setPool(poolAddress);
    const price = await token.getPrice();
    console.log("price", price.toNumber());
    const pool = await hre.ethers.getContractAt(PoolABI, poolAddress);
    const slot0 = await pool.slot0();
    console.log("slot0", slot0);
    const sqrtPriceX96 = Number(slot0.sqrtPriceX96);
    // (sqrtPriceX96 ** sqrtPriceX96)
    console.log("sqrtPriceX96", sqrtPriceX96);
    const normalPrice = sqrtPriceX96 ** 2 / (2 ** 96) ** 2;
    console.log("normalPrice", normalPrice);

    const contactPrice = (sqrtPriceX96 * sqrtPriceX96) >> (92 * 2);
    console.log("contactPrice", contactPrice);

    const blah = (sqrtPriceX96 / 2 ** 96) ** 2; // sqrtRatioX96 ** 2 / 2 ** 192
    console.log("blah", blah);
    */
};
func.tags = ["PageToken"];
export default func;
