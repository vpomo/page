import {
    abi as FACTORY_ABI,
    bytecode as FACTORY_BYTECODE,
} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import bs58 from "bs58";
import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
    MockToken__factory,
    PageBank,
    PageBank__factory,
    PageComment,
    PageComment__factory,
    PageNFT,
    PageNFT__factory,
    PageToken,
    PageToken__factory,
} from "../types";

describe("PageCommentBank", function () {
    const commentText =
        "0x" +
        bs58
            .decode("QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB")
            .slice(2)
            .toString("hex");
    const collectionName =
        "0xb0379d0047424de9fa43620fd073532a0135cf4a85e8d7bc9ca8aae9bcd8cc4c";
    let bank: PageBank;
    let token: PageToken;
    let nft: PageNFT;
    let comment: PageComment;
    let signers: Signer[];
    let alice: Address;
    let bob: Address;
    let deployer: Address;

    beforeEach(async function () {
        signers = await ethers.getSigners();
        alice = await signers[0].getAddress();
        deployer = await signers[signers.length - 1].getAddress();
        bob = await signers[1].getAddress();

        const bankFactory = (await ethers.getContractFactory(
            "PageBank"
        )) as PageBank__factory;
        const tokenFactory = (await ethers.getContractFactory(
            "PageToken"
        )) as PageToken__factory;
        const mockTokenFactory = (await ethers.getContractFactory(
            "MockToken"
        )) as MockToken__factory;
        const nftFactory = (await ethers.getContractFactory(
            "PageNFT"
        )) as PageNFT__factory;
        const commentFactory = (await ethers.getContractFactory(
            "PageComment"
        )) as PageComment__factory;
        const uniswapV3FactoryFactory = new ethers.ContractFactory(
            FACTORY_ABI,
            FACTORY_BYTECODE,
            signers[signers.length - 1]
        );

        const uniswapV3Factory = await uniswapV3FactoryFactory.deploy();
        const weth = await mockTokenFactory.deploy(18);
        const usdt = await mockTokenFactory.deploy(6);

        bank = await bankFactory.deploy();
        token = await tokenFactory.deploy();
        nft = await nftFactory.deploy();
        comment = await commentFactory.deploy();

        await token.initialize(deployer, bank.address);
        await token.deployed();
        await bank.initialize(deployer, 1000);
        await comment.initialize(bank.address);
        await bank.setToken(token.address);
        await bank.grantRole(ethers.utils.id("MINTER_ROLE"), token.address);
        await bank.grantRole(ethers.utils.id("MINTER_ROLE"), nft.address);
        await bank.grantRole(ethers.utils.id("BURNER_ROLE"), nft.address);
        await bank.grantRole(ethers.utils.id("MINTER_ROLE"), comment.address);
        await nft.initialize(
            comment.address,
            bank.address,
            "https://ipfs.io/ipfs"
        );
    });

    it("Should Be Allowed Check Balance", async function () {
        await nft.safeMint(
            alice,
            "https://ipfs.io/ipfs/fakeHash",
            collectionName
        );
        let balance = await bank.balance();
        expect(Number(balance)).to.be.equal(0);
        await nft
            .connect(signers[1])
            .safeMint(alice, "https://ipfs.io/ipfs/fakeHash", collectionName);
        balance = await bank.balance();
        expect(Number(balance)).to.be.greaterThan(0);
    });

    it("Should Be Allowed Withdraw", async function () {
        await expect(bank.withdraw(10000000000000)).to.be.revertedWith(
            "Not enough balance"
        );
        await nft
            .connect(signers[5])
            .safeMint(alice, "https://ipfs.io/ipfs/fakeHash", collectionName);
        const balance = await bank.connect(signers[0]).balance();
        await bank.withdraw(1);
    });

    it("Should Set Static USDT / PAGE Price", async function () {
        await bank.setStaticUSDTPAGEPrice(200);
        expect(await bank.staticUSDTPAGEPrice()).to.be.equal(200);
        expect(await bank.getUSDTPAGEPrice()).to.be.equal(100);
    });

    it("Should Set Static WETH / USDT Price", async function () {
        await bank.setStaticWETHUSDTPrice(5000);
        expect(await bank.staticWETHUSDTPrice()).to.be.equal(5000);
    });
});
