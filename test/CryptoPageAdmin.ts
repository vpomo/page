import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    PageAdmin,
    PageAdmin__factory,
    PageCommentMinter,
    PageCommentMinter__factory,
    PageComment__factory,
    PageNFT,
    PageNFT__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageNFTMinter", function () {
    const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
    let address: Address;
    let signers: Signer[];
    let admin: PageAdmin;
    let token: PageToken;
    let commentMinter: PageCommentMinter;
    let nft: PageNFT;

    beforeEach(async function () {
        signers = await ethers.getSigners();
        address = await signers[0].getAddress();
        const adminFactory = (await ethers.getContractFactory(
            "PageAdmin"
        )) as PageAdmin__factory;
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const commentFactory = (await ethers.getContractFactory(
            "PageComment"
        )) as PageComment__factory;
        const commentMinterFactory = (await ethers.getContractFactory(
            "PageCommentMinter"
        )) as PageCommentMinter__factory;
        const nftFactory = (await ethers.getContractFactory(
            "PageNFT"
        )) as PageNFT__factory;
        token = await tokenFactory.deploy();
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
        await token.grantRole(MINTER_ROLE, nft.address);
        await token.grantRole(BURNER_ROLE, nft.address);
        admin = await adminFactory.deploy(address, token.address, nft.address);
        await nft.transferOwnership(admin.address);
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
