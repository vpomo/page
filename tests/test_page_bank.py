import pytest
from brownie import ZERO_ADDRESS, chain, reverts, network
import brownie

VERSION = '1'


def test_deployment(pageBank):
    print('='*20 + ' running for pageBank ... ' + '='*20)
    assert pageBank != ZERO_ADDRESS


def test_version(pageBank):
    assert VERSION == pageBank.version()


def test_define_comment_fee_for_new_community(pageBank, pageCommunity):
    pageBank.defineCommentFeeForNewCommunity(1, {'from': pageCommunity})
    readCommentFee = pageBank.readCommentFee(1)
    assert readCommentFee[0] == 4500
    assert readCommentFee[1] == 4500
    assert readCommentFee[2] == 0
    assert readCommentFee[3] == 9000


def test_define_post_fee_for_new_community(pageBank, pageCommunity):
    pageBank.definePostFeeForNewCommunity(1, {'from': pageCommunity})
    readPostFee = pageBank.readPostFee(1)
    assert readPostFee[0] == 4500
    assert readPostFee[1] == 4500
    assert readPostFee[2] == 0
    assert readPostFee[3] == 9000


def test_update_comment_fee_for_new_community(pageBank, pageVoteForCommon):
    pageBank.updateCommentFee(1, 2, 3, 4, 5, {'from': pageVoteForCommon})
    readCommentFee = pageBank.readCommentFee(1)
    assert readCommentFee[0] == 2
    assert readCommentFee[1] == 3
    assert readCommentFee[2] == 4
    assert readCommentFee[3] == 5


def test_update_post_fee_for_new_community(pageBank, pageVoteForCommon):
    pageBank.updatePostFee(1, 2, 3, 4, 5, {'from': pageVoteForCommon})
    readPostFee = pageBank.readPostFee(1)
    assert readPostFee[0] == 2
    assert readPostFee[1] == 3
    assert readPostFee[2] == 4
    assert readPostFee[3] == 5


def test_mint_burn_token_for_new_post(pageBank, pageCommunity, pageToken, pageOracle, admin, someUser):
    pageBank.definePostFeeForNewCommunity(1, {'from': pageCommunity})
    pageBank.defineCommentFeeForNewCommunity(1, {'from': pageCommunity})
    price = pageOracle.getFromPageToWethPrice()
    assert price > 0
    network.gas_price("65 gwei")
    gas = 200000
    tx = pageBank.mintTokenForNewPost(1, admin, someUser, gas, {'from': pageCommunity})
    #print('tx for mint post', tx.info())
    #Gas Used: 142345

    beforeAdminBalance = pageBank.balanceOf(admin)
    beforeSomeUserBalance = pageBank.balanceOf(someUser)
    beforePageBankBalance = pageToken.balanceOf(pageBank)

    assert beforeAdminBalance > 0
    assert beforeSomeUserBalance > 0
    assert beforePageBankBalance > 0

    gas = 20

    tx = pageBank.burnTokenForPost(1, admin, someUser, gas, {'from': pageCommunity})
    #print('tx for burn post', tx.info())
    # Gas Used: 93111

    afterAdminBalance = pageBank.balanceOf(admin)
    afterSomeUserBalance = pageBank.balanceOf(someUser)
    afterPageBankBalance = pageToken.balanceOf(pageBank)

    assert afterAdminBalance > 0
    assert afterSomeUserBalance > 0
    assert afterPageBankBalance > 0

    assert beforeSomeUserBalance > afterSomeUserBalance
    assert beforePageBankBalance > afterPageBankBalance


def test_mint_burn_token_for_new_comment(pageBank, pageCommunity, pageToken, pageOracle, admin, someUser):
    pageBank.definePostFeeForNewCommunity(1, {'from': pageCommunity})
    pageBank.defineCommentFeeForNewCommunity(1, {'from': pageCommunity})
    price = pageOracle.getFromPageToWethPrice()
    assert price > 0
    network.gas_price("65 gwei")
    gas = 200000
    tx = pageBank.mintTokenForNewComment(1, admin, someUser, gas, {'from': pageCommunity})
    #print('tx for mint comment', tx.info())
    # Gas Used: 142337

    beforeAdminBalance = pageBank.balanceOf(admin)
    beforeSomeUserBalance = pageBank.balanceOf(someUser)
    beforePageBankBalance = pageToken.balanceOf(pageBank)

    assert beforeAdminBalance > 0
    assert beforeSomeUserBalance > 0
    assert beforePageBankBalance > 0

    gas = 20

    tx = pageBank.burnTokenForComment(1, admin, someUser, gas, {'from': pageCommunity})
    #print('tx for burn comment', tx.info())
    # Gas Used: 93124

    afterAdminBalance = pageBank.balanceOf(admin)
    afterSomeUserBalance = pageBank.balanceOf(someUser)
    afterPageBankBalance = pageToken.balanceOf(pageBank)

    assert afterAdminBalance > 0
    assert afterSomeUserBalance > 0
    assert afterPageBankBalance > 0

    assert beforeSomeUserBalance > afterSomeUserBalance
    assert beforePageBankBalance > afterPageBankBalance


def test_add_balance_withdraw(pageBank, pageToken, treasury, someUser):
    amount = 1000

    pageToken.transfer(someUser, amount, {'from': treasury})
    pageToken.approve(pageBank, amount, {'from': someUser})

    pageBank.addBalance(amount, {'from': someUser})
    beforeSomeUserBalance = pageBank.balanceOf(someUser)
    assert beforeSomeUserBalance == amount

    pageBank.withdraw(amount/2, {'from': someUser})
    afterSomeUserBalance = pageBank.balanceOf(someUser)
    assert afterSomeUserBalance == amount/2


def test_set_post_default_fee(pageBank, deployer):
    defaultRemovePostOwnerFee = pageBank.defaultRemovePostOwnerFee()
    assert defaultRemovePostOwnerFee == 0

    pageBank.setDefaultFee(2, 99, {'from': deployer} )
    defaultRemovePostOwnerFee = pageBank.defaultRemovePostOwnerFee()
    assert defaultRemovePostOwnerFee == 99


def test_set_comment_default_fee(pageBank, deployer):
    defaultRemoveCommentOwnerFee = pageBank.defaultRemoveCommentOwnerFee()
    assert defaultRemoveCommentOwnerFee == 0

    pageBank.setDefaultFee(6, 99, {'from': deployer} )
    defaultRemoveCommentOwnerFee = pageBank.defaultRemoveCommentOwnerFee()
    assert defaultRemoveCommentOwnerFee == 99


def test_set_TreasuryFee(pageBank, deployer):
    oldTreasuryFee = pageBank.treasuryFee()
    newTreasuryFee = 999
    assert oldTreasuryFee != newTreasuryFee

    pageBank.setTreasuryFee(newTreasuryFee, {'from': deployer} )
    assert newTreasuryFee == pageBank.treasuryFee()
