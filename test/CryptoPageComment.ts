import {
    abi as FACTORY_ABI,
    bytecode as FACTORY_BYTECODE,
} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { abi as POOL_ABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import bs58 from "bs58";
import { expect } from "chai";
import { Signer } from "ethers";
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

describe("PageComment", async function () {
    const commentText =
        "0x" +
        bs58
            .decode("QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB")
            .slice(2)
            .toString("hex");
    let bank: PageBank;
    let token: PageToken;
    let nft: PageNFT;
    let signers: Signer[];
    let alice: Address;
    let deployer: Address;
    let comment: PageComment;

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
        await nft.safeMint(alice, "https://ipfs.io/ipfs/");
    });

    describe("After Deployment", function () {
        it("Should Be Empty Statistic", async function () {
            const statictic = await comment.getStatistic(nft.address, 0);
            expect(statictic.likes).to.equal(0);
            expect(statictic.dislikes).to.equal(0);
            expect(statictic.total).to.equal(0);
        });

        it("Should Be Required Id Equals Or Less Than Total Comments Count", async function () {
            await expect(
                comment.getCommentById(nft.address, 0, 99)
            ).to.be.revertedWith("No comment with this ID");
        });

        it("Should Be Required Ids Count More Than Zero", async function () {
            await expect(
                comment.getCommentsByIds(nft.address, 0, [])
            ).to.be.revertedWith("ids length must be more than zero");
        });
        it("Should Be Required Id In Ids Equals Or Less Than Total Comments Count", async function () {
            await comment.createComment(nft.address, 0, commentText, true);
            // await expect(comment.getCommentsByIds(nft.address, 0, [0])).to.be.revertedWith(
            // "No comment with this ID"
            // );
            await expect(
                comment.getCommentsByIds(nft.address, 0, [99, 33])
            ).to.be.revertedWith(
                "ids length must be less or equal commentsIdsArray"
            );
        });

        describe("Each New Comment", function () {
            it("Should Be Available In Total Comments Ids", async function () {
                await comment.createComment(nft.address, 0, commentText, true);
                const commentsIds = await comment.getCommentsIds(
                    nft.address,
                    0
                );
                expect(commentsIds.length).to.equal(1);
                expect(commentsIds[0]).to.equal(0);
            });

            it("Should Be Available Comments By Author", async function () {
                let comments = await comment.getCommentsOf(
                    nft.address,
                    0,
                    alice
                );
                expect(comments.length).to.equal(0);
                await comment.createComment(nft.address, 0, commentText, true);
                comments = await comment.getCommentsOf(nft.address, 0, alice);
                expect(comments.length).to.equal(1);
            });
        });
    });

    describe("Each New Comment", function () {
        it("Should Be Available In Statistic When Comment Positive", async function () {
            await comment.createComment(nft.address, 0, commentText, true);
            const statistic = await comment.getStatistic(nft.address, 0);
            expect(statistic.likes).to.equal(1);
            expect(statistic.dislikes).to.equal(0);
            expect(statistic.total).to.equal(1);
        });

        it("Should Be Available In Total Comments Ids", async function () {
            await comment.createComment(nft.address, 0, commentText, true);
            const commentsIds = await comment.getCommentsIds(nft.address, 0);
            expect(commentsIds.length).to.equal(1);
            expect(commentsIds[0]).to.equal(0);
        });

        it("Should Be Available In Statistic When Comment Negative", async function () {
            await comment.createComment(nft.address, 0, commentText, true);
            const statistic = await comment.getStatistic(nft.address, 0);
            expect(statistic.likes).to.equal(1);
            expect(statistic.dislikes).to.equal(0);
            expect(statistic.total).to.equal(1);
        });

        it("Should Be Available By Id", async function () {
            await comment.createComment(nft.address, 0, commentText, true);
            const commentData = await comment.getCommentById(nft.address, 0, 0);
            expect(commentData.id).to.equal(0);
            expect(commentData.author).to.equal(alice);
            expect(commentData.ipfsHash).to.equal(commentText);
            expect(commentData.like).to.equal(true);
        });
        it("Should Be Available In Total Comments", async function () {
            await comment.createComment(nft.address, 0, commentText, true);
            const comments = await comment.getComments(nft.address, 0);
            expect(comments[0].ipfsHash).to.equal(commentText);
            expect(comments[0].author).to.equal(alice);
        });
        it("Should Be Available Empty Comments", async function () {
            const comments = await comment.getComments(nft.address, 0);
            expect(comments.length).to.equal(0);
        });
        it("Should Be Available In Statistic With Comments", async function () {
            await comment.createComment(nft.address, 0, commentText, true);
            const statistic = await comment.getStatisticWithComments(
                nft.address,
                0
            );
            const firstComment = statistic.comments[0];
            expect(statistic.comments.length).to.equal(1);
            expect(firstComment.id).to.equal(0);
            expect(firstComment.ipfsHash).to.equal(commentText);
            expect(firstComment.author).to.equal(alice);
            expect(firstComment.like).to.equal(true);
            expect(statistic.likes).to.equal(1);
            expect(statistic.dislikes).to.equal(0);
            expect(statistic.total).to.equal(1);
        });
        it("Should Be Available Comments By Author", async function () {
            let comments = await comment.getCommentsOf(nft.address, 0, alice);
            expect(comments.length).to.equal(0);
            await comment.createComment(nft.address, 0, commentText, true);
            comments = await comment.getCommentsOf(nft.address, 0, alice);
            const f = await comment.getCommentsOf(
                nft.address,
                0,
                "0x0000000000000000000000000000000000000000"
            );
            // console.log("f", f);
            // await expect(comment.getCommentsOf("0x0000000000000000000000000000000000000000")).to.be.revertedWith("Address can't be null");
        });
    });
});
