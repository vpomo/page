import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

ZERO_BYTES32 = '0x0000000000000000000000000000000000000000000000000000000000000000'

TOKEN_VERSION = 1


def test_deployment(pageToken):
    print('='*20 + ' running for pageToken ... ' + '='*20)
    assert pageToken != ZERO_ADDRESS
    assert pageToken.decimals() == 18
    assert pageToken.name() == 'Crypto.Page'
    assert pageToken.symbol() == 'PAGE'


