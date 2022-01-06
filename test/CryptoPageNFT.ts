import {
    abi as FACTORY_ABI,
    bytecode as FACTORY_BYTECODE,
} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { abi as POOL_ABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    MockUSDTToken,
    MockUSDTToken__factory,
    MockWETHToken,
    MockWETHToken__factory,
    PageCommentDeployer,
    PageCommentDeployer__factory,
    PageNFT,
    PageNFT__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageNFT", function () {
    /*
    const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
    let nft: PageNFT;
    let token: PageToken;
    let mockUSDTToken: MockUSDTToken;
    let mockWETHToken: MockWETHToken;
    let commentMinter: PageCommentMinter;
    let commentMinterFactory: PageCommentMinter__factory;
    let tokenFactory: PageToken__factory;
    let nftFactory: PageNFT__factory;
    let signers: Signer[];
    let alice: Signer;
    let aliceAddress: Address;
    let bob: Signer;
    let carol: Signer;

    beforeEach(async function () {
        signers = await ethers.getSigners();
        alice = signers[0];
        aliceAddress = await alice.getAddress();
        bob = signers[1];
        carol = signers[2];
        tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        commentMinterFactory = (await ethers.getContractFactory(
            "PageCommentMinter"
        )) as PageCommentMinter__factory;
        nftFactory = (await ethers.getContractFactory(
            "PageNFT"
        )) as PageNFT__factory;
        const mockMETHTokenFactory = (await ethers.getContractFactory(
            "MockWETHToken"
        )) as MockWETHToken__factory;
        const mockUSDTTokenFactory = (await ethers.getContractFactory(
            "MockUSDTToken"
        )) as MockUSDTToken__factory;
        const factoryFactory = new ethers.ContractFactory(
            FACTORY_ABI,
            FACTORY_BYTECODE,
            signers[0]
        );
        const factory = await factoryFactory.deploy();
        const treasury = await alice.getAddress();
        commentMinter = await commentMinterFactory.deploy();
        const MINTER_ROLE = ethers.utils.id("MINTER_ROLE");
        const BURNER_ROLE = ethers.utils.id("BURNER_ROLE");
        mockWETHToken = await mockMETHTokenFactory.deploy();
        mockUSDTToken = await mockUSDTTokenFactory.deploy();
        nft = await nftFactory.deploy();
        token = await tokenFactory.deploy();
        await factory.deployed();
        await token.deployed();
        await token.initialize(treasury);
        await commentMinter.initialize(treasury, token.address);
        await nft.initialize(treasury, token.address, commentMinter.address);
        await factory.createPool(
            mockWETHToken.address,
            mockUSDTToken.address,
            3000
        );
        await factory.createPool(mockUSDTToken.address, token.address, 3000);
        const WEUTHUSDTPoolAddress = await factory.getPool(
            mockWETHToken.address,
            mockUSDTToken.address,
            3000
        );
        const USDTPAGEPoolAddress = await factory.getPool(
            mockUSDTToken.address,
            token.address,
            3000
        );
        const WEUTHUSDTPoolContract = await ethers.getContractAt(
            POOL_ABI,
            WEUTHUSDTPoolAddress
        );
        const USDTPAGEPoolContract = await ethers.getContractAt(
            POOL_ABI,
            USDTPAGEPoolAddress
        );
        await token.setWETHUSDTPool(WEUTHUSDTPoolAddress);
        await token.setUSDTPAGEPool(USDTPAGEPoolAddress);
        await WEUTHUSDTPoolContract.initialize(ethers.utils.parseEther("1")); // 5.007187174633349e+24
        await USDTPAGEPoolContract.initialize(ethers.utils.parseEther("1")); // 4.9029716095450684e+35
        await token.grantRole(MINTER_ROLE, await alice.getAddress());
        await token.grantRole(BURNER_ROLE, await alice.getAddress());
        await token.grantRole(MINTER_ROLE, nft.address);
        await token.grantRole(BURNER_ROLE, nft.address);
        await token.grantRole(MINTER_ROLE, commentMinter.address);
        await token.grantRole(BURNER_ROLE, commentMinter.address);
    });

    it("Should Have Correct Name And Symbol", async function () {
        const name = await nft.name();
        const symbol = await nft.symbol();
        expect(name).to.equal("Crypto.Page NFT");
        expect(symbol).to.equal("PAGE.NFT");
    });

    it("Should Be Available Set Fee Only By Owner", async function () {
        await nft.setFee(1000);
        const fee = await nft.getFee();
        expect(fee).to.equal(1000);
        await expect(nft.connect(signers[1]).setFee(1000)).to.revertedWith(
            "Ownable: caller is not the owner"
        );
    });

    it("Should Be Available Get Treasury", async function () {
        const anotherTreasuryAddress = await signers[1].getAddress();
        await nft.setTreasury(anotherTreasuryAddress);
        const treasury = await nft.getTreasury();
        expect(treasury).to.equal(anotherTreasuryAddress);
    });

    it("Should Only Allow Owner Of Contract To Burn NFT", async function () {
        await nft.safeMint(aliceAddress, "https://ipfs.io/ipfs/fakeIPFSHash");
        const balance = await token.balanceOf(aliceAddress);
        await nft.burn(0);
        await nft.safeMint(aliceAddress, "https://ipfs.io/ipfs/fakeIPFSHash");
        await expect(nft.connect(bob).burn(1)).to.be.revertedWith(
            "It's possible only for owner"
        );
    });

    it("Should Available TokenPrice", async function () {
        await nft.safeMint(aliceAddress, "https://ipfs.io/ipfs/fakeIPFSHash");
        const price = await nft.tokenPrice(0);
        await expect(price.toString(), "160032");
        await expect(nft.tokenPrice(25)).to.be.revertedWith(
            "No token with this Id"
        );
    });

    it("Should Not Allow Burn Nonexistent Token", async function () {
        await expect(nft.burn(1)).to.be.revertedWith(
            "ERC721: owner query for nonexistent token"
        );
    });

    it("Should Allow To Get TokenURI", async function () {
        await nft.safeMint(aliceAddress, "https://ipfs.io/ipfs/fakeIPFSHash");
        await expect(nft.connect(bob).tokenURI(0), tokenURI);
    });

    it("Should ##############################", async function () {
        await nft.safeMint(
            await bob.getAddress(),
            "https://ipfs.io/ipfs/fakeIPFSHash"
        );
        await commentMinter.createComment(
            nft.address,
            0,
            aliceAddress,
            "Hello, World!",
            false
        );
        const balance = await token.balanceOf(await bob.getAddress());
        await token.connect(bob).transfer(aliceAddress, balance);
        await expect(nft.connect(bob).burn(0)).to.be.revertedWith(
            "not enought balance"
        );
    });

    it("Should %%%%%%%%%%%%%%%%%%%%%%%", async function () {
        await nft.safeMint(aliceAddress, "https://ipfs.io/ipfs/fakeIPFSHash");
        const bobAddress = await bob.getAddress();
        await nft.transferFrom(aliceAddress, bobAddress, 0);
        await expect(
            nft.transferFrom(bobAddress, aliceAddress, 0)
        ).to.be.revertedWith(
            "ERC721: transfer caller is not owner or approved"
        );
    });

    it("Should Be Available Set Only Valid Treasury Only For Owner", async function () {
        const anotherAddress = await signers[1].getAddress();
        const nullAddress = "0x0000000000000000000000000000000000000000";
        await nft.setTreasury(anotherAddress);
        await expect(nft.setTreasury(nullAddress)).to.revertedWith("");
    });

    it("Should Be Available Set Mint Fee < 3000 And > 100 For Owner", async function () {
        await nft.setFee(3000);
        await expect(nft.setFee(9)).to.revertedWith(
            "setMintFee: minimum mint fee percent is 0.1%"
        );
        await expect(nft.setFee(3001)).to.revertedWith(
            "setMintFee: maximum mint fee percent is 30%"
        );
    });
    */
});
