import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    PageNFT,
    PageNFT__factory,
    PageToken,
    PageTokenMinter,
    PageTokenMinter__factory,
    PageToken__factory,
} from "../types";

describe("PageTokenMinter", function () {
    const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
    let tokenMinter: PageTokenMinter;
    let tokenMinterFactory: PageTokenMinter__factory;
    let signers: Signer[];
    let alice: Signer;
    let aliceAddress: Address;
    let bob: Signer;
    let bobAddress: Address;
    let carol: Signer;
    let carolAddress: Address;

    beforeEach(async function () {
        const nftFactory = (await ethers.getContractFactory(
            "PageNFT"
        )) as PageNFT__factory;
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const nft: PageNFT = await nftFactory.deploy();
        const token: PageToken = await tokenFactory.deploy();
        tokenMinterFactory = (await ethers.getContractFactory(
            "PageTokenMinter"
        )) as PageTokenMinter__factory;
        tokenMinter = await tokenMinterFactory.deploy(token.address);

        signers = await ethers.getSigners();
        alice = signers[0];
        aliceAddress = await alice.getAddress();
        bob = signers[1];
        bobAddress = await bob.getAddress();
        carol = signers[2];
        carolAddress = await carol.getAddress();
        await tokenMinter.deployed();
    });

    it("should only allow owner to mint token", async function () {
        const role =
            "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
        const message = `AccessControl: account ${aliceAddress.toLocaleLowerCase()} is missing role ${role}`;
        await expect(tokenMinter.mint(aliceAddress, "1000")).to.be.revertedWith(
            message
        );
    });

    it("should only allow owner to burn token", async function () {
        const role =
            "0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848";
        const message = `AccessControl: account ${aliceAddress.toLocaleLowerCase()} is missing role ${role}`;
        await expect(tokenMinter.burn(aliceAddress, "1000")).to.be.revertedWith(
            message
        );
    });
});
