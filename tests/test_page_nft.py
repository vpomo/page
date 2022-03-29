import pytest
from brownie import ZERO_ADDRESS, chain, reverts
import brownie

VERSION = '1'


def test_deployment(pageNFT):
    print('='*20 + ' running for pageNFT ... ' + '='*20)
    assert pageNFT != ZERO_ADDRESS
    assert pageNFT.name() == 'Crypto.Page NFT'
    assert pageNFT.symbol() == 'PAGE.NFT'


def test_version(pageNFT):
    assert VERSION == pageNFT.version()


def test_set_base_token_uri(pageNFT, pageCommunity, admin):
    tokenUri = 'https://my_token_uri/'

    pageNFT.mint(admin, {'from': pageCommunity})
    tokenURI_0 = pageNFT.tokenURI(0)
    assert tokenURI_0 == 'https://0'

    pageNFT.setBaseTokenURI(tokenUri)
    tokenURI_0 = pageNFT.tokenURI(0)
    assert tokenURI_0 == 'https://my_token_uri/0'


def test_tokens_of_owner(pageNFT, pageCommunity, admin, someUser):
    pageNFT.mint(admin, {'from': pageCommunity})
    pageNFT.mint(admin, {'from': pageCommunity})
    pageNFT.mint(someUser, {'from': pageCommunity})
    pageNFT.mint(admin, {'from': pageCommunity})

    tokens = pageNFT.tokensOfOwner(admin)
    assert tokens[2] == 3

    tokens = pageNFT.tokensOfOwner(someUser)
    assert tokens[0] == 2

def test_tokens_of_owner(pageNFT, pageCommunity, admin):
    pageNFT.mint(admin, {'from': pageCommunity})
    pageNFT.mint(admin, {'from': pageCommunity})
    pageNFT.mint(admin, {'from': pageCommunity})

    tokens = pageNFT.tokensOfOwner(admin)
    assert tokens[1] == 1

    pageNFT.burn(1, {'from': pageCommunity})
    tokens = pageNFT.tokensOfOwner(admin)
    assert tokens[1] == 2


def test_transfer_from(pageNFT, pageCommunity, admin, someUser):
    pageNFT.mint(admin, {'from': pageCommunity})
    pageNFT.mint(admin, {'from': pageCommunity})
    pageNFT.mint(admin, {'from': pageCommunity})

    with reverts():
        pageNFT.transferFrom(admin, someUser, 1, {'from': admin})

    tokens = pageNFT.tokensOfOwner(admin)
    assert tokens[1] == 1

    pageNFT.approve(someUser, 1, {'from': admin})
    pageNFT.transferFrom(admin, someUser, 1, {'from': admin})

    tokens = pageNFT.tokensOfOwner(someUser)
    assert tokens[0] == 1
    tokens = pageNFT.tokensOfOwner(admin)
    assert tokens[1] == 2


