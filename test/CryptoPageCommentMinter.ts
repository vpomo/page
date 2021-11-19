import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    PageComment,
    PageCommentMinter,
    PageCommentMinter__factory,
    PageComment__factory,
    PageNFT,
    PageNFTMinter,
    PageNFTMinter__factory,
    PageNFT__factory,
    PageToken,
    PageTokenMinter,
    PageTokenMinter__factory,
    PageToken__factory,
} from "../types";

describe("PageCommentMinter", async function () {
    const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
    let address: Address;
    let accounts: Signer[];
    let token: PageToken;
    let tokenMinter: PageTokenMinter;
    let comment: PageComment;
    let commentMinter: PageCommentMinter;
    let nft: PageNFT;
    let nftMinter: PageNFTMinter;
    beforeEach(async function () {
        accounts = await ethers.getSigners();
        address = await accounts[0].getAddress();
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const tokenMinterFactory = (await ethers.getContractFactory(
            "PageTokenMinter"
        )) as PageTokenMinter__factory;
        const commentFactory = (await ethers.getContractFactory(
            "PageComment"
        )) as PageComment__factory;
        const commentMinterFactory = (await ethers.getContractFactory(
            "PageCommentMinter"
        )) as PageCommentMinter__factory;
        const nftFactory = (await ethers.getContractFactory(
            "PageNFT"
        )) as PageNFT__factory;
        const nftMinterFactory = (await ethers.getContractFactory(
            "PageNFTMinter"
        )) as PageNFTMinter__factory;
        token = await tokenFactory.deploy();
        tokenMinter = await tokenMinterFactory.deploy(token.address);
        comment = await commentFactory.deploy();
        commentMinter = await commentMinterFactory.deploy();
        nft = await nftFactory.deploy();
        nftMinter = await nftMinterFactory.deploy(
            address,
            tokenMinter.address,
            nft.address,
            commentMinter.address
        );
        /*
        console.log("tokenMinter.address", tokenMinter.address);
        console.log("nft.address", nft.address);
        console.log("commentMinter.address", commentMinter.address);
        nftMinter = await nftMinterFactory.deploy(
            address,
            tokenMinter.address,
            nft.address,
            commentMinter.address
        );
        */
    });

    describe("After Deployment", function () {
        it("Should be available check activated on any ERC721 contract", async function () {
            const activated = await commentMinter.activated(nft.address, 0);
            expect(activated).to.equal(false);
        });
        it("Should be allow activate any TokenId from any ERC721 contract", async function () {
            await nft.mint(address, tokenURI);
            await commentMinter.activateComment(nft.address, 0);
        });
        it("Should be allow activate any TokenId from any ERC721 contract", async function () {
            await nft.mint(address, tokenURI);
            await commentMinter.createComment(
                nft.address,
                0,
                address,
                "Hello, world!",
                true
            );
        });
        it("Should be allow activate any TokenId from any ERC721 contract", async function () {
            await nft.mint(address, tokenURI);
            await commentMinter.activateComment(nft.address, 0);
            const activated = await commentMinter.createComment(
                nft.address,
                0,
                address,
                "Hello, world!",
                true
            );
            // expect(activated).to.equal(false);
            // console.log("activated", activated);
        });
    });

    /*
    describe("After Deployment", function () {
        it("Should be available check activated on any ERC721 contract", async function () {
            const activated = await commentMinter.activated(nft.address, 0);
            expect(activated).to.equal(false);
        });
        it("Should be available check activated on any ERC721 contract", async function () {
            const activated = await commentMinter.activateComment(
                nft.address,
                0
            );
            expect(activated).to.equal(false);
        });
        it("Should be available check activated on any ERC721 contract", async function () {
            const activated = await commentMinter.activated(nft.address, 0);
            expect(activated).to.equal(false);
        });
    });
    */
});

//             await nft.mint(address, tokenURI);
// activated = await pageCommentMinter.activated(nft.address, 0);
// expect(activated).to.equal(false);
