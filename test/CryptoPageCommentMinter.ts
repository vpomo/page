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

describe("PageCommentMinter", async function () {
    const tokenURI = "https://ipfs.io/ipfs/fakeIPFSHash";
    let address: Address;
    let accounts: Signer[];
    let token: PageToken;
    let commentMinter: PageCommentMinter;
    let nft: PageNFT;
    beforeEach(async function () {
        accounts = await ethers.getSigners();
        address = await accounts[0].getAddress();
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
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
        await nft.deployed();
    });

    describe("After Deployment", function () {
        it("Should be available check activated on any ERC721 contract", async function () {
            const activated = await commentMinter.activated(nft.address, 0);
            expect(activated).to.equal(false);
        });
        it("Should Be Allowed Existing Contract", async function () {
            await nft.safeMint(tokenURI, true);
            await commentMinter.getContract(nft.address, 0);
        });
        it("Should Be Not Allowed Existing Contract", async function () {
            await expect(
                commentMinter.getContract(nft.address, 0)
            ).to.be.revertedWith("NFT contract does not exist");
        });
        it("Should be allow activate any TokenId from any ERC721 contract", async function () {
            await nft.safeMint(tokenURI, false);
            await commentMinter.activateComments(nft.address, 0);
        });
        it("Should be allow check comments existing", async function () {
            await nft.safeMint(tokenURI, false);
            await commentMinter.hasComments(nft.address, 0);
        });
        it("Should be allow activate any TokenId from any ERC721 contract", async function () {
            await nft.safeMint(tokenURI, true);
            await commentMinter.createComment(
                nft.address,
                0,
                address,
                "Hello, world!",
                true
            );
        });
        it("Should be allow activate any TokenId from any ERC721 contract", async function () {
            await nft.safeMint(tokenURI, false);
            const activated = await commentMinter.createComment(
                nft.address,
                0,
                address,
                "Hello, world!",
                true
            );
        });
    });
});
