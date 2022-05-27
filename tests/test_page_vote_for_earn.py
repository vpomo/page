import pytest
from brownie import ZERO_ADDRESS, chain, reverts, network
import brownie

VERSION = '1'
duration = 86400 * 4


def test_deployment(pageVoteForEarn):
    print('='*20 + ' running for PageVoteForEarn ... ' + '='*20)
    assert pageVoteForEarn != ZERO_ADDRESS


def test_version(pageVoteForEarn):
    version = pageVoteForEarn.version()
    assert VERSION == version


def test_create_read_vote(accounts, pageVoteForEarn, pageCommunity, someUser, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    pageCommunity.join(1, {'from': deployer})

    voteDesc = 'test for vote'
    pageVoteForEarn.createPrivacyAccessPriceVote(1, voteDesc, duration, 2, {'from': accounts[0]})

    readVote = pageVoteForEarn.readPrivacyAccessPriceVote(1, 0)
    #('test for vote', '0x66aB6D9362d4F35596279692F0251Db635165871', 2, 1649429924, 0, 0, (10, 11, 12, 13), '0x0000000000000000000000000000000000000000', (), True)
    assert readVote[0] == voteDesc
    assert readVote[5] == 2

    assert 1 == pageVoteForEarn.readPrivacyAccessPriceVotesCount(1)


def test_execute_token_transfer_vote(chain, accounts, pageVoteForEarn, pageCommunity, pageBank, pageToken, someUser, deployer, treasury):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    pageCommunity.join(1, {'from': deployer})

    voteDesc = 'test for vote'
    pageVoteForEarn.createTokenTransferVote(1, voteDesc, duration, 2, accounts[5], {'from': accounts[0]})

    readVotesCount = pageVoteForEarn.readTokenTransferVotesCount(1)
    assert readVotesCount == 1

    pageToken.transfer(someUser, 100, {'from': treasury})
    pageToken.transfer(deployer, 100, {'from': treasury})

    pageBank.setPriceForPrivacyAccess(1, 1, {'from': pageVoteForEarn})
    pageToken.approve(pageBank, 100, {'from': treasury})
    pageBank.addBalance(100, {'from': treasury})
    pageBank.payForPrivacyAccess(100, 1, {'from': treasury})

    pageVoteForEarn.putTokenTransferVote(1, 0, True, {'from': someUser})
    pageVoteForEarn.putTokenTransferVote(1, 0, True, {'from': deployer})

    readVote = pageVoteForEarn.readTokenTransferVote(1, 0)
    assert readVote[8] == True

    with reverts():
        pageVoteForEarn.executeTokenTransferVote(1, 0, {'from': someUser})

    chain.sleep(duration + 10)
    pageVoteForEarn.executeTokenTransferVote(1, 0, {'from': someUser})

    readVote = pageVoteForEarn.readTokenTransferVote(1, 0)
    assert readVote[8] == False


def test_execute_nft_transfer_vote(chain, accounts, pageCommunity, pageVoteForFeeAndModerator, pageVoteForEarn, pageToken, pageNFT, someUser, deployer, treasury):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    pageCommunity.join(1, {'from': deployer})

    pageToken.transfer(someUser, 100, {'from': treasury})
    pageToken.transfer(deployer, 100, {'from': treasury})
    network.gas_price("65 gwei")

    assert pageVoteForFeeAndModerator == pageCommunity.voterContracts(0)
    assert pageVoteForEarn == pageCommunity.voterContracts(1)

    pageCommunity.setPostOwner(1, {'from': pageVoteForFeeAndModerator})

    pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})
    pageCommunity.writePost(1, 'aaaa', deployer, {'from': someUser})

    voteDesc = 'test for vote'
    pageVoteForEarn.createNftTransferVote(1, voteDesc, duration, 1, accounts[5], {'from': accounts[0]})

    readVotesCount = pageVoteForEarn.readNftTransferVotesCount(1)
    assert readVotesCount == 1

    pageVoteForEarn.putNftTransferVote(1, 0, True, {'from': someUser})
    pageVoteForEarn.putNftTransferVote(1, 0, True, {'from': deployer})

    readVote = pageVoteForEarn.readNftTransferVote(1, 0)
    assert readVote[8] == True

    with reverts():
        pageVoteForEarn.executeNftTransferVote(1, 0, {'from': someUser})

    chain.sleep(duration + 10)

    tokens = pageNFT.tokensOfOwner(pageCommunity)
    assert tokens == (0,1)

    pageNFT.approve(accounts[5], 1, {'from': pageCommunity})

    pageVoteForEarn.executeNftTransferVote(1, 0, {'from': someUser})

    readVote = pageVoteForEarn.readNftTransferVote(1, 0)
    assert readVote[8] == False



