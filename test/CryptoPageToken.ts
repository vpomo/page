import {
    abi as FACTORY_ABI,
    bytecode as FACTORY_BYTECODE,
} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { abi as POOL_ABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import { expect } from "chai";
import { Signer } from "ethers";
import { ethers, upgrades } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    MockToken,
    MockToken__factory,
    PageBank,
    PageBank__factory,
    PageComment,
    PageComment__factory,
    PageNFT,
    PageNFT__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageToken", function () {
    let bank: PageBank;
    let token: PageToken;
    let nft: PageNFT;
    let comment: PageComment;
    let signers: Signer[];
    let alice: Address;
    let deployer: Address;

    beforeEach(async function () {
        signers = await ethers.getSigners();
        alice = await signers[0].getAddress();
        deployer = await signers[signers.length - 1].getAddress();

        const bankFactory = (await ethers.getContractFactory(
            "PageBank"
        )) as PageBank__factory;
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const mockTokenFactory = (await ethers.getContractFactory(
            "MockToken"
        )) as MockToken__factory;
        const nftFactory = (await ethers.getContractFactory(
            "PageNFT"
        )) as PageNFT__factory;
        const commentFactory = (await ethers.getContractFactory(
            "PageComment"
        )) as PageComment__factory;
        const uniswapV3FactoryFactory = new ethers.ContractFactory(
            FACTORY_ABI,
            FACTORY_BYTECODE,
            signers[signers.length - 1]
        );
        const uniswapV3Factory = await uniswapV3FactoryFactory.deploy();
        const weth = await mockTokenFactory.deploy(18);
        const usdt = await mockTokenFactory.deploy(6);

        bank = await bankFactory.deploy();
        token = await tokenFactory.deploy();
        nft = await nftFactory.deploy();
        comment = await commentFactory.deploy();

        await token.initialize(deployer, bank.address);
        await weth.deployed();
        await usdt.deployed();
        await uniswapV3Factory.createPool(weth.address, usdt.address, 3000);
        await uniswapV3Factory.createPool(usdt.address, token.address, 3000);
        const WETHUSDTPoolAddress = await uniswapV3Factory.getPool(
            weth.address,
            usdt.address,
            3000
        );
        const USDTPAGEPoolAddress = await uniswapV3Factory.getPool(
            usdt.address,
            token.address,
            3000
        );
        const WETHUSDTPool = new ethers.Contract(WETHUSDTPoolAddress, POOL_ABI);
        const USDTPAGEPool = new ethers.Contract(USDTPAGEPoolAddress, POOL_ABI);
        await token.deployed();
        await bank.initialize(deployer, 1000);
        await comment.initialize(bank.address);
        await bank.setToken(token.address);
        await bank.grantRole(ethers.utils.id("MINTER_ROLE"), token.address);
        await bank.grantRole(ethers.utils.id("MINTER_ROLE"), nft.address);
        await bank.grantRole(ethers.utils.id("BURNER_ROLE"), nft.address);
        await bank.grantRole(ethers.utils.id("MINTER_ROLE"), comment.address);
        await nft.initialize(
            comment.address,
            bank.address,
            "https://ipfs.io/ipfs"
        );
        await bank.setWETHUSDTPool(WETHUSDTPoolAddress);
        await bank.setUSDTPAGEPool(USDTPAGEPoolAddress);
    });

    it("Should Be Upgradable", async function () {
        const pageToken = await ethers.getContractFactory("PageToken");
        const pageTokenV2 = await ethers.getContractFactory("PageToken");
        const proxy = await upgrades.deployProxy(pageToken, [
            deployer,
            bank.address,
        ]);
        await upgrades.upgradeProxy(proxy.address, pageTokenV2);
    });

    it("Should Have Correct Name And Symbol And Decimal", async function () {
        const name = await token.name();
        const symbol = await token.symbol();
        const decimals = await token.decimals();
        expect(name).to.equal("Crypto.Page");
        expect(symbol).to.equal("PAGE");
        expect(decimals.toString()).to.equal("18");
    });

    it("Should Be Available Mint And Burn Only For Bank", async function () {
        await expect(token.mint(alice, 1000)).to.be.revertedWith(
            "PageToken. Only bank can call this function"
        );
        await expect(token.burn(alice, 1000)).to.be.revertedWith(
            "PageToken. Only bank can call this function"
        );
    });
});
