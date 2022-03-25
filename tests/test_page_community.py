import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

ZERO_BYTES32 = '0x0000000000000000000000000000000000000000000000000000000000000000'

TOKEN_VERSION = 1


def test_deployment(pageCommunity):
    print('='*20 + ' running for pageComment ... ' + '='*20)
    assert pageCommunity != ZERO_ADDRESS


def test_add_community(pageCommunity):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    assert pageCommunity.communityCount() == 1
    community = pageCommunity.readCommunity(1)
    print('community', community)
    # ('First users', '0x66aB6D9362d4F35596279692F0251Db635165871', (), (), (), 0, True)

    assert community[0] == communityName


def test_add_remove_moderator(pageCommunity, accounts):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    assert pageCommunity.communityCount() == 1

    pageCommunity.addModerator(1, accounts[2], {'from': accounts[0]})
    pageCommunity.addModerator(1, accounts[3], {'from': accounts[0]})
    community = pageCommunity.readCommunity(1)
    assert community[2][0] == accounts[2]
    assert community[2][1] == accounts[3]

    pageCommunity.removeModerator(1, accounts[2], {'from': accounts[0]})
    community = pageCommunity.readCommunity(1)
    assert community[2][0] == accounts[3]


def test_find_moderator(pageCommunity, accounts):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    assert pageCommunity.communityCount() == 1

    pageCommunity.addModerator(1, accounts[2], {'from': accounts[0]})
    pageCommunity.addModerator(1, accounts[3], {'from': accounts[0]})
    community = pageCommunity.readCommunity(1)
    assert community[2][0] == accounts[2]
    assert community[2][1] == accounts[3]

    isCommunityModerator = pageCommunity.isCommunityModerator(1, accounts[2], {'from': accounts[0]})
    print('isCommunityModerator', isCommunityModerator)
    assert isCommunityModerator == True
    isCommunityModerator = pageCommunity.isCommunityModerator(1, accounts[3], {'from': accounts[0]})
    assert isCommunityModerator == True



