import pytest
from brownie import ZERO_ADDRESS, chain, reverts, network
import brownie

VERSION = '1'


def test_deployment(pageVoteForSuperModerator):
    print('='*20 + ' running for PageVoteForSuperModerator ... ' + '='*20)
    assert pageVoteForSuperModerator != ZERO_ADDRESS


def test_version(pageVoteForSuperModerator):
    version = pageVoteForSuperModerator.version()
    assert VERSION == version


def test_execute_vote(chain, pageVoteForSuperModerator, pageCommunity, pageVoteForFeeAndModerator, pageToken, someUser, deployer, treasury):
    supervisor = pageCommunity.supervisor()
    assert supervisor == ZERO_ADDRESS

    communityName = 'First users'
    pageCommunity.addCommunity(communityName)

    communityName = 'Second users'
    pageCommunity.addCommunity(communityName)

    pageCommunity.join(1, {'from': someUser})
    pageCommunity.join(2, {'from': deployer})

    pageCommunity.addModerator(1, someUser, {'from': pageVoteForFeeAndModerator})
    pageCommunity.addModerator(2, deployer, {'from': pageVoteForFeeAndModerator})

    pageToken.transfer(someUser, 100, {'from': treasury})
    pageToken.transfer(deployer, 100, {'from': treasury})
    network.gas_price("65 gwei")

    desc = 'Vote for superadmin'
    duration = 86400 * 4

    pageVoteForSuperModerator.createVote(1, desc, duration, treasury, {'from': someUser})

    readVotesCount = pageVoteForSuperModerator.readVotesCount()
    assert readVotesCount == 1

    readVote = pageVoteForSuperModerator.readVote(0)
    assert readVote[8] == True

    pageVoteForSuperModerator.putVote(1, 0, True, {'from': someUser})
    pageVoteForSuperModerator.putVote(2, 0, True, {'from': deployer})

    chain.sleep(duration + 10)

    pageVoteForSuperModerator.executeVote(1, 0, {'from': someUser})

    readVote = pageVoteForSuperModerator.readVote(0)
    assert readVote[8] == False

    supervisor = pageCommunity.supervisor()
    assert supervisor == treasury



