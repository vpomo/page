import {
    abi as FACTORY_ABI,
    bytecode as FACTORY_BYTECODE,
} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { abi as POOL_ABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import bs58 from "bs58";
import { expect } from "chai";
import { Signer } from "ethers";
import { hexStripZeros } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
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

describe("PageCommentBank", function () {
    const commentText =
        "0x" +
        bs58
            .decode("QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB")
            .slice(2)
            .toString("hex");
    let bank: PageBank;
    let token: PageToken;
    let nft: PageNFT;
    let comment: PageComment;
    let signers: Signer[];
    let alice: Address;
    let bob: Address;
    let deployer: Address;

    beforeEach(async function () {
        signers = await ethers.getSigners();
        alice = await signers[0].getAddress();
        deployer = await signers[signers.length - 1].getAddress();
        bob = await signers[1].getAddress();

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
        comment = await commentFactory.deploy(bank.address);

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
        // await WETHUSDTPool.initialize(1000000000000);
        // await USDTPAGEPool.initialize(1000000000000);
        await token.deployed();
        await bank.initialize(deployer, 1000);
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

    it("Should Be Allowed Check Balance", async function () {
        await nft.safeMint(alice, "https://ipfs.io/ipfs/fakeHash");
        let balance = await bank.balanceOf();
        expect(Number(balance)).to.be.equal(0);
        await nft
            .connect(signers[1])
            .safeMint(alice, "https://ipfs.io/ipfs/fakeHash");
        balance = await bank.balanceOf();
        // expect(Number(balance)).to.be.equal(17891712000);// 18243360000);
    });

    it("Should Be Allowed Withdraw", async function () {
        await expect(bank.withdraw(10000000000000)).to.be.revertedWith(
            "Not enough balance"
        );
        await nft
            .connect(signers[5])
            .safeMint(alice, "https://ipfs.io/ipfs/fakeHash");
        // const balance = await bank.connect(signers[0]).balanceOf();
        // console.log("balance after safe mint from another", balance);
        // await bank.withdraw(1);
    });
});
