import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

TOKEN_VERSION = '1'


def test_deployment(pageToken):
    print('='*20 + ' running for pageToken ... ' + '='*20)
    assert pageToken != ZERO_ADDRESS
    assert pageToken.decimals() == 18
    assert pageToken.name() == 'Crypto.Page'
    assert pageToken.symbol() == 'PAGE'


def test_version(pageToken):
    assert TOKEN_VERSION == pageToken.version()


def test_mint_burn(treasury, admin, pageToken, pageBank):
    mintAmount = 1000
    burnAmount = 100
    beforeTotalSupply = pageToken.totalSupply()
    assert beforeTotalSupply == 50000000000000000000000000

    balanceTreasury = pageToken.balanceOf(treasury)
    assert balanceTreasury == beforeTotalSupply

    balanceAdmin = pageToken.balanceOf(admin)
    assert balanceAdmin == 0

    pageToken.mint(admin, mintAmount, {'from': pageBank})
    balanceAdmin = pageToken.balanceOf(admin)
    assert balanceAdmin == mintAmount
    totalSupply = pageToken.totalSupply()
    assert totalSupply == beforeTotalSupply + mintAmount

    pageToken.burn(admin, burnAmount, {'from': pageBank})
    balanceAdmin = pageToken.balanceOf(admin)
    assert balanceAdmin == mintAmount - burnAmount
    totalSupply = pageToken.totalSupply()
    assert totalSupply == beforeTotalSupply + mintAmount - burnAmount

