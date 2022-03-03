import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

ZERO_BYTES32 = '0x0000000000000000000000000000000000000000000000000000000000000000'

TOKEN_VERSION = 1


def test_deployment(pageNFT):
    print('='*20 + ' running for pageNFT ... ' + '='*20)
    assert pageNFT != ZERO_ADDRESS
    assert pageNFT.name() == 'Crypto.Page NFT'
    assert pageNFT.symbol() == 'PAGE.NFT'


