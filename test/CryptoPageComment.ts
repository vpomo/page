// import { ConstructorFragment } from "@ethersproject/abi";
import { expect } from "chai";
// import { config } from "dotenv";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import { PageComment, PageComment__factory } from "../types";

describe("PageComment", async function () {
    let address: Address;
    let accounts: Signer[];
    let pageComment: PageComment;
    beforeEach(async function () {
        accounts = await ethers.getSigners();
        const pageCommentFactory = (await ethers.getContractFactory(
            "PageComment"
        )) as PageComment__factory;
        pageComment = await pageCommentFactory.deploy();
        address = await accounts[0].getAddress();
    });

    describe("After Deployment", function () {
        it("Must Have Empty Stats", async function () {
            const totalStats = await pageComment.totalStats();
            expect(totalStats[0]).to.equal(0);
            expect(totalStats[0]).to.equal(0);
            expect(totalStats[0]).to.equal(0);
        });
        it("Should Be Required Id Equals Or Less Than Comments Count", async function () {
            await expect(pageComment.getCommentById(99)).to.be.revertedWith(
                "No comment with this ID"
            );
        });
        it("Should Be Required Ids More Than Zero", async function () {
            await expect(pageComment.getCommentsByIds([])).to.be.revertedWith(
                "_ids length must be more than zero"
            );
        });
        it("Should Be Required Id In Ids Equals Or Less Than Comments Count", async function () {
            await pageComment.createComment(address, "hello world", true);
            await expect(pageComment.getCommentsByIds([99])).to.be.revertedWith(
                "No comment with this ID"
            );
        });
        it("Should Be Required Ids Count Must Be Equal Or Less Than Comments Count", async function () {
            await pageComment.createComment(address, "hello world", true);
            await expect(
                pageComment.getCommentsByIds([0, 99])
            ).to.be.revertedWith(
                "_ids length must be less or equal commentsIds"
            );
        });
        describe("Each New Comment", function () {
            it("Should Be Available In Comments Ids", async function () {
                await pageComment.createComment(address, "hello world", true);
                const commentsIds = await pageComment.getCommentsIds();
                expect(commentsIds.length).to.equal(1);
                expect(commentsIds[0]).to.equal(0);
            });
            it("Should Be Available In Stats When Is Positive", async function () {
                const totalStats = await pageComment.totalStats();
                await pageComment.createComment(address, "hello world", true);
                expect(totalStats[1]).to.equal(0);
                expect(totalStats[1]).to.equal(0);
                expect(totalStats[0]).to.equal(0);
            });
            it("Should Be Available In Stats When Is Negative", async function () {
                const totalStats = await pageComment.totalStats();
                await pageComment.createComment(address, "hello world", false);
                expect(totalStats[1]).to.equal(0);
                expect(totalStats[0]).to.equal(0);
                expect(totalStats[1]).to.equal(0);
            });
            it("Should Be Available By Id", async function () {
                await pageComment.createComment(address, "hello world", true);
                const arrays = await pageComment.getCommentById(0);
                expect(arrays.length).to.equal(4);
            });
            it("Should Be Available In AllComments", async function () {
                await pageComment.createComment(address, "hello world", true);
                const arrays = await pageComment.getComments();
                expect(arrays.length).to.equal(4);
            });
        });
    });
});
