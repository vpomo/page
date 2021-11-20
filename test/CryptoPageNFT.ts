import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import { PageNFT, PageNFT__factory } from "../types";

describe("PageNFT", function () {
    const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
    let nft: PageNFT;
    let nftFactory: PageNFT__factory;
    let signers: Signer[];
    let alice: Signer;
    let aliceAddress: Address;
    let bob: Signer;
    let carol: Signer;

    // let nftFactory: PageNFT__factory;
    beforeEach(async function () {
        nftFactory = (await ethers.getContractFactory(
            "PageNFT"
        )) as PageNFT__factory;
        nft = await nftFactory.deploy();
        signers = await ethers.getSigners();
        alice = signers[0];
        aliceAddress = await alice.getAddress();
        bob = signers[1];
        carol = signers[2];
        await nft.deployed();
    });

    it("should have correct name and symbol and decimal", async function () {
        const name = await nft.name();
        const symbol = await nft.symbol();
        expect(name, "Page NFT");
        expect(symbol, "PAGE-NFT");
    });

    it("should only allow owner to mint NFT", async function () {
        await nft.mint(aliceAddress, tokenURI);
        await expect(
            nft.connect(bob).mint(aliceAddress, tokenURI)
        ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should only allow owner of contract to burn NFT", async function () {
        await nft.mint(aliceAddress, tokenURI);
        await nft.burn(0);
        await nft.mint(aliceAddress, tokenURI);
        await expect(nft.connect(bob).burn(1)).to.be.revertedWith(
            "Ownable: caller is not the owner"
        );
    });

    it("should not allow burn nonexistent token", async function () {
        // await nft.mint(aliceAddress, tokenURI);
        // await nft.burn(0);
        await expect(nft.burn(1)).to.be.revertedWith(
            "ERC721: owner query for nonexistent token"
        );
    });

    it("should allow to get tokenURI", async function () {
        await nft.mint(aliceAddress, tokenURI);
        await expect(nft.connect(bob).tokenURI(0), tokenURI);
    });

    it("should allow to call getBaseURL", async function () {
        await expect(nft.connect(bob).getBaseURL(), "https://ipfs.io/ipfs");
    });
});
