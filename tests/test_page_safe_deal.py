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


def test_make_deal(pageSafeDeal, pageToken, pageBank, pageOracle, deployer, someUser, admin):
    desc = 'first deal'
    value = Wei('1 ether')/5

    currentTime = pageSafeDeal.currentTime()

    mintAmount = pageOracle.getFromWethToPageAmount(pageSafeDeal.GUARANTOR_FEE())

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



def test_cancel_deal(pageSafeDeal, pageToken, pageBank, pageOracle, pageUserRateToken, deployer, someUser, admin):
    #deployer - seller
    #admin - guarantor
    #someuser - buyer

    desc = 'first deal'
    value = Wei('1 ether')/5

    currentTime = pageSafeDeal.currentTime()

    mintAmount = pageOracle.getFromWethToPageAmount(pageSafeDeal.GUARANTOR_FEE())

    beforeBalanceBuyer = pageToken.balanceOf(someUser)
    pageToken.mint(someUser, mintAmount, {'from': pageBank})
    pageToken.approve(pageSafeDeal, mintAmount, {'from': someUser})
    afterBalanceBuyer = pageToken.balanceOf(someUser)

    diff = afterBalanceBuyer - beforeBalanceBuyer
    print('diff', diff)
    assert afterBalanceBuyer > 0
    assert diff == mintAmount

    pageSafeDeal.makeDeal(desc, deployer, admin, currentTime + 100, currentTime + 1000, value, True, {'from': someUser, 'value': value})
    dealId = 1

    pageSafeDeal.setIssue(dealId, '', {'from': deployer})

    isIssue = pageSafeDeal.isIssue(dealId)
    assert isIssue == True

    firstDeal = pageSafeDeal.readBoolDeal(1)
    assert firstDeal[0] == True
    assert firstDeal[1] == True
    assert firstDeal[2] == False

    beforeBalance = pageUserRateToken.balanceOf(admin, 11)
    assert beforeBalance == 0


    pageSafeDeal.cancelDeal(dealId, {'from': admin})

    afterBalance = pageUserRateToken.balanceOf(admin, 11)
    assert afterBalance == 1

    firstDeal = pageSafeDeal.readBoolDeal(1)
    assert firstDeal[0] == True
    assert firstDeal[1] == True
    assert firstDeal[2] == True


def test_finish_deal(pageSafeDeal, pageToken, pageBank, pageOracle, pageUserRateToken, deployer, someUser, admin):
    #deployer - seller
    #admin - guarantor
    #someuser - buyer

    desc = 'first deal'
    value = Wei('1 ether')/5

    currentTime = pageSafeDeal.currentTime()

    mintAmount = pageOracle.getFromWethToPageAmount(pageSafeDeal.GUARANTOR_FEE())

    beforeBalanceBuyer = pageToken.balanceOf(someUser)
    pageToken.mint(someUser, mintAmount, {'from': pageBank})
    pageToken.approve(pageSafeDeal, mintAmount, {'from': someUser})
    afterBalanceBuyer = pageToken.balanceOf(someUser)

    diff = afterBalanceBuyer - beforeBalanceBuyer
    print('diff', diff)
    assert afterBalanceBuyer > 0
    assert diff == mintAmount

    pageSafeDeal.makeDeal(desc, deployer, admin, currentTime + 10, currentTime + 1000, value, True, {'from': someUser, 'value': value})
    dealId = 1

    firstDeal = pageSafeDeal.readApproveDeal(1)
    assert firstDeal[0] == False
    assert firstDeal[1] == False

    pageSafeDeal.makeStartApprove(dealId, {'from': deployer})
    pageSafeDeal.makeStartApprove(dealId, {'from': someUser})

    firstDeal = pageSafeDeal.readApproveDeal(1)
    assert firstDeal[0] == True
    assert firstDeal[1] == True
    assert firstDeal[2] == False
    assert firstDeal[3] == False

    firstDeal = pageSafeDeal.readBoolDeal(1)
    assert firstDeal[0] == False
    assert firstDeal[1] == True
    assert firstDeal[2] == False

    with reverts("SafeDeal: wrong start time"):
        pageSafeDeal.makeEndApprove(dealId, {'from': deployer})

    chain.sleep(currentTime + 2000)

    with reverts("SafeDeal: wrong deal user"):
        pageSafeDeal.makeEndApprove(dealId, {'from': admin})

    pageSafeDeal.makeEndApprove(dealId, {'from': deployer})
    pageSafeDeal.makeEndApprove(dealId, {'from': someUser})

    firstDeal = pageSafeDeal.readApproveDeal(1)
    assert firstDeal[2] == True
    assert firstDeal[3] == True

    pageSafeDeal.finishDeal(dealId, {'from': admin})

    firstDeal = pageSafeDeal.readBoolDeal(1)
    assert firstDeal[0] == False
    assert firstDeal[1] == True
    assert firstDeal[2] == True

    guarantorNftBalance = pageUserRateToken.balanceOf(admin, 11)
    sellerNftBalance = pageUserRateToken.balanceOf(deployer, 12)
    buyerNftBalance = pageUserRateToken.balanceOf(someUser, 13)
    assert guarantorNftBalance == 1
    assert sellerNftBalance == 1
    assert buyerNftBalance == 1



