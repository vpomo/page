import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import { PageComment, PageComment__factory } from "../types";

describe("PageComment", async function () {
    /*
    let address: Address;
    let accounts: Signer[];
    let comment: PageComment;
    const commentFactory = (await ethers.getContractFactory(
        "PageComment"
    )) as PageComment__factory;
    beforeEach(async function () {
        accounts = await ethers.getSigners();
        address = await accounts[0].getAddress();
        comment = await commentFactory.deploy();
    });

    describe("After Deployment", function () {
        it("Should Be Empty Statistic", async function () {
            const statictic = await comment.getStatistic();
            expect(statictic.likes).to.equal(0);
            expect(statictic.dislikes).to.equal(0);
            expect(statictic.total).to.equal(0);
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
            await comment.createComment(address, "Hello, World!", true);
            await expect(comment.getCommentsByIds([99])).to.be.revertedWith(
                "No comment with this ID"
            );
        });
        it("Should Be Required Ids Count Must Be Equal Or Less Than Comments Count", async function () {
            await comment.createComment(address, "Hello, World!", true);
            await expect(comment.getCommentsByIds([0, 99])).to.be.revertedWith(
                "_ids length must be less or equal commentsIds"
            );
        });
        describe("Each New Comment", function () {
            it("Should Be Available In Total Comments Ids", async function () {
                await comment.createComment(address, "Hello, World!", true);
                const commentsIds = await comment.getCommentsIds();
                expect(commentsIds.length).to.equal(1);
                expect(commentsIds[0]).to.equal(0);
            });
            it("Should Be Available In Statistic When Comment Positive", async function () {
                await comment.createComment(address, "Hello, World!", true);
                const statistic = await comment.getStatistic();
                expect(statistic.likes).to.equal(1);
                expect(statistic.dislikes).to.equal(0);
                expect(statistic.total).to.equal(1);
            });
            it("Should Be Available In Statistic When Comment Negative", async function () {
                await comment.createComment(address, "Hello, World!", false);
                const statistic = await comment.getStatistic();
                expect(statistic.likes).to.equal(0);
                expect(statistic.dislikes).to.equal(1);
                expect(statistic.total).to.equal(1);
            });
            it("Should Be Available By Id", async function () {
                await comment.createComment(address, "Hello, World!", true);
                const commentData = await comment.getCommentById(0);
                expect(commentData.id).to.equal(0);
                expect(commentData.author).to.equal(address);
                expect(commentData.text).to.equal("Hello, World!");
                expect(commentData.like).to.equal(true);
            });
            it("Should Be Available In Total Comments", async function () {
                const commentText = "hello, World!";
                await comment.createComment(address, commentText, true);
                const comments = await comment.getComments();
                expect(comments[0].text).to.equal(commentText);
                expect(comments[0].author).to.equal(address);
            });
            it("Should Be Available Empty Comments", async function () {
                const comments = await comment.getComments();
                expect(comments.length).to.equal(0);
            });
            it("Should Be Available In Statistic With Comments", async function () {
                await comment.createComment(address, "Hello, World!", true);
                const statistic = await comment.getStatisticWithComments();
                expect(statistic.comments.length).to.equal(1);
                expect(statistic.comments[0].id).to.equal(0);
                expect(statistic.comments[0].text).to.equal("Hello, World!");
                expect(statistic.comments[0].author).to.equal(address);
                expect(statistic.comments[0].like).to.equal(true);
                expect(statistic.likes).to.equal(1);
                expect(statistic.dislikes).to.equal(0);
                expect(statistic.total).to.equal(1);
            });
        });
    });
    */
});
