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

describe("PageToken", async function () {
    const tokenAmount = String(10 * 10 ** 18);
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
        await pageAdmin.init(pageMinterNFT.address, pageToken.address);
    });
    describe("After Deployment", function () {
        it("Should Increase NFT Owner PageToken Balance When Minting NFT", async function () {
            expect(await pageToken.balanceOf(address)).to.equal(0);
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            expect(await pageToken.balanceOf(address)).to.equal(tokenAmount);
        });
        it("Should Be Increasable Total Supply", async function () {
            expect(await pageToken.totalSupply()).to.equal(0);
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            expect(await pageToken.totalSupply()).to.equal(tokenAmount);
        });
        it("Should Be Increased Balance After Mint", async function () {
            const amount = ethers.utils.parseUnits("10.0");

            expect(await pageToken.isEnoughOn(address, amount)).to.equal(false);
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            expect(await pageToken.isEnoughOn(address, amount)).to.equal(true);
        });
        it("Should Be Right Balances After Safe Withdraw", async function () {
            const secondAddress = await accounts[1].getAddress();
            const amount = ethers.utils.parseUnits("5.0");
            const decimals = await pageToken.decimals();

            await pageAdmin.addSafe([address]);
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            await pageToken.safeWithdraw(address, secondAddress, amount);
            let balance = await pageToken.balanceOf(secondAddress);
            let formatBalance = ethers.utils.formatUnits(balance, decimals);
            expect(formatBalance).to.equal("5.0");

            balance = await pageToken.balanceOf(address);
            formatBalance = ethers.utils.formatUnits(balance, decimals);
            expect(formatBalance).to.equal("5.0");
        });
        it("Should Be Burned", async function () {
            const amount = ethers.utils.parseUnits("5.0");

            expect(await pageToken.isEnoughOn(address, amount)).to.equal(false);
            await pageMinterNFT.safeMint("fakeIPFSHash", false);
            await pageToken.burn(5);
            expect(await pageToken.isEnoughOn(address, amount)).to.equal(true);
        });
    });
});
