import {
    abi as FACTORY_ABI,
    bytecode as FACTORY_BYTECODE,
} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import {
    abi as POOL_ABI,
    bytecode as POOL_BYTECODE,
} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    MockUSDTToken,
    MockUSDTToken__factory,
    MockWETHToken,
    MockWETHToken__factory,
    PageCommentMinter,
    PageCommentMinter__factory,
    PageNFT,
    PageNFT__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageCommentMinter", async function () {
    const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
    let address: Address;
    let accounts: Signer[];
    let token: PageToken;
    let mockUSDTToken: MockUSDTToken;
    let mockWETHToken: MockWETHToken;
    let commentMinter: PageCommentMinter;
    let nft: PageNFT;
    beforeEach(async function () {
        accounts = await ethers.getSigners();
        address = await accounts[0].getAddress();
        const treasury = await accounts[9].getAddress();
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const commentMinterFactory = (await ethers.getContractFactory(
            "PageCommentMinter"
        )) as PageCommentMinter__factory;
        const nftFactory = (await ethers.getContractFactory(
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
            accounts[0]
        );
        const factory = await factoryFactory.deploy();
        const MINTER_ROLE = ethers.utils.id("MINTER_ROLE");
        const BURNER_ROLE = ethers.utils.id("BURNER_ROLE");
        commentMinter = await commentMinterFactory.deploy();
        mockWETHToken = await mockMETHTokenFactory.deploy();
        mockUSDTToken = await mockUSDTTokenFactory.deploy();
        token = await tokenFactory.deploy();
        nft = await nftFactory.deploy();
        await token.deployed();
        await factory.deployed();
        await token.initialize(treasury);
        await commentMinter.initialize(treasury, token.address);
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
        await WEUTHUSDTPoolContract.initialize(ethers.utils.parseEther("1"));
        await USDTPAGEPoolContract.initialize(ethers.utils.parseEther("1"));
        await token.grantRole(MINTER_ROLE, address);
        await token.grantRole(BURNER_ROLE, address);
        await nft.deployed();
        await nft.initialize(address, token.address, commentMinter.address);
        await token.grantRole(MINTER_ROLE, nft.address);
        await token.grantRole(BURNER_ROLE, nft.address);
        await token.grantRole(MINTER_ROLE, commentMinter.address);
        await token.grantRole(BURNER_ROLE, commentMinter.address);
    });

    describe("After Deployment", function () {
        it("Should Be Allowed Check Existing Contract", async function () {
            await nft.safeMint(address, tokenURI);
            await commentMinter.createComment(
                nft.address,
                0,
                address,
                "Hello, World!",
                true
            );
            await commentMinter.createComment(
                nft.address,
                0,
                address,
                "Hello, World!",
                false
            );
            await commentMinter.getContract(nft.address, 0);
        });

        it("Should Be Not Allowed Existing Contract", async function () {
            await expect(
                commentMinter.getContract(nft.address, 0)
            ).to.be.revertedWith("NFT contract does not exist");
        });
        it("Should Be Allowed Activate Any TokenId From Any ERC721 Contract", async function () {
            await nft.safeMint(address, tokenURI);
            await commentMinter.createComment(
                nft.address,
                0,
                address,
                "Hello, world!",
                true
            );
        });

        it("Should Be Available Get And Set Treasury ", async function () {
            const anotherTreasuryAddress = await accounts[1].getAddress();
            await commentMinter.setTreasury(anotherTreasuryAddress);
            const treasury = await commentMinter.getTreasury();
            expect(treasury).to.equal(anotherTreasuryAddress);
            await expect(
                commentMinter.setTreasury(
                    "0x0000000000000000000000000000000000000000"
                )
            ).to.be.revertedWith("setTreasuryAddress: is zero address");
        });
    });
});
