import pytest
from brownie import Wei, ZERO_ADDRESS, chain, reverts, network
import brownie

VERSION = '1'


def test_deployment(pageOracle):
    print('='*20 + ' running for pageOracle ... ' + '='*20)
    assert pageOracle != ZERO_ADDRESS


def test_version(pageOracle):
    assert VERSION == pageOracle.version()


def test_get_price_from_pool(pageOracle):

    price = pageOracle.getFromPageToWethPrice()
    print('price', price / 1e18) # 0.000197085401415945
    print('price', price / 1e18) # 0.000197085401415945
    assert price > 0

    wethAmount = Wei('1 ether')/10
    pageAmount = pageOracle.getFromWethToPageAmount(wethAmount) / 1e18
    print('pageAmount', pageAmount) # 50.73
    assert pageAmount > 0


def test_get_stable_price(pageOracle, deployer):
    newPrice = 197085401415975
    pageOracle.setStablePrice(newPrice, {'from': deployer} )

    price = pageOracle.getFromPageToWethPrice()
    assert price != newPrice

    pageOracle.changeStablePriceStatus()
    price = pageOracle.getFromPageToWethPrice()
    print('price', price) # 197085401415975
    assert price == newPrice
