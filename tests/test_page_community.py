import pytest
from brownie import ZERO_ADDRESS, chain, reverts, network
import brownie

TOKEN_VERSION = 1


def test_deployment(pageCommunity):
    print('='*20 + ' running for pageCommunity ... ' + '='*20)
    assert pageCommunity != ZERO_ADDRESS


def test_add_read_community(pageCommunity):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    assert pageCommunity.communityCount() == 1
    community = pageCommunity.readCommunity(1)
    # ('First users', '0x66aB6D9362d4F35596279692F0251Db635165871', (), (), (), 0, True)

    assert community[0] == communityName


def test_add_remove_moderator(pageCommunity, pageVoteForCommon, accounts, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    assert pageCommunity.communityCount() == 1

    pageCommunity.join(1, {'from': accounts[2]})
    pageCommunity.join(1, {'from': accounts[3]})

    pageCommunity.addModerator(1, accounts[2], {'from': pageVoteForCommon})
    pageCommunity.addModerator(1, accounts[3], {'from': pageVoteForCommon})
    community = pageCommunity.readCommunity(1)
    assert community[2][0] == accounts[2]
    assert community[2][1] == accounts[3]

    pageCommunity.removeModerator(1, accounts[2], {'from': pageVoteForCommon})
    community = pageCommunity.readCommunity(1)
    assert community[2][0] == accounts[3]


def test_find_moderator(pageCommunity, pageVoteForCommon, accounts, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    assert pageCommunity.communityCount() == 1

    pageCommunity.join(1, {'from': accounts[2]})
    pageCommunity.join(1, {'from': accounts[3]})

    pageCommunity.addModerator(1, accounts[2], {'from': pageVoteForCommon})
    pageCommunity.addModerator(1, accounts[3], {'from': pageVoteForCommon})
    community = pageCommunity.readCommunity(1)
    assert community[2][0] == accounts[2]
    assert community[2][1] == accounts[3]

    isCommunityModerator = pageCommunity.isCommunityModerator(1, accounts[2], {'from': deployer})
    assert isCommunityModerator == True
    isCommunityModerator = pageCommunity.isCommunityModerator(1, accounts[3], {'from': deployer})
    assert isCommunityModerator == True


def test_join_quit(pageCommunity, someUser):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    assert pageCommunity.communityCount() == 1

    isCommunityActiveUser = pageCommunity.isCommunityActiveUser(1, someUser)
    assert isCommunityActiveUser == False

    pageCommunity.join(1, {'from': someUser})
    isCommunityActiveUser = pageCommunity.isCommunityActiveUser(1, someUser)
    assert isCommunityActiveUser == True

    pageCommunity.quit(1, {'from': someUser})
    isCommunityActiveUser = pageCommunity.isCommunityActiveUser(1, someUser)
    assert isCommunityActiveUser == False


def test_write_read_Post(pageBank, pageCommunity, someUser, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    network.gas_price("65 gwei")

    with reverts():
        pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})

    pageCommunity.join(1, {'from': deployer})
    pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})
    pageCommunity.writePost(1, 'aaaa', deployer, {'from': someUser})

    assert pageCommunity.isActiveCommunityByPostId(0) == True
    assert pageCommunity.isActiveCommunityByPostId(1) == True
    assert pageCommunity.isActiveCommunityByPostId(2) == False

    readPost = pageCommunity.readPost(0)
    #('dddd', '0xA868bC7c1AF08B8831795FAC946025557369F69C', '0x66aB6D9362d4F35596279692F0251Db635165871', 0, 0, 12122487000000000000, 0, (), True)
    assert readPost[0] == 'dddd'

    readPost = pageCommunity.readPost(1)
    assert readPost[0] == 'aaaa'


