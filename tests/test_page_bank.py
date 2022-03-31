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


def test_update_comment_fee_for_new_community(pageBank, pageVoteForFeeAndModerator):
    pageBank.updateCommentFee(1, 2, 3, 4, 5, {'from': pageVoteForFeeAndModerator})
    readCommentFee = pageBank.readCommentFee(1)
    assert readCommentFee[0] == 2
    assert readCommentFee[1] == 3
    assert readCommentFee[2] == 4
    assert readCommentFee[3] == 5


def test_update_post_fee_for_new_community(pageBank, pageVoteForFeeAndModerator):
    pageBank.updatePostFee(1, 2, 3, 4, 5, {'from': pageVoteForFeeAndModerator})
    readPostFee = pageBank.readPostFee(1)
    assert readPostFee[0] == 2
    assert readPostFee[1] == 3
    assert readPostFee[2] == 4
    assert readPostFee[3] == 5


def test_mint_token_for_new_post(pageBank, pageCommunity, pageToken, admin, someUser):
    pageBank.definePostFeeForNewCommunity(1, {'from': pageCommunity})
    pageBank.defineCommentFeeForNewCommunity(1, {'from': pageCommunity})
    price = pageBank.getWETHPagePrice()
    #print('price', price)
    network.gas_price("65 gwei")
    gas = 200000
    tx = pageBank.mintTokenForNewPost(1, admin, someUser, gas, {'from': pageCommunity})
    #print('tx', tx.info())
    #print('pageBank.balanceOf(admin)', pageBank.balanceOf(admin))
    #print('pageBank.balanceOf(someUser)', pageBank.balanceOf(someUser))
    #print('pageToken.balanceOf(pageBank)', pageToken.balanceOf(pageBank))

    assert pageBank.balanceOf(admin) > 0
    assert pageBank.balanceOf(someUser) > 0
    assert pageToken.balanceOf(pageBank) > 0
