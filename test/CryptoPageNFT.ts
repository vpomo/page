import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    PageCommentMinter,
    PageCommentMinter__factory,
    PageNFT,
    PageNFT__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageNFT", function () {
    const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
    let nft: PageNFT;
    let token: PageToken;
    let commentMinter: PageCommentMinter;
    let commentMinterFactory: PageCommentMinter__factory;
    let tokenFactory: PageToken__factory;
    let nftFactory: PageNFT__factory;
    let signers: Signer[];
    let alice: Signer;
    let aliceAddress: Address;
    let bob: Signer;
    let carol: Signer;

    // let nftFactory: PageNFT__factory;
    beforeEach(async function () {
        signers = await ethers.getSigners();
        alice = signers[0];
        aliceAddress = await alice.getAddress();
        bob = signers[1];
        carol = signers[2];
        tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        commentMinterFactory = (await ethers.getContractFactory(
            "PageCommentMinter"
        )) as PageCommentMinter__factory;
        nftFactory = (await ethers.getContractFactory(
            "PageNFT"
        )) as PageNFT__factory;
        token = await tokenFactory.deploy();
        const treasury = await alice.getAddress();
        commentMinter = await commentMinterFactory.deploy(
            treasury,
            token.address
        );
        nft = await nftFactory.deploy(
            treasury,
            token.address,
            commentMinter.address
        );
        await nft.deployed();
        // token.getRole()
        const MINTER_ROLE = ethers.utils.id("MINTER_ROLE");
        const BURNER_ROLE = ethers.utils.id("BURNER_ROLE");

        await token.grantRole(MINTER_ROLE, commentMinter.address);
        await token.grantRole(MINTER_ROLE, nft.address);
        await token.grantRole(BURNER_ROLE, nft.address);
        await token.deployed();
    });
    it("should have correct name and symbol and decimal", async function () {
        const name = await nft.name();
        const symbol = await nft.symbol();
        expect(name, "Page NFT");
        expect(symbol, "PAGE-NFT");
    });
    it("Should be available set burn fee only by owner", async function () {
        await nft.setBurnFee(1000);
        const burnFee = await nft.getBurnFee();
        expect(burnFee).to.equal(1000);
        await expect(nft.connect(signers[1]).setBurnFee(1000)).to.revertedWith(
            "Ownable: caller is not the owner"
        );
    });
    it("Should be available set mint fee only by owner", async function () {
        await nft.setMintFee(1000);
        const mintFee = await nft.getMintFee();
        expect(mintFee).to.equal(1000);
        await expect(nft.connect(signers[1]).setBurnFee(1000)).to.revertedWith(
            "Ownable: caller is not the owner"
        );
    });
    it("Should be available get treasury", async function () {
        const anotherTreasuryAddress = await signers[1].getAddress();
        await nft.setTreasury(anotherTreasuryAddress);
        const treasury = await nft.getTreasury();
        expect(treasury).to.equal(anotherTreasuryAddress);
    });
    /*
    it("should only allow owner to mint NFT", async function () {
        await nft.safeMint(aliceAddress, tokenURI);
        await expect(
            nft.connect(bob).mint(aliceAddress, tokenURI)
        ).to.be.revertedWith("Ownable: caller is not the owner");
    });
    */

    it("should only allow owner of contract to burn NFT", async function () {
        await nft.safeMint("https://ipfs.io/ipfs/fakeIPFSHash", false);
        await nft.burn(0);
        await nft.safeMint("https://ipfs.io/ipfs/fakeIPFSHash", true);
        await expect(nft.connect(bob).burn(1)).to.be.revertedWith(
            "It's possible only for owner"
        );
    });

    it("should not allow burn nonexistent token", async function () {
        await expect(nft.burn(1)).to.be.revertedWith(
            "ERC721: owner query for nonexistent token"
        );
    });

    it("should allow to get tokenURI", async function () {
        await nft.safeMint("https://ipfs.io/ipfs/fakeIPFSHash", true);
        await expect(nft.connect(bob).tokenURI(0), tokenURI);
    });

    it("should allow to call getBaseURL", async function () {
        await expect(nft.connect(bob).getBaseURL(), "https://ipfs.io/ipfs");
    });
});
