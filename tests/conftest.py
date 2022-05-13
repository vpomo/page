import pytest
from brownie import Wei, ZERO_ADDRESS

@pytest.fixture(scope='function', autouse=True)
def shared_setup(fn_isolation):
    pass


@pytest.fixture(scope='module')
def deployer(accounts):
    return accounts[0]


@pytest.fixture(scope='module')
def admin(accounts):
    return accounts[1]


@pytest.fixture(scope='module')
def treasury(accounts):
    return accounts[9]

@pytest.fixture(scope='module')
def someUser(accounts):
    return accounts[8]


@pytest.fixture(scope='module')
def helpers():
    return Helpers

@pytest.fixture(scope="module")
def pageUserRateToken(PageUserRateToken, treasury, deployer):
    instanсe = PageUserRateToken.deploy({'from': deployer})
    instanсe.initialize('https://')
    return instanсe


@pytest.fixture(scope="module")
def pageCalcUserRate(PageCalcUserRate, pageUserRateToken, deployer, admin):
    instanсe = PageCalcUserRate.deploy({'from': deployer})
    instanсe.initialize(admin, pageUserRateToken)
    pageUserRateToken.setCalcRateContract(instanсe)
    deployer.transfer(instanсe, Wei('10 ether'))

    return instanсe


@pytest.fixture(scope="module")
def pageBank(PageBank, pageCalcUserRate, treasury, admin, deployer):
    instanсe = PageBank.deploy({'from': deployer})
    instanсe.initialize(treasury, admin, pageCalcUserRate)
    instanсe.setWETHPagePool('0x3b685307c8611afb2a9e83ebc8743dc20480716e', {'from': deployer}) #FTM/ETH
    deployer.transfer(instanсe, Wei('10 ether'))

    pageCalcUserRate.grantRole(pageCalcUserRate.BANK_ROLE(), instanсe, {'from': admin})

    return instanсe


@pytest.fixture(scope="module")
def pageToken(PageToken, treasury, deployer, pageBank):
    instanсe = PageToken.deploy({'from': deployer})
    instanсe.initialize(treasury, pageBank)
    pageBank.setToken(instanсe, {'from': deployer})
    return instanсe


@pytest.fixture(scope="module")
def pageNFT(PageNFT, pageBank, treasury, deployer):
    instanсe = PageNFT.deploy({'from': deployer})
    instanсe.initialize(pageBank, 'https://')
    return instanсe


@pytest.fixture(scope="module")
def pageCommunity(PageCommunity, pageNFT, pageUserRateToken, pageBank, pageToken, deployer, admin):
    instanсe = PageCommunity.deploy({'from': deployer})
    instanсe.initialize(pageNFT, pageBank, admin)
    assert deployer == pageNFT.owner()

    pageNFT.setCommunity(instanсe, {'from': deployer})

    deployer.transfer(instanсe, Wei('10 ether'))

    pageBank.grantRole(pageBank.MINTER_ROLE(), instanсe, {'from': admin})
    pageBank.grantRole(pageBank.BURNER_ROLE(), instanсe, {'from': admin})
    pageBank.setToken(pageToken, {'from': deployer})

    return instanсe


@pytest.fixture(scope="module")
def pageVoteForFeeAndModerator(PageVoteForFeeAndModerator, deployer, pageToken, pageCommunity, pageBank, admin):
    instanсe = PageVoteForFeeAndModerator.deploy({'from': deployer})
    instanсe.initialize(deployer, pageToken, pageCommunity, pageBank)
    deployer.transfer(instanсe, Wei('10 ether'))

    pageBank.grantRole(pageBank.UPDATER_FEE_ROLE(), instanсe, {'from': admin})

    pageCommunity.addVoterContract(instanсe, {'from': deployer})
    #pageCommunity.grantRole(pageCommunity.VOTER_ROLE(), instanсe, {'from': admin})
    #pageCommunity.grantRole(pageCommunity.VOTER_ROLE(), deployer, {'from': admin})

    return instanсe


@pytest.fixture(scope="module")
def pageVoteForEarn(PageVoteForEarn, deployer, pageToken, pageCommunity, pageBank, admin):
    instanсe = PageVoteForEarn.deploy({'from': deployer})
    instanсe.initialize(admin, pageToken, pageCommunity, pageBank)
    deployer.transfer(instanсe, Wei('10 ether'))
    pageBank.grantRole(pageBank.VOTE_FOR_EARN_ROLE(), instanсe, {'from': admin})
    pageCommunity.addVoterContract(instanсe, {'from': deployer})
    return instanсe

