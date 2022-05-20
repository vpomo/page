import pytest
from brownie import ZERO_ADDRESS, chain, reverts, network
import brownie

VERSION = '1'


def test_deployment(pageSafeDeal):
    print('='*20 + ' running for PageSafeDeal ... ' + '='*20)
    assert pageSafeDeal != ZERO_ADDRESS


def test_version(pageSafeDeal):
    assert VERSION == pageSafeDeal.version()


