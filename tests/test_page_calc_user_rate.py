import pytest
from brownie import ZERO_ADDRESS, chain, reverts, network
import brownie

VERSION = '1'


def test_deployment(pageCalcUserRate):
    print('='*20 + ' running for pageCalcUserRate ... ' + '='*20)
    assert pageCalcUserRate != ZERO_ADDRESS


def test_version(pageCalcUserRate):
    assert VERSION == pageCalcUserRate.version()


