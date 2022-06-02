import pytest
from brownie import Wei, ZERO_ADDRESS, chain, reverts, network
import brownie

VERSION = '1'


def test_deployment(pageSafeDeal):
    print('='*20 + ' running for PageSafeDeal ... ' + '='*20)
    assert pageSafeDeal != ZERO_ADDRESS


def test_version(pageSafeDeal):
    assert VERSION == pageSafeDeal.version()


def test_set_token(pageSafeDeal, pageToken, deployer, someUser):
    beforeToken = pageSafeDeal.token()
    assert beforeToken == pageToken

    pageSafeDeal.setToken(someUser, {'from': deployer})
    afterToken = pageSafeDeal.token()
    assert afterToken == someUser


def test_make_deal(pageSafeDeal, pageToken, pageBank, deployer, someUser, admin):
    desc = 'first deal'
    value = Wei('1 ether')/5

    currentTime = pageSafeDeal.currentTime()

    mintAmount = pageSafeDeal.GUARANTOR_FEE() * pageBank.getWETHPagePrice()

    beforeBalanceBuyer = pageToken.balanceOf(someUser)
    pageToken.mint(someUser, mintAmount, {'from': pageBank})
    pageToken.approve(pageSafeDeal, mintAmount, {'from': someUser})
    afterBalanceBuyer = pageToken.balanceOf(someUser)

    diff = afterBalanceBuyer - beforeBalanceBuyer
    print('diff', diff)
    assert afterBalanceBuyer > 0
    assert diff == mintAmount

    pageSafeDeal.makeDeal(desc, deployer, admin, currentTime + 10, currentTime + 100, value, True, {'from': someUser, 'value': value})

    firstDeal = pageSafeDeal.readCommonDeal(1)
    print('firstDeal', firstDeal)
    #  ('first deal', '0x66aB6D9362d4F35596279692F0251Db635165871', '0xA868bC7c1AF08B8831795FAC946025557369F69C',
    # '0x33A4622B82D4c04a53e170c638B944ce27cffce3', 200000000000000000, 1653029270, 1653029360)

    assert firstDeal[0] == desc

    assert firstDeal[1] == deployer #seller
    assert firstDeal[2] == someUser #buyer
    assert firstDeal[3] == admin #guarantor

    assert firstDeal[4] == value
    assert firstDeal[5] == currentTime + 10
    assert firstDeal[6] == currentTime + 100


