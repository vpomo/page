import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    PageAdmin,
    PageAdmin__factory,
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
    let admin: PageAdmin;
    let token: PageToken;
    let tokenMinter: PageTokenMinter;
    let comment: PageComment;
    let commentMinter: PageCommentMinter;
    let nft: PageNFT;
    let nftMinter: PageNFTMinter;

    beforeEach(async function () {
        signers = await ethers.getSigners();
        address = await signers[0].getAddress();
        const adminFactory = (await ethers.getContractFactory(
            "PageAdmin"
        )) as PageAdmin__factory;
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
        const BURNER_ROLE = ethers.utils.id("BURNER_ROLE");
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
        admin = await adminFactory.deploy(
            address,
            tokenMinter.address,
            nftMinter.address
        );
        await nftMinter.transferOwnership(admin.address);
    });

    describe("After Deployment", function () {
        it("Should be available set only valid treasury only for owner", async function () {
            const anotherAddress = await signers[1].getAddress();
            const nullAddress = "0x0000000000000000000000000000000000000000";
            await admin.setTreasury(anotherAddress);
            await expect(admin.setTreasury(nullAddress)).to.revertedWith("");
        });

        it("Should be available set burn fee only for owner", async function () {
            await admin.setBurnFee(1000);
        });

        it("Should be available set mint fee < 3000 and > 100 for owner", async function () {
            await admin.setMintFee(3000);
            await expect(admin.setMintFee(9)).to.revertedWith(
                "setMintFee: minimum mint fee percent is 0.1%"
            );
            await expect(admin.setMintFee(3001)).to.revertedWith(
                "setMintFee: maximum mint fee percent is 30%"
            );
        });

        it("Should be available set burn fee < 3000 and > 100 for owner", async function () {
            await admin.setBurnFee(3000);
            await expect(admin.setBurnFee(9)).to.revertedWith(
                "setBurnFee: minimum burn fee percent is 0.1%"
            );
            await expect(admin.setBurnFee(3001)).to.revertedWith(
                "setBurnFee: maximum burn fee percent is 30%"
            );
        });
    });
});