def test_write_read_Comment(pageBank, pageCommunity, someUser, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    network.gas_price("65 gwei")

    with reverts():
        pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})

    pageCommunity.join(1, {'from': deployer})
    pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})

    pageCommunity.writeComment(0, 'dddd-dddd', True, False, deployer, {'from': someUser})

    readComment = pageCommunity.readComment(0, 0)
    #readComment ('dddd-dddd', '0xA868bC7c1AF08B8831795FAC946025557369F69C', '0x66aB6D9362d4F35596279692F0251Db635165871', 7287969000000000000, True, False, True)
    assert readComment[0] == 'dddd-dddd'
    assert readComment[1] == someUser
    assert readComment[2] == deployer
    assert readComment[3] > 0
    assert readComment[4] == True
    assert readComment[5] == False
    assert readComment[6] == True

    with reverts():
        pageCommunity.writeComment(0, 'dddd-dddd', True, True, deployer, {'from': someUser})


def test_write_burn_Post(pageBank, pageCommunity, someUser, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    network.gas_price("65 gwei")

    with reverts():
        pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})

    pageCommunity.join(1, {'from': deployer})
    pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})
    tx = pageCommunity.writePost(1, 'aaaa', deployer, {'from': someUser})
    #print('tx write post ', tx.info());
    # Gas Used: All = 430758;

    readPost = pageCommunity.readPost(0)
    #('dddd', '0xA868bC7c1AF08B8831795FAC946025557369F69C', '0x66aB6D9362d4F35596279692F0251Db635165871', 0, 0, 12122487000000000000, 0, (), True)
    assert readPost[0] == 'dddd'

    readPost = pageCommunity.readPost(1)
    assert readPost[0] == 'aaaa'

    tx = pageCommunity.burnPost(0)
    #print('tx burn post ', tx.info());
    # Gas Used: All = 119503;

    readPost = pageCommunity.readPost(0)
    #('', '0x0000000000000000000000000000000000000000', '0x0000000000000000000000000000000000000000', 0, 0, 12122487000000000000, 0, (), False)
    assert readPost[0] == ''
    assert readPost[1] == ZERO_ADDRESS
    assert readPost[2] == ZERO_ADDRESS


def test_write_burn_Comment(accounts, pageBank, pageCommunity, pageToken, pageVoteForCommon, someUser, deployer, treasury):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    network.gas_price("65 gwei")

    with reverts():
        pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})

    pageCommunity.join(1, {'from': deployer})
    pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})

    tx = pageCommunity.writeComment(0, 'dddd-dddd', True, False, deployer, {'from': someUser})
    #print('tx write comment ', tx.info());
    # Gas Used: All = 288168;

    with reverts():
        pageCommunity.writeComment(0, 'dddd-dddd-dddd', True, False, deployer, {'from': someUser})

    pageCommunity.writeComment(0, 'dddd-dddd-dddd', False, False, deployer, {'from': someUser})
    count = pageCommunity.getCommentCount(0)
    assert count == 2

    readComment = pageCommunity.readComment(0, 0)
    #readComment ('dddd-dddd', '0xA868bC7c1AF08B8831795FAC946025557369F69C', '0x66aB6D9362d4F35596279692F0251Db635165871', 7287969000000000000, True, False, True)
    assert readComment[0] == 'dddd-dddd'

    with reverts():
        pageCommunity.burnComment(0,0)

    pageCommunity.join(1, {'from': accounts[2]})

    pageCommunity.addModerator(1, accounts[2], {'from': pageVoteForCommon})

    amount = 10000000000000000000000;
    pageToken.transfer(someUser, amount, {'from': treasury})
    pageToken.approve(pageBank, amount, {'from': someUser})
    pageBank.addBalance(amount, {'from': someUser})

    pageToken.transfer(accounts[2], amount, {'from': treasury})
    pageToken.approve(pageBank, amount, {'from': accounts[2]})
    pageBank.addBalance(amount, {'from': accounts[2]})

    tx = pageCommunity.burnComment(0,0, {'from': accounts[2]})
    #print('tx burn comment ', tx.info());
    # Gas Used: All = 69089;

    count = pageCommunity.getCommentCount(0)
    assert count == 2

    readComment = pageCommunity.readComment(0, 0)
    assert readComment[0] == ''


