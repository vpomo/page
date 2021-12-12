import {
    abi as FACTORY_ABI,
    bytecode as FACTORY_BYTECODE,
} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import { abi as POOL_ABI } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";
import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    MockToken,
    MockToken__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageToken", function () {
    const MINTER_ROLE = ethers.utils.id("MINTER_ROLE");
    const BURNER_ROLE = ethers.utils.id("BURNER_ROLE");
    let token: PageToken;
    let mockToken: MockToken;
    let signers: Signer[];
    let alice: Address;
    let bob: Address;
    let carol: Address;

    beforeEach(async function () {
        signers = await ethers.getSigners();
        alice = await signers[0].getAddress();
        bob = await signers[1].getAddress();
        carol = await signers[2].getAddress();
        const treasury = await signers[9].getAddress();
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const mockTokenFactory = (await ethers.getContractFactory(
            "MockToken"
        )) as MockToken__factory;
        const factoryFactory = new ethers.ContractFactory(
            FACTORY_ABI,
            FACTORY_BYTECODE,
            signers[0]
        );
        const factory = await factoryFactory.deploy();
        mockToken = await mockTokenFactory.deploy();
        token = await tokenFactory.deploy(treasury);
        await token.deployed();
        await factory.createPool(factory.address, mockToken.address, 3000);
        const pool = await factory.getPool(
            factory.address,
            mockToken.address,
            3000
        );
        const poolContract = await ethers.getContractAt(POOL_ABI, pool);
        // console.log('price', ethers.utils.parseEther("79228162514264337593543950336"))
        await poolContract.initialize(ethers.utils.parseEther("792281333999")); // 79228162514264337593543950336
        await token.setPool(pool);
        await token.grantRole(MINTER_ROLE, token.address);
        await token.grantRole(MINTER_ROLE, alice);
        await token.grantRole(BURNER_ROLE, alice);
    });

    it("should have correct name and symbol and decimal", async function () {
        const name = await token.name();
        const symbol = await token.symbol();
        const decimals = await token.decimals();
        expect(name, "PageToken");
        expect(symbol, "PAGE");
        expect(decimals, "18");
    });

    it("Should Allow To Mint Only For Owner", async function () {
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
        expect(totalSupply).to.equal("10000000000000000000001100");
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

    it("should be available price", async function () {
        const price = await token.getPrice();
        console.log("price", price.toString());
        expect(price.toString(), "10");
    });

    it("should be burnable only for owner", async function () {
        const role =
            "0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848";
        await token.mint(alice, "100");
        await token.burn(alice, "50");
        await expect(
            token.connect(signers[1]).burn(alice, "50", { from: bob })
        ).to.be.revertedWith(
            `AccessControl: account ${bob.toLowerCase()} is missing role ${role}`
        );
    });
});
