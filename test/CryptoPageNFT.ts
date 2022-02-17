import {
    abi as FACTORY_ABI,
    bytecode as FACTORY_BYTECODE,
} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { abi as POOL_ABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import bs58 from "bs58";
import { expect } from "chai";
import { Signer } from "ethers";
import { ethers, upgrades } from "hardhat";
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

describe("PageNFT", function () {
    const commentText =
        "0x" +
        bs58
            .decode("QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB")
            .slice(2)
            .toString("hex");
    const collectionName =
        "0xb0379d0047424de9fa43620fd073532a0135cf4a85e8d7bc9ca8aae9bcd8cc4c";
    let bank: PageBank;
    let token: PageToken;
    let nft: PageNFT;
    let comment: PageComment;
    let signers: Signer[];
    let alice: Address;
    let deployer: Address;
    let commentFactory: PageComment__factory;

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
        commentFactory = (await ethers.getContractFactory(
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
    /*
    it("Should Be Upgradable", async function () {
        const pageNFT = await ethers.getContractFactory("PageNFT");
        const pageNFTV2 = await ethers.getContractFactory("PageNFT");
        const proxy = await upgrades.deployProxy(pageNFT, [
            comment.address,
            bank.address,
            "https://ipfs.io/ipfs",
            ]);
        await upgrades.upgradeProxy(proxy.address, pageNFTV2);
    });
    */
    it("Should Have Correct Name And Symbol", async function () {
        const name = await nft.name();
        const symbol = await nft.symbol();
        expect(name).to.equal("Crypto.Page NFT");
        expect(symbol).to.equal("PAGE.NFT");
    });

    it("Should Available TokenPrice", async function () {
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        const price = await nft.tokenPrice(0);
        await expect(price.toString(), "160032");
        // await expect(nft.tokenPrice(25)).to.be.revertedWith(
        // "No token with this Id"
        // );
    });

    it("Should Only Allow Owner Of Contract To Burn NFT", async function () {
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        await nft.safeBurn(0);
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        await expect(nft.connect(signers[1]).safeBurn(1)).to.be.revertedWith(
            "Allower only for owner"
        );
    });

    it("Should", async function () {
        const bob = await signers[1];
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        await nft
            .connect(bob)
            .safeMint(
                alice,
                "https://ipfs.io/ipfs/fakeIPFSHash",
                collectionName
            );
        await comment
            .connect(bob)
            .createComment(nft.address, 0, commentText, true);
        await nft.safeBurn(0);
    });

    it("Should't Allow Mint For Null Address", async function () {
        await expect(
            nft.safeMint(
                "0x0000000000000000000000000000000000000000",
                "https://ipfs.io/ipfs/fakeIPFSHash",
                collectionName
            )
        ).to.be.revertedWith("Address can't be null");
    });

    it("Should Only Allow Owner Of Contract To Burn NFT", async function () {
        const bob = await signers[1].getAddress();
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        await nft["safeTransferFrom(address,address,uint256)"](alice, bob, 0);
        const nullAddress = "0x0000000000000000000000000000000000000000";
        await expect(nft["safeTransferFrom(address,address,uint256)"](nullAddress, bob, 1)).to.be.revertedWith("Address can't be null");
        await expect(nft["safeTransferFrom(address,address,uint256)"](alice, nullAddress, 1)).to.be.revertedWith("Address can't be null");
    });

    it("Should Allowed Get Collections By Address", async function () {
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        const collections = await nft.getCollectionsByAddress(alice);
        expect(collections[0]).to.be.equal(collectionName);
    });

    it("Should Allowed Get TokensIds By CollectionName", async function () {
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        const tokensIds = await nft.getTokensIdsByCollectionName(
            alice,
            collectionName
        );
        expect(tokensIds[0]).to.be.equal(0);
    });

    it("Should Allowed Get TokensURIs By CollectionName", async function () {
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeIPFSHash",
            collectionName
        );
        const tokenURIs = await nft.getTokensURIsByCollectionName(
            alice,
            collectionName
        );
        expect(tokenURIs[0]).to.be.equal("https://ipfs.io/ipfs/fakeIPFSHash");
    });
});
