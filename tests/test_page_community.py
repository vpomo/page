import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

ZERO_BYTES32 = '0x0000000000000000000000000000000000000000000000000000000000000000'

TOKEN_VERSION = 1


def test_deployment(pageCommunity):
    print('='*20 + ' running for pageComment ... ' + '='*20)
    assert pageCommunity != ZERO_ADDRESS


def test_add_community(pageCommunity):
    pageCommunity.addCommunity("First users")
    assert pageCommunity.communityCount() == 1
    community = pageCommunity.getCommunity(1)
    print('community', community)

