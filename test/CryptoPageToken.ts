import { expect } from "chai";
import { Signer } from "ethers";
import { ethers, waffle } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import { PageToken, PageToken__factory } from "../types";

describe("PageToken", function () {
    let token: PageToken;
    // let tokenMinter: PageTokenMinter;
    // let tokenMinterFactory: PageTokenMinter__factory;
    let signers: Signer[];
    let alice: Address;
    let bob: Address;
    let carol: Address;
    // before(async function () {
    // });

    beforeEach(async function () {
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory; // tokenMinterFactory = await ethers.getContractFactory("PageTokenMinter");
        signers = await ethers.getSigners();
        alice = await signers[0].getAddress();
        bob = await signers[1].getAddress();
        carol = await signers[2].getAddress();
        // tokenMinter = await tokenMinterFactory.deploy()
        token = await tokenFactory.deploy();
        await token.deployed();
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
        ).to.be.revertedWith("Ownable: caller is not the owner");
        const totalSupply = await token.totalSupply();
        const aliceBal = await token.balanceOf(alice);
        const bobBal = await token.balanceOf(bob);
        const carolBal = await token.balanceOf(carol);
        expect(totalSupply).to.equal("1100");
        expect(aliceBal).to.equal("100");
        expect(bobBal).to.equal("1000");
        expect(carolBal).to.equal("0");
    });
    /*
    it("should only allow owner to burn token", async function () {
        await token.mint(alice, "1000");
        await token.mint(bob, "2000");
        await token.burn(alice, "1000");
        await expect(
            await token.connect(signers[1]).burn(alice, "1000")
        ).to.be.revertedWith("Ownable: caller is not the owner");
        const totalSupply = await token.totalSupply();
        const aliceBal = await token.balanceOf(alice);
        const bobBal = await token.balanceOf(bob);
        const carolBal = await token.balanceOf(carol);
        expect(totalSupply).to.equal("1100");
        expect(aliceBal).to.equal("100");
        expect(bobBal).to.equal("1000");
        expect(carolBal).to.equal("0");
    });
    */

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
        token.on("Staked", (event) => {
            console.log("event", event);
        });
        await token.stake(amount);
        await ethers.provider.send("evm_increaseTime", [ 3600 * 3000 ]);
        await ethers.provider.send("evm_mine", []);
        await ethers.provider.send("evm_increaseTime", [ 3600 * 3000 ]);
        await ethers.provider.send("evm_mine", []);
        // await token.hasStake(alice);
        await token.stake(amount);
        await ethers.provider.send("evm_increaseTime", [ 3600 * 3000 ]);
        await ethers.provider.send("evm_mine", []);

        await token.stake(amount);
        await ethers.provider.send("evm_increaseTime", [ 3600 * 3000 ]);
        await ethers.provider.send("evm_mine", []);        
        const blockNumBefore = await ethers.provider.getBlockNumber();
        const blockBefore = await ethers.provider.getBlock(blockNumBefore);
        const timestampBefore = blockBefore.timestamp;
        let stakeSummary = await token.hasStake(alice);
        const stake = stakeSummary.stakes[0];        
        // let expected = 1000-200+100+Number(stake.claimable)
        // console.log('expected', expected)
        // const sevenDays = 7 * 24 * 60 * 60;

        // await ethers.provider.send("evm_increaseTime", [
            // timestampBefore + sevenDays,
        // ]);
        await token.withdrawStake(Number(amount) * 1, 0);
        balance = await token.balanceOf(alice);
        console.log('balance', balance.toNumber())

        await token.withdrawStake(Number(amount) / 2, 1);

        await expect(token.withdrawStake(Number(amount) * 1.5, 1)).to.revertedWith('Staking: Cannot withdraw more than you have staked');
        // const reward = await token.calculateStakeReward(0);
        // console.log("reward", reward);
        // const stake = await token.hasStake(alice);
        // console.log("totalAmount", stake.totalAmount.toNumber());
        // Assert on the emittedevent using truffleassert
        // This will capture the event and inside the event callback we can use assert on the values returned
        await expect(token.stake(100000)).to.revertedWith('PageToken: Cannot stake more than you own');

        await expect(token.stake(0)).to.revertedWith('Cannot stake nothing');

        token.on(
            "Staked",
            (ev) => {
                console.log("event", ev);
                console.log("event.amount", ev.amount);
                console.log("event.index", ev.index);
                // In here we can do our assertion on the ev variable (its the event and will contain the values we emitted)
                // expect(ev.amount, stake_amount, "Stake amount in event was not correct");
                // expect(ev.index, 1, "Stake index was not correct");
                return true;
            }
            // "Stake event should have triggered");
        );
    });
});
