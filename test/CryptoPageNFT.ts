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
        // const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
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
    /*
    it("should supply token transfers properly", async function () {
        await this.token.mint(this.alice.address, "100");
        await this.token.mint(this.bob.address, "1000");
        await this.token.transfer(this.carol.address, "10");
        await this.token.connect(this.bob).transfer(this.carol.address, "100", {
            from: this.bob.address,
        });
        const totalSupply = await this.token.totalSupply();
        const aliceBalance = await this.token.balanceOf(this.alice.address);
        const bobBalance = await this.token.balanceOf(this.bob.address);
        const carolBalance = await this.token.balanceOf(this.carol.address);
        expect(totalSupply, "1100");
        expect(aliceBalance, "90");
        expect(bobBalance, "900");
        expect(carolBalance, "110");
    });

    it("should fail if you try to do bad transfers", async function () {
        await this.token.mint(this.alice.address, "100");
        await expect(
            this.token.transfer(this.carol.address, "110")
        ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
        await expect(
            this.token
                .connect(this.bob)
                .transfer(this.carol.address, "1", { from: this.bob.address })
        ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
    });
    */
});
