// import { ConstructorFragment } from "@ethersproject/abi";
import { expect } from "chai";
// import { config } from "dotenv";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    PageAdmin,
    PageAdmin__factory,
    PageMinterNFT,
    PageMinterNFT__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageAdmin", async function () {
    let address: Address;
    let accounts: Signer[];
    let pageToken: PageToken;
    let pageAdmin: PageAdmin;
    let pageMinter: Address;
    let pageMinterNFT: PageMinterNFT;
    beforeEach(async function () {
        accounts = await ethers.getSigners();
        address = await accounts[0].getAddress();

        const pageAdminFactory = (await ethers.getContractFactory(
            "PageAdmin"
        )) as PageAdmin__factory;
        const pageTokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const pageMinterNFTFactory = (await ethers.getContractFactory(
            "PageMinterNFT"
        )) as PageMinterNFT__factory;

        pageAdmin = await pageAdminFactory.deploy(address);
        pageMinter = await pageAdmin.pageMinter();
        pageToken = await pageTokenFactory.deploy(pageMinter);
        pageMinterNFT = await pageMinterNFTFactory.deploy(
            pageMinter,
            pageToken.address
        );
    });
    describe("After Deployment", function () {
        describe("Before Init", function () {
            it("Can't Be Called AddSafe", async function () {
                await expect(pageAdmin.addSafe([address])).to.be.revertedWith(
                    "INIT FUNCTION NOT CALLED"
                );
            });
            it("Can't Be Called removeSafe", async function () {
                await expect(pageAdmin.removeSafe(address)).to.be.revertedWith(
                    "INIT FUNCTION NOT CALLED"
                );
            });
            it("Can't Be Called changeSafe", async function () {
                await expect(
                    pageAdmin.changeSafe(address, address)
                ).to.be.revertedWith("INIT FUNCTION NOT CALLED");
            });
            /*
            it("Can't Be Called setBurnNFTCost", async function () {
                await expect(pageAdmin.setBurnNFTCost(10)).to.be.revertedWith(
                    "INIT FUNCTION NOT CALLED"
                );
            });
            */
            it("Can't Be Called setTreasuryAddress", async function () {
                await expect(
                    pageAdmin.setTreasuryAddress(address)
                ).to.be.revertedWith("INIT FUNCTION NOT CALLED");
            });
            it("Can't Be Called setTreasuryFee", async function () {
                await expect(pageAdmin.setTreasuryFee(10)).to.be.revertedWith(
                    "INIT FUNCTION NOT CALLED"
                );
            });
            /*
            it("Can't Be Called setMinter", async function () {
                await expect(
                    pageAdmin.setMinter("fakeKey", address, 1)
                ).to.be.revertedWith("INIT FUNCTION NOT CALLED");
            });
            it("Can't Be Called setTreasuryFee", async function () {
                await expect(
                    pageAdmin.removeMinter("fakeKey")
                ).to.be.revertedWith("INIT FUNCTION NOT CALLED");
            });
            */
        });
        describe("After Init", function () {
            beforeEach(async function () {
                await pageAdmin.init(pageMinterNFT.address, pageToken.address);
            });
            it("Can't Be Init Twice", async function () {
                await expect(
                    pageAdmin.init(pageMinterNFT.address, pageToken.address)
                ).to.be.revertedWith("CAN BE CALL ONLY ONCE");
            });
            it("Can Be Add And Remove From Safe By Owner", async function () {
                await pageAdmin.addSafe([address]);
                await pageAdmin.removeSafe(address);
            });
            it("Can Be Set Treasury Another Address By Owner", async function () {
                const secondAddress = await accounts[1].getAddress();
                await pageAdmin.setTreasuryAddress(secondAddress);
            });
            it("Can Be Set Treasury Fee By Owner", async function () {
                await pageAdmin.setTreasuryFee(25);
            });
            it("Can Be Change Safe By Owner", async function () {
                const secondAddress = await accounts[1].getAddress();
                await pageAdmin.addSafe([address]);
                await pageAdmin.changeSafe(address, secondAddress);
            });
            it("Can Be Set Burn NFT Cost By Owner", async function () {
                await pageAdmin.setBurnNFTCost(50);
            });
            /*
            it("Can Be Set Burn NFT Cost By Owner", async function () {
                await pageAdmin.setMinter("test", address, 10);
            });
            it("Can Be Set Burn NFT Cost By Owner", async function () {
                await pageAdmin.setMinter("test", address, 10);
                await pageAdmin.removeMinter("test");
            });
            */
        });
    });
});
