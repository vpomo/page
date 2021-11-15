// import { ConstructorFragment } from "@ethersproject/abi";
import { expect } from "chai";
// import { config } from "dotenv";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    PageAdmin,
    PageAdmin__factory,
    PageMinter,
    PageMinterNFT,
    PageMinterNFT__factory,
    PageMinter__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageMinter", async function () {
    let address: Address;
    let pageMinterAddress: Address;
    let accounts: Signer[];
    let pageAdmin: PageAdmin;
    let pageToken: PageToken;
    let pageMinter: PageMinter;
    let pageMinterNFT: PageMinterNFT;
    beforeEach(async function () {
        const pageAdminFactory = (await ethers.getContractFactory(
            "PageAdmin"
        )) as PageAdmin__factory;
        const pageMinterFactory = (await ethers.getContractFactory(
            "PageMinter"
        )) as PageMinter__factory;
        const pageTokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const pageMinterNFTFactory = (await ethers.getContractFactory(
            "PageMinterNFT"
        )) as PageMinterNFT__factory;
        accounts = await ethers.getSigners();
        address = await accounts[0].getAddress();
        pageAdmin = await pageAdminFactory.deploy(address);
        pageMinterAddress = await pageAdmin.pageMinter();
        pageMinter = await pageMinterFactory.deploy(pageAdmin.address, address);
        pageToken = await pageTokenFactory.deploy(pageMinterAddress);
        pageMinterNFT = await pageMinterNFTFactory.deploy(
            pageMinterAddress,
            pageToken.address
        );
        await pageAdmin.init(pageMinterNFT.address, pageToken.address);
    });

    describe("After Deployment", function () {
        /*
        it("Can't Be Minted Tokens", async function () {
            await pageMinter.mint("NFT_CREATE", [address]);
            await expect(
                await pageMinter.burn(address, 100)
            ).to.be.revertedWith("onlyAdmin: caller is not the admin");
        });
        */
        /*
        it("Can Be Get Burn NFT Cost", async function () {
            const cost = await pageMinter.getBurnNFTCost();
            console.log("cost", cost);
        });
        
        it("Can Be Get Admin Public", async function () {
            const admin = await pageMinter.getAdmin();
            console.log("admin", admin);
        });
        
        it("Can Be Get Page Token Public", async function () {
            const pageTokenAddress = await pageMinter.getPageToken();
            console.log("pageToken", pageTokenAddress);
        });
        */
        /*
        it("Should Be Burned If Balance Enought", async function () {
            // const secondAddress = await accounts[1].getAddress();
            const amount = ethers.utils.parseUnits("5.0");
            await pageAdmin.addSafe([address]);
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            pageAdmin.pageMinter();
            // pageMinter.mint(address, address);
            // await pageMinter.burn(address, amount);
            expect(await pageToken.isEnoughOn(address, amount)).to.equal(true);
        });
        */
    });
    /*
    describe("After Deployment", function () {
        it("Should Be Burned If Balance Enought", async function () {
            // const secondAddress = await accounts[1].getAddress();
            const amount = ethers.utils.parseUnits("5.0");
            await pageAdmin.addSafe([address]);
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            pageAdmin.pageMinter()
            // pageMinter.mint(address, address);
            // await pageMinter.burn(address, amount);
            expect(await pageToken.isEnoughOn(address, amount)).to.equal(true);
        });
    });
    */
});
