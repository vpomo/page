import { expect } from "chai";
import { Signer } from "ethers";
import { ethers, waffle } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import { PageToken, PageToken__factory } from "../types";

describe("PageToken", function () {
    let token: PageToken;
    let signers: Signer[];
    let alice: Address;
    let bob: Address;
    let carol: Address;

    beforeEach(async function () {
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        signers = await ethers.getSigners();
        alice = await signers[0].getAddress();
        console.log("alice", alice);
        bob = await signers[1].getAddress();
        carol = await signers[2].getAddress();
        token = await tokenFactory.deploy();
        await token.deployed();
        const MINTER_ROLE = ethers.utils.id("MINTER_ROLE");
        await token.grantRole(MINTER_ROLE, alice);
    });

    it("should have correct name and symbol and decimal", async function () {
        const name = await token.name();
        const symbol = await token.symbol();
        const decimals = await token.decimals();
        expect(name, "PageToken");
        expect(symbol, "PAGE");
        expect(decimals, "18");
    });

    it("should only allow owner to mint token", async function () {
        await token.mint(alice, "100");
        await token.mint(bob, "1000");
        await expect(
            token.connect(signers[1]).mint(carol, "1000")
        ).to.be.revertedWith(
            `AccessControl: account ${bob.toLocaleLowerCase()} is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6`
        );
        const totalSupply = await token.totalSupply();
        const aliceBal = await token.balanceOf(alice);
        const bobBal = await token.balanceOf(bob);
        const carolBal = await token.balanceOf(carol);
        expect(totalSupply).to.equal("1100");
        expect(aliceBal).to.equal("100");
        expect(bobBal).to.equal("1000");
        expect(carolBal).to.equal("0");
    });

    it("should supply token transfers properly", async function () {
        await token.mint(alice, "100");
        await token.mint(bob, "1000");
        await token.transfer(carol, "10");
        await token.connect(signers[1]).transfer(carol, "100", {
            from: bob,
        });
        const totalSupply = await token.totalSupply();
        const aliceBalance = await token.balanceOf(alice);
        const bobBalance = await token.balanceOf(bob);
        const carolBalance = await token.balanceOf(carol);
        expect(totalSupply, "1100");
        expect(aliceBalance, "90");
        expect(bobBalance, "900");
        expect(carolBalance, "110");
    });

    it("should fail if you try to do bad transfers", async function () {
        await token.mint(alice, "100");
        await expect(token.transfer(carol, "110")).to.be.revertedWith(
            "ERC20: transfer amount exceeds balance"
        );
        await expect(
            token.connect(signers[1]).transfer(carol, "1", { from: bob })
        ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
    });

    it("Staking 10x2", async function () {
        const amount = "10";
        await token.mint(alice, Number(amount) * 5);
        let balance = await token.balanceOf(alice);
        await token.stake(amount);
        await ethers.provider.send("evm_increaseTime", [3600 * 3000]);
        await ethers.provider.send("evm_mine", []);
        await ethers.provider.send("evm_increaseTime", [3600 * 3000]);
        await ethers.provider.send("evm_mine", []);
        await token.stake(amount);
        await ethers.provider.send("evm_increaseTime", [3600 * 3000]);
        await ethers.provider.send("evm_mine", []);

        await token.stake(amount);
        await ethers.provider.send("evm_increaseTime", [3600 * 3000]);
        await ethers.provider.send("evm_mine", []);
        const blockNumBefore = await ethers.provider.getBlockNumber();
        const blockBefore = await ethers.provider.getBlock(blockNumBefore);
        const timestampBefore = blockBefore.timestamp;
        const stakeSummary = await token.hasStake(alice);
        const stake = stakeSummary.stakes[0];
        await token.withdrawStake(Number(amount) * 1, 0);
        balance = await token.balanceOf(alice);
        await token.withdrawStake(Number(amount) / 2, 1);
        await expect(
            token.withdrawStake(Number(amount) * 1.5, 1)
        ).to.revertedWith("Staking: Cannot withdraw more than you have staked");
        await expect(token.stake(100000)).to.revertedWith(
            "PageToken: Cannot stake more than you own"
        );
        await expect(token.stake(0)).to.revertedWith("Cannot stake nothing");
    });
});