def test_visibility(accounts, pageCommunity, pageVoteForCommon, someUser, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    network.gas_price("65 gwei")

    pageCommunity.join(1, {'from': deployer})
    pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})
    readPost = pageCommunity.readPost(0)
    postVisible = readPost[8]
    assert postVisible == True


    pageCommunity.writeComment(0, 'dddd-dddd', True, False, deployer, {'from': someUser})
    readComment = pageCommunity.readComment(0, 0)
    commentVisible = readComment[6]
    assert commentVisible == True

    pageCommunity.join(1, {'from': accounts[2]})

    pageCommunity.addModerator(1, accounts[2], {'from': pageVoteForCommon})

    with reverts():
        pageCommunity.setVisibilityComment(0, 0, False, {'from': someUser})

    pageCommunity.setVisibilityComment(0, 0, False, {'from': accounts[2]})
    readComment = pageCommunity.readComment(0, 0)
    commentVisible = readComment[6]
    assert commentVisible == False

    with reverts():
        pageCommunity.setPostVisibility(0, False, {'from': someUser})

    pageCommunity.setPostVisibility(0, False, {'from': accounts[2]})
    readPost = pageCommunity.readPost(0)
    postVisible = readPost[8]
    assert postVisible == False


def test_banned_user(accounts, pageBank, pageCommunity, pageVoteForCommon, someUser, deployer, treasury):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    network.gas_price("65 gwei")

    with reverts():
        pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})

    pageCommunity.join(1, {'from': deployer})
    pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})

    pageCommunity.join(1, {'from': accounts[2]})
    pageCommunity.join(1, {'from': accounts[3]})

    pageCommunity.addModerator(1, accounts[2], {'from': pageVoteForCommon})
    pageCommunity.addModerator(1, accounts[3], {'from': pageVoteForCommon})

    pageCommunity.addBannedUser(1, someUser, {'from': accounts[2]})

    with reverts():
        pageCommunity.writePost(1, 'dddd-ssss', deployer, {'from': someUser})

    pageCommunity.removeBannedUser(1, someUser, {'from': accounts[2]})
    pageCommunity.writePost(1, 'dddd-ssss', deployer, {'from': someUser})


def test_community_activity(accounts, pageCommunity, pageVoteForCommon, someUser, deployer):
    communityName = 'First users'
    pageCommunity.addCommunity(communityName)
    pageCommunity.join(1, {'from': someUser})
    network.gas_price("65 gwei")

    pageCommunity.join(1, {'from': deployer})
    pageCommunity.writePost(1, 'dddd', deployer, {'from': someUser})
    readPost = pageCommunity.readPost(0)
    postVisible = readPost[8]
    assert postVisible == True

    isActiveCommunity = pageCommunity.isActiveCommunity(1)
    assert isActiveCommunity == True

    pageCommunity.changeCommunityActive(1,{'from': pageVoteForCommon})

    isActiveCommunity = pageCommunity.isActiveCommunity(1)
    assert isActiveCommunity == False

    with reverts():
        pageCommunity.writeComment(0, 'dddd-dddd', True, False, deployer, {'from': someUser})

    with reverts():
        pageCommunity.join(1, {'from': accounts[2]})

    with reverts():
        pageCommunity.addModerator(1, accounts[2], {'from': pageVoteForCommon})

    with reverts():
        pageCommunity.setVisibilityComment(0, 0, False, {'from': someUser})

    with reverts():
        pageCommunity.setPostVisibility(0, False, {'from': someUser})

    pageCommunity.changeCommunityActive(1,{'from': pageVoteForCommon})

    isActiveCommunity = pageCommunity.isActiveCommunity(1)
    assert isActiveCommunity == True

    pageCommunity.addModerator(1, deployer, {'from': pageVoteForCommon})
    pageCommunity.setPostVisibility(0, False, {'from': deployer})
    readPost = pageCommunity.readPost(0)
    postVisible = readPost[8]
    assert postVisible == False

