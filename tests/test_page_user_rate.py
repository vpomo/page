import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

VERSION = '1'
tokenData = '00'
tokenAmount = 1


def test_deployment(pageUserRate):
    print('='*20 + ' running for PageUserRate ... ' + '='*20)
    assert pageUserRate != ZERO_ADDRESS
    assert pageUserRate.uri(1) == 'https://'

def test_version(pageUserRate):
    assert VERSION == pageUserRate.version()


def test_set_base_token_uri(pageUserRate, pageCommunity, admin):
    pageUserRate.mint(admin, 1, tokenAmount, tokenData, {'from': pageCommunity})
    tokenURI_0 = pageUserRate.uri(0)
    assert tokenURI_0 == 'https://'


def test_tokens_mint_burn(pageUserRate, pageCommunity, admin, someUser):
    pageUserRate.mint(admin, 1, tokenAmount, tokenData, {'from': pageCommunity})
    pageUserRate.mint(admin, 1, tokenAmount, tokenData, {'from': pageCommunity})
    pageUserRate.mint(someUser, 2, tokenAmount, tokenData, {'from': pageCommunity})
    pageUserRate.mint(admin, 2, tokenAmount, tokenData, {'from': pageCommunity})

    totalSupply1 = pageUserRate.totalSupply(1)
    assert totalSupply1 == 2

    totalSupply2 = pageUserRate.totalSupply(2)
    assert totalSupply2 == 2

    tokenBalance = pageUserRate.balanceOf(someUser, 1)
    assert tokenBalance == 0
    tokenBalance = pageUserRate.balanceOf(someUser, 2)
    assert tokenBalance == 1
    tokenBalance = pageUserRate.balanceOf(admin, 1)
    assert tokenBalance == 2


def test_transfer_from(pageUserRate, pageCommunity, admin, someUser, treasury):
    pageUserRate.mint(admin, 1, tokenAmount, tokenData, {'from': pageCommunity})
    pageUserRate.mint(admin, 1, tokenAmount, tokenData, {'from': pageCommunity})
    pageUserRate.mint(admin, 1, tokenAmount, tokenData, {'from': pageCommunity})

    with reverts():
        pageUserRate.safeTransferFrom(admin, treasury, 1, tokenAmount, tokenData, {'from': someUser})

    tokens = pageUserRate.totalSupply(1)
    assert tokens == 3
    tokens = pageUserRate.balanceOf(admin, 1)
    assert tokens == 3

    pageUserRate.setApprovalForAll(someUser, True, {'from': admin})
    pageUserRate.safeTransferFrom(admin, treasury, 1, tokenAmount, tokenData, {'from': someUser})

    tokens = pageUserRate.balanceOf(treasury, 1)
    assert tokens == 1
    tokens = pageUserRate.balanceOf(admin, 1)
    assert tokens == 2


