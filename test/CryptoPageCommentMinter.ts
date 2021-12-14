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
    MockToken,
    MockToken__factory,
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
    let mockToken: MockToken;
    let commentMinter: PageCommentMinter;
    let nft: PageNFT;
    beforeEach(async function () {
        accounts = await ethers.getSigners();
        address = await accounts[0].getAddress();
        const treasury = await accounts[9].getAddress();
        const mockTokenFactory = (await ethers.getContractFactory(
            "MockToken"
        )) as MockToken__factory;
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const commentMinterFactory = (await ethers.getContractFactory(
            "PageCommentMinter"
        )) as PageCommentMinter__factory;
        const nftFactory = (await ethers.getContractFactory(
            "PageNFT"
        )) as PageNFT__factory;
        const factoryFactory = new ethers.ContractFactory(
            FACTORY_ABI,
            FACTORY_BYTECODE,
            accounts[0]
        );
        const factory = await factoryFactory.deploy();
        await factory.deployed();
        mockToken = await mockTokenFactory.deploy();
        await mockToken.deployed();
        token = await tokenFactory.deploy(treasury);
        await token.deployed();
        await factory.createPool(factory.address, mockToken.address, 3000);
        const pool = await factory.getPool(
            factory.address,
            mockToken.address,
            3000
        );
        await token.setUSDTPAGEPool(pool);
        await token.setWETHUSDTPool(pool);
        const poolContract = await ethers.getContractAt(POOL_ABI, pool);
        await poolContract.initialize(ethers.utils.parseEther("1"));
        commentMinter = await commentMinterFactory.deploy(
            address,
            token.address
        );
        nft = await nftFactory.deploy(
            address,
            token.address,
            commentMinter.address
        );
        const MINTER_ROLE = ethers.utils.id("MINTER_ROLE");
        const BURNER_ROLE = ethers.utils.id("BURNER_ROLE");
        await token.grantRole(MINTER_ROLE, commentMinter.address);
        await token.grantRole(BURNER_ROLE, commentMinter.address);
        await token.grantRole(MINTER_ROLE, nft.address);
        await token.grantRole(BURNER_ROLE, nft.address);
        await nft.deployed();
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
