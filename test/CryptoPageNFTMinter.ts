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

describe("PageNFTMinter", function () {
    const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
    let address: Address;
    let signers: Signer[];
    let token: PageToken;
    let tokenMinter: PageTokenMinter;
    let comment: PageComment;
    let commentMinter: PageCommentMinter;
    let nft: PageNFT;
    let nftMinter: PageNFTMinter;

    // let nftFactory: PageNFT__factory;
    beforeEach(async function () {
        signers = await ethers.getSigners();
        address = await signers[0].getAddress();
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
        nft = await nftFactory.deploy();
        comment = await commentFactory.deploy();
        commentMinter = await commentMinterFactory.deploy();
        tokenMinter = await tokenMinterFactory.deploy(token.address);

        const MINTER_ROLE = ethers.utils.id("MINTER_ROLE");
        // console.log("MINTER_ROLE", MINTER_ROLE);
        const BURNER_ROLE = ethers.utils.id("BURNER_ROLE");
        // console.log("BURNER_ROLE", BURNER_ROLE);

        nftMinter = await nftMinterFactory.deploy(
            address,
            tokenMinter.address,
            nft.address,
            commentMinter.address
        );

        await nftMinter.deployed();
        await tokenMinter.grantRole(MINTER_ROLE, nftMinter.address);
        await tokenMinter.grantRole(BURNER_ROLE, nftMinter.address);
        await token.transferOwnership(tokenMinter.address);
        await nft.transferOwnership(nftMinter.address);
    });

    describe("After Deployment", function () {
        it("Should be available safeMint", async function () {
            await nftMinter.safeMint("https://ipfs.io/ipfs/IPFSHash", false);
            let activated = await commentMinter.activated(nft.address, 0);
            expect(activated).to.equal(false);
            await nftMinter.safeMint("https://ipfs.io/ipfs/IPFSHash", true);
            activated = await commentMinter.activated(nft.address, 1);
            expect(activated).to.equal(true);
        });

        it("Should be burned by owner", async function () {
            await nftMinter.safeMint("https://ipfs.io/ipfs/IPFSHash", false);
            await nftMinter.burn(0);
        });
        it("Should not be burned by another account", async function () {
            await nftMinter.safeMint("https://ipfs.io/ipfs/IPFSHash", false);
            await expect(
                nftMinter.connect(signers[1]).burn(0)
            ).to.be.revertedWith("It's possible only for owner");
        });
        it("Should be available burn fee", async function () {
            const burnFee = await nftMinter.getBurnFee();
            expect(burnFee).to.equal(0);
        });
        it("Should be available mint fee", async function () {
            const mintFee = await nftMinter.getMintFee();
            expect(mintFee).to.equal(1000);
        });
        it("Should be available treasury", async function () {
            const treasury = await nftMinter.getTreasury();
            expect(treasury).to.equal(address);
        });
        it("Should be available set burn fee only by owner", async function () {
            await nftMinter.setBurnFee(1000);
            const burnFee = await nftMinter.getBurnFee();
            expect(burnFee).to.equal(1000);
            await expect(
                nftMinter.connect(signers[1]).setBurnFee(1000)
            ).to.revertedWith("Ownable: caller is not the owner");
        });
        it("Should be available set mint fee only by owner", async function () {
            await nftMinter.setMintFee(1000);
            const mintFee = await nftMinter.getMintFee();
            expect(mintFee).to.equal(1000);
            await expect(
                nftMinter.connect(signers[1]).setBurnFee(1000)
            ).to.revertedWith("Ownable: caller is not the owner");
        });
        it("Should be available get treasury", async function () {
            const anotherTreasuryAddress = await signers[1].getAddress();
            await nftMinter.setTreasury(anotherTreasuryAddress);
            const treasury = await nftMinter.getTreasury();
            expect(treasury).to.equal(anotherTreasuryAddress);
        });
    });
});
