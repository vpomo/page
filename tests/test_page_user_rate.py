import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

VERSION = '1'
tokenData = '00'
tokenAmount = 1


def test_deployment(pageUserRateToken):
    print('='*20 + ' running for PageUserRateToken ... ' + '='*20)
    assert pageUserRateToken != ZERO_ADDRESS
    assert pageUserRateToken.uri(1) == 'https://'

def test_version(pageUserRateToken):
    assert VERSION == pageUserRateToken.version()


def test_set_base_token_uri(pageUserRateToken, pageCalcUserRate, admin):
    pageUserRateToken.mint(admin, 1, tokenAmount, tokenData, {'from': pageCalcUserRate})
    tokenURI_0 = pageUserRateToken.uri(0)
    assert tokenURI_0 == 'https://'


def test_tokens_mint_burn(pageUserRateToken, pageCalcUserRate, admin, someUser):
    pageUserRateToken.mint(admin, 1, tokenAmount, tokenData, {'from': pageCalcUserRate})
    pageUserRateToken.mint(admin, 1, tokenAmount, tokenData, {'from': pageCalcUserRate})
    pageUserRateToken.mint(someUser, 2, tokenAmount, tokenData, {'from': pageCalcUserRate})
    pageUserRateToken.mint(admin, 2, tokenAmount, tokenData, {'from': pageCalcUserRate})

    totalSupply1 = pageUserRateToken.totalSupply(1)
    assert totalSupply1 == 2

    totalSupply2 = pageUserRateToken.totalSupply(2)
    assert totalSupply2 == 2

    tokenBalance = pageUserRateToken.balanceOf(someUser, 1)
    assert tokenBalance == 0
    tokenBalance = pageUserRateToken.balanceOf(someUser, 2)
    assert tokenBalance == 1
    tokenBalance = pageUserRateToken.balanceOf(admin, 1)
    assert tokenBalance == 2


def test_transfer_from(pageUserRateToken, pageCalcUserRate, admin, someUser, treasury):
    pageUserRateToken.mint(admin, 1, tokenAmount, tokenData, {'from': pageCalcUserRate})
    pageUserRateToken.mint(admin, 1, tokenAmount, tokenData, {'from': pageCalcUserRate})
    pageUserRateToken.mint(admin, 1, tokenAmount, tokenData, {'from': pageCalcUserRate})

    with reverts():
        pageUserRateToken.safeTransferFrom(admin, treasury, 1, tokenAmount, tokenData, {'from': someUser})

    tokens = pageUserRateToken.totalSupply(1)
    assert tokens == 3
    tokens = pageUserRateToken.balanceOf(admin, 1)
    assert tokens == 3

    pageUserRateToken.setApprovalForAll(someUser, True, {'from': admin})
    pageUserRateToken.safeTransferFrom(admin, treasury, 1, tokenAmount, tokenData, {'from': someUser})

    tokens = pageUserRateToken.balanceOf(treasury, 1)
    assert tokens == 1
    tokens = pageUserRateToken.balanceOf(admin, 1)
    assert tokens == 2


