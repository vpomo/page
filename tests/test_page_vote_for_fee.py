import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

VERSION = '1'
duration = 86400 * 4


def test_deployment(pageVoteForFeeAndModerator):
    print('='*20 + ' running for pageVoteForFeeAndModerator ... ' + '='*20)
    assert pageVoteForFeeAndModerator != ZERO_ADDRESS


def test_version(pageVoteForFeeAndModerator):
    assert VERSION == pageVoteForFeeAndModerator.version()


def test_create_read_vote(accounts, pageVoteForFeeAndModerator, pageCommunity, someUser, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    pageCommunity.join(1, {'from': deployer})

    voteDesc = 'test for vote'
    pageVoteForFeeAndModerator.createVote(1, voteDesc, duration, 2, [10, 11, 12, 13], ZERO_ADDRESS, {'from': accounts[0]})

    readVote = pageVoteForFeeAndModerator.readVote(1, 0)
    #('test for vote', '0x66aB6D9362d4F35596279692F0251Db635165871', 2, 1649429924, 0, 0, (10, 11, 12, 13), '0x0000000000000000000000000000000000000000', (), True)
    assert readVote[0] == voteDesc
    assert readVote[6][0] == 10

    assert 1 == pageVoteForFeeAndModerator.readVotesCount(1)


def test_put_execute_vote(accounts, pageVoteForFeeAndModerator, pageCommunity, someUser, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    pageCommunity.join(1, {'from': deployer})

    voteDesc = 'test for vote'
    pageVoteForFeeAndModerator.createVote(1, voteDesc, duration, 2, [10, 11, 12, 13], ZERO_ADDRESS, {'from': accounts[0]})

    pageVoteForFeeAndModerator.putVote(1, 0, True, {'from': someUser})
    pageVoteForFeeAndModerator.putVote(1, 0, True, {'from': deployer})

    readVote = pageVoteForFeeAndModerator.readVote(1, 0)
    #('test for vote', '0x66aB6D9362d4F35596279692F0251Db635165871', 2, 1649429924, 0, 0, (10, 11, 12, 13), '0x0000000000000000000000000000000000000000', (), True)





