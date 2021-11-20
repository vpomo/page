import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import { PageComment, PageComment__factory } from "../types";

describe("PageComment", async function () {
    let address: Address;
    let accounts: Signer[];
    let comment: PageComment;
    const commentFactory = (await ethers.getContractFactory(
        "PageComment"
    )) as PageComment__factory;
    beforeEach(async function () {
        accounts = await ethers.getSigners();
        comment = await commentFactory.deploy();
        address = await accounts[0].getAddress();
    });

    describe("After Deployment", function () {
        it("Should Be Empty Statistic", async function () {
            const totalStats = await comment.getStatistic();
            expect(totalStats[0]).to.equal(0);
            expect(totalStats[0]).to.equal(0);
            expect(totalStats[0]).to.equal(0);
        });
        it("Should Be Required Id Equals Or Less Than Total Comments Count", async function () {
            await expect(comment.getCommentById(99)).to.be.revertedWith(
                "No comment with this ID"
            );
        });
        it("Should Be Required Ids Count More Than Zero", async function () {
            await expect(comment.getCommentsByIds([])).to.be.revertedWith(
                "_ids length must be more than zero"
            );
        });
        it("Should Be Required Id In Ids Equals Or Less Than Total Comments Count", async function () {
            await comment.createComment(address, "hello, World!", true);
            await expect(comment.getCommentsByIds([99])).to.be.revertedWith(
                "No comment with this ID"
            );
        });
        it("Should Be Required Ids Count Must Be Equal Or Less Than Comments Count", async function () {
            await comment.createComment(address, "hello, World!", true);
            await expect(comment.getCommentsByIds([0, 99])).to.be.revertedWith(
                "_ids length must be less or equal commentsIds"
            );
        });
        it("Should Be Avoid Create Comment If Inactove", async function () {
            await comment.toggleActive();
            await comment.toggleActive();
            await comment.toggleActive();
            await expect(
                comment.createComment(address, "Hello, World!", true)
            ).to.be.revertedWith("Comments not activated.");
        });
        describe("Each New Comment", function () {
            it("Should Be Available In Total Comments Ids", async function () {
                await comment.createComment(address, "hello world", true);
                const commentsIds = await comment.getCommentsIds();
                expect(commentsIds.length).to.equal(1);
                expect(commentsIds[0]).to.equal(0);
            });
            it("Should Be Available In Statistic When Comment Positive", async function () {
                const totalStats = await comment.getStatistic();
                await comment.createComment(address, "hello world", true);
                expect(totalStats[1]).to.equal(0);
                expect(totalStats[1]).to.equal(0);
                expect(totalStats[0]).to.equal(0);
            });
            it("Should Be Available In Statistic When Comment Negative", async function () {
                const totalStats = await comment.getStatistic();
                await comment.createComment(address, "hello world", false);
                expect(totalStats[1]).to.equal(0);
                expect(totalStats[0]).to.equal(0);
                expect(totalStats[1]).to.equal(0);
            });
            it("Should Be Available By Id", async function () {
                await comment.createComment(address, "hello world", true);
                const arrays = await comment.getCommentById(0);
                expect(arrays.length).to.equal(4);
            });
            it("Should Be Available In Total Comments", async function () {
                const commentText = "hello, World!";
                await comment.createComment(address, commentText, true);
                const comments = await comment.getComments();
                expect(comments[0].text).to.equal(commentText);
                expect(comments[0].author).to.equal(address);
            });
            it("Should Be Active By Default", async function () {
                await comment.createComment(address, "hello world", true);
                const active = await comment.getActive();
                expect(active).to.equal(true);
            });
        });
    });
});
