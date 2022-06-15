import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

VERSION = '1'
duration = 86400 * 4


def test_deployment(pageVoteForCommon):
    print('='*20 + ' running for PageVoteForCommon ... ' + '='*20)
    assert pageVoteForCommon != ZERO_ADDRESS


def test_version(pageVoteForCommon):
    assert VERSION == pageVoteForCommon.version()


def test_create_read_vote(accounts, pageVoteForCommon, pageCommunity, someUser, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    pageCommunity.join(1, {'from': deployer})

    voteDesc = 'test for vote'
    pageVoteForCommon.createVote(1, voteDesc, duration, 2, [10, 11, 12, 13], ZERO_ADDRESS, {'from': accounts[0]})

    readVote = pageVoteForCommon.readVote(1, 0)
    #('test for vote', '0x66aB6D9362d4F35596279692F0251Db635165871', 2, 1649429924, 0, 0, (10, 11, 12, 13), '0x0000000000000000000000000000000000000000', (), True)
    assert readVote[0] == voteDesc
    assert readVote[6][0] == 10

    assert 1 == pageVoteForCommon.readVotesCount(1)


def test_put_execute_vote(chain, accounts, pageVoteForCommon, pageCommunity, pageBank, pageToken, someUser, deployer, treasury):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    pageCommunity.join(1, {'from': deployer})

    voteDesc = 'test for vote'
    pageVoteForCommon.createVote(1, voteDesc, duration, 2, [10, 11, 12, 13], ZERO_ADDRESS, {'from': accounts[0]})

    readVotesCount = pageVoteForCommon.readVotesCount(1)
    assert readVotesCount == 1

    pageToken.transfer(someUser, 1000, {'from': treasury})
    pageToken.transfer(deployer, 1000, {'from': treasury})

    pageVoteForCommon.putVote(1, 0, True, {'from': someUser})
    pageVoteForCommon.putVote(1, 0, True, {'from': deployer})

    readVote = pageVoteForCommon.readVote(1, 0)
    assert readVote[9] == True

    with reverts():
        pageVoteForCommon.executeVote(1, 0, {'from': someUser})

    readCommentFee = pageBank.readCommentFee(1)
    assert readCommentFee[0] == 4500
    assert readCommentFee[1] == 4500
    assert readCommentFee[2] == 0
    assert readCommentFee[3] == 9000

    chain.sleep(duration + 10)
    pageVoteForCommon.executeVote(1, 0, {'from': someUser})

    readVote = pageVoteForCommon.readVote(1, 0)
    #('test for vote', '0x66aB6D9362d4F35596279692F0251Db635165871', 2, 1649439695, 0, 0, (10, 11, 12, 13),
    # '0x0000000000000000000000000000000000000000',
    # ('0xA868bC7c1AF08B8831795FAC946025557369F69C', '0x66aB6D9362d4F35596279692F0251Db635165871'), False)
    assert readVote[9] == False

    readCommentFee = pageBank.readCommentFee(1)
    assert readCommentFee[0] == 10
    assert readCommentFee[1] == 11
    assert readCommentFee[2] == 12
    assert readCommentFee[3] == 13




