import pytest
from brownie import ZERO_ADDRESS, chain, reverts, network
import brownie

VERSION = '1'


def test_deployment(pageCalcUserRate):
    print('='*20 + ' running for pageCalcUserRate ... ' + '='*20)
    assert pageCalcUserRate != ZERO_ADDRESS


def test_version(pageCalcUserRate):
    assert VERSION == pageCalcUserRate.version()


def test_check_activity(pageBank, pageCalcUserRate, someUser):
    userActivity = pageCalcUserRate.getUserActivity(1, someUser)
    assert userActivity == (0,0,0,0)

    pageCalcUserRate.checkCommunityActivity(1, someUser, 0, {'from': pageBank})
    userActivity = pageCalcUserRate.getUserActivity(1, someUser)
    assert userActivity == (0,1,0,0)

    pageCalcUserRate.checkCommunityActivity(1, someUser, 1, {'from': pageBank})
    userActivity = pageCalcUserRate.getUserActivity(1, someUser)
    assert userActivity == (1,1,0,0)

    pageCalcUserRate.checkCommunityActivity(1, someUser, 2, {'from': pageBank})
    userActivity = pageCalcUserRate.getUserActivity(1, someUser)
    assert userActivity == (1,1,1,0)

    pageCalcUserRate.checkCommunityActivity(1, someUser, 3, {'from': pageBank})
    userActivity = pageCalcUserRate.getUserActivity(1, someUser)
    assert userActivity == (1,1,1,1)


def test_check_ten_posts(pageBank, pageCalcUserRate, pageUserRateToken, someUser, deployer):
    userActivity = pageCalcUserRate.getUserActivity(1, someUser)
    assert userActivity == (0,0,0,0)

    for i in range(9): pageCalcUserRate.checkCommunityActivity(1, someUser, 0, {'from': pageBank})
    userActivity = pageCalcUserRate.getUserActivity(1, someUser)
    assert userActivity == (0,9,0,0)

    beforeBalance = pageUserRateToken.balanceOf(someUser, 108)
    assert beforeBalance == 0

    pageCalcUserRate.checkCommunityActivity(1, someUser, 0, {'from': pageBank})
    userActivity = pageCalcUserRate.getUserActivity(1, someUser)
    assert userActivity == (0,10,0,0)

    afterBalance = pageUserRateToken.balanceOf(someUser, 1*108)
    assert afterBalance == 1


def test_setInterestAdjustment(pageCalcUserRate, admin):
    interestAdjustment = pageCalcUserRate.interestAdjustment(0)
    assert interestAdjustment == 5

    pageCalcUserRate.setInterestAdjustment([1,1,1,1,1,1,1,1,1,1], {'from': admin})
    interestAdjustment = pageCalcUserRate.interestAdjustment(0)
    assert interestAdjustment == 1
