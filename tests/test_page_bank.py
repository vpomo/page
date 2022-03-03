import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

ZERO_BYTES32 = '0x0000000000000000000000000000000000000000000000000000000000000000'

TOKEN_VERSION = 1


def test_deployment(pageBank):
    print('='*20 + ' running for pageBank ... ' + '='*20)
    assert pageBank != ZERO_ADDRESS


