import { ConstructorFragment } from "@ethersproject/abi";
import { expect } from "chai";
import { config } from "dotenv";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    PageAdmin,
    PageAdmin__factory,
    PageMinterNFT,
    PageMinterNFT__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageMinterNFT", async function () {
    const tokenAmount = String(10 * 10 ** 18);
    let treasuryAddress: Address;
    let anotherAddress: Address;
    let accounts: Signer[];
    let pageAdmin: PageAdmin;
    let pageMinter: Address;
    let pageToken: PageToken;
    let pageMinterNFT: PageMinterNFT;

    beforeEach(async function () {
        accounts = await ethers.getSigners();
        treasuryAddress = await accounts[0].getAddress();
        anotherAddress = await accounts[1].getAddress();
        const pageAdminFactory = (await ethers.getContractFactory(
            "PageAdmin"
        )) as PageAdmin__factory;
        const pageTokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const pageMinterNFTFactory = (await ethers.getContractFactory(
            "PageMinterNFT"
        )) as PageMinterNFT__factory;

        pageAdmin = await pageAdminFactory.deploy(treasuryAddress);
        pageMinter = await pageAdmin.pageMinter();
        pageToken = await pageTokenFactory.deploy(pageMinter);
        pageMinterNFT = await pageMinterNFTFactory.deploy(
            pageMinter,
            pageToken.address
        );
        await pageAdmin.init(pageMinterNFT.address, pageToken.address);
    });

    describe("After Deployment", function () {
        it("Should Be Return BaseURL", async function () {
            const baseURL = await pageMinterNFT.getBaseURL();
            console.log("baseURL", baseURL);
        });
        it("Can Be Activated Comments In NFT", async function () {
            // const baseURL = await pageMinterNFT.getBaseURL();
            // await pageComment.createComment(address, "hello world", true);
            // console.log('baseURL', baseURL)
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            await pageMinterNFT.commentActivate(0);
        });
        it("Should Be Available tokenURI", async function () {
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            const tokenURI = await pageMinterNFT.tokenURI(0);
            expect(tokenURI).to.equal("https://ipfs.io/ipfs/fakeIPFSHash");
        });
        it("Should Be Available creatorOf", async function () {
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            const creator = await pageMinterNFT.creatorOf(0);
            expect(creator).to.equal(treasuryAddress);
        });
        it("Should Be Available getTotalStatsByTokenId", async function () {
            await pageMinterNFT.safeMint("fakeIPFSHash", true);
            const totalStats = await pageMinterNFT.getTotalStatsByTokenId(0);
            expect(totalStats.id).to.equal(0);
            expect(totalStats.comments).to.equal(0);
            expect(totalStats.likes).to.equal(0);
            expect(totalStats.dislikes).to.equal(0);
        });
        it("Should Be Available getTotalStatsByTokenId", async function () {
            await pageMinterNFT.safeMint("fakeIPFSHash", true);
            await pageMinterNFT.createCmment(0, "Hello, World!", true);
            const totalStats = await pageMinterNFT.getTotalStatsByTokenId(0);
            expect(totalStats.id).to.equal(0);
            expect(totalStats.comments).to.equal(1);
            expect(totalStats.likes).to.equal(1);
            expect(totalStats.dislikes).to.equal(0);
            // console.log("comment", comment);
        });
        /*
        it("Can't Create Comment For NFT With Disabled Comments", async function () {
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            await expect(
                pageMinterNFT.createCmment(0, "Hello, World!", true)
            ).to.be.revertedWith("No comment functionaly for this nft");
        });
        */
        it("Should Be Available getTotalStatsByTokenId", async function () {
            await pageMinterNFT.safeMint("fakeIPFSHash", true);
            await pageMinterNFT.createCmment(0, "Hello, World!", true);
            const comments = await pageMinterNFT.getCommentsByTokenId(0);
            console.log("comments", comments);
        });
        /*
        it("Should Be Burned By Owner", async function () {
            await pageMinterNFT.safeMint("fakeIPFSHash", true);
            const response = await pageMinterNFT.burn(0);
            console.log('response', response)
        });
        */
        //
        // commentActivate
        /*
        it("Should Be Burned NFT", async function () {
            await pageMinterNFT.safeMint("fakeIPFSHash", true);
            const totalSupply = await pageMinterNFT.totalSupply();
            const tokenId = Number(totalSupply) - 1; // decrement current (next) tokenId
            const owner = await pageMinterNFT.ownerOf(tokenId);
            const firstComment = await pageMinterNFT.comment(
                tokenId,
                "Hello world",
                true
            );
            // console.log("firstComment", firstComment);
            const secondComment = await pageMinterNFT.comment(
                tokenId,
                "Goodbye world",
                false
            );
            // console.log("secondComment", secondComment);
            // const comments = await pageMinterNFT.getTokenComments(tokenId);
            // console.log("comments", comments);
            const tokenComments = await pageMinterNFT.getCommentsByTokenId(
                tokenId
            );
            // console.log("tokenComments", tokenComments);
            // const comments = await pageMinterNFT.getCommentsByOwnerOf()
            // console.log('tokenId', tokenId)
            // console.log('owner', owner)
            // await pageMinterNFT.burn(tokenId)
        });
        */
    });
});
