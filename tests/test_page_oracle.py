import pytest
from brownie import ZERO_ADDRESS, chain, reverts, network
import brownie

VERSION = '1'


def test_deployment(pageBank):
    print('='*20 + ' running for pageBank ... ' + '='*20)
    assert pageBank != ZERO_ADDRESS


def test_version(pageBank):
    assert VERSION == pageBank.version()


def test_get_price(pageBank, pageCommunity):
    pageBank.definePostFeeForNewCommunity(1, {'from': pageCommunity})
    pageBank.defineCommentFeeForNewCommunity(1, {'from': pageCommunity})

    price = pageBank.getWETHPagePriceFromPool()
    #print('getWETHPagePriceFromPool', price)
    assert price > 0


    price = pageBank.getWETHPagePrice()
    #print('getWETHPagePrice', price)
    assert price > 0

