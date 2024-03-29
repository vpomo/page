import pytest
from brownie import Wei, ZERO_ADDRESS

FTM_TOKEN = '0x4e15361fd6b4bb609fa63c81a2be19d873717870';
FTM_ETH_POOL = '0x3b685307c8611afb2a9e83ebc8743dc20480716e' #FTM/ETH

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
def pageUserRateToken(PageUserRateToken, deployer):
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
def pageOracle(PageOracle, deployer, pageToken, pageBank):
    instanсe = PageOracle.deploy({'from': deployer})
    instanсe.initialize(FTM_TOKEN, FTM_ETH_POOL)
    pageBank.setOracle(instanсe, {'from': deployer})
    return instanсe


@pytest.fixture(scope="module")
def pageSafeDeal(PageSafeDeal, admin, deployer, pageCalcUserRate, pageToken, pageOracle):
    instanсe = PageSafeDeal.deploy({'from': deployer})
    instanсe.initialize(admin, pageCalcUserRate, pageOracle)
    instanсe.setToken(pageToken, {'from': deployer})
    pageCalcUserRate.grantRole(pageCalcUserRate.DEAL_ROLE(), instanсe, {'from': admin})

    return instanсe


@pytest.fixture(scope="module")
def pageNFT(PageNFT, pageBank, treasury, deployer):
    instanсe = PageNFT.deploy({'from': deployer})
    instanсe.initialize(pageBank, 'https://')
    return instanсe


@pytest.fixture(scope="module")
def pageCommunity(PageCommunity, pageNFT, pageUserRateToken, pageBank, pageToken, pageOracle, deployer, admin):
    instanсe = PageCommunity.deploy({'from': deployer})
    instanсe.initialize(pageNFT, pageBank, admin)
    assert deployer == pageNFT.owner()

    pageNFT.setCommunity(instanсe, {'from': deployer})

    deployer.transfer(instanсe, Wei('10 ether'))

    pageBank.grantRole(pageBank.MINTER_ROLE(), instanсe, {'from': admin})
    pageBank.grantRole(pageBank.BURNER_ROLE(), instanсe, {'from': admin})
    pageBank.setToken(pageToken, {'from': deployer})
    pageBank.setOracle(pageOracle, {'from': deployer})

    return instanсe


@pytest.fixture(scope="module")
def pageVoteForCommon(PageVoteForCommon, deployer, pageToken, pageCommunity, pageBank, pageOracle, admin):
    instanсe = PageVoteForCommon.deploy({'from': deployer})
    instanсe.initialize(deployer, pageToken, pageCommunity, pageBank)
    deployer.transfer(instanсe, Wei('10 ether'))

    pageBank.grantRole(pageBank.UPDATER_FEE_ROLE(), instanсe, {'from': admin})
    pageBank.setOracle(pageOracle, {'from': deployer})

    pageCommunity.addVoterContract(instanсe, {'from': deployer})

    return instanсe


@pytest.fixture(scope="module")
def pageVoteForEarn(pageVoteForCommon, PageVoteForEarn, deployer, pageToken, pageCommunity, pageBank, pageOracle, admin):
    instanсe = PageVoteForEarn.deploy({'from': deployer})
    instanсe.initialize(admin, pageToken, pageCommunity, pageBank)
    deployer.transfer(instanсe, Wei('10 ether'))
    pageBank.grantRole(pageBank.VOTE_FOR_EARN_ROLE(), instanсe, {'from': admin})
    pageBank.setOracle(pageOracle, {'from': deployer})
    pageCommunity.addVoterContract(instanсe, {'from': deployer})
    return instanсe


@pytest.fixture(scope="module")
def pageVoteForSuperModerator(pageVoteForCommon, pageVoteForEarn, PageVoteForSuperModerator, deployer, pageToken, pageCommunity, pageBank, pageOracle, admin):
    instanсe = PageVoteForSuperModerator.deploy({'from': deployer})
    instanсe.initialize(admin, pageToken, pageCommunity, pageBank)
    pageCommunity.addVoterContract(instanсe, {'from': deployer})
    pageBank.setOracle(pageOracle, {'from': deployer})

    assert pageVoteForCommon == pageCommunity.voterContracts(0)
    assert pageVoteForEarn == pageCommunity.voterContracts(1)
    assert instanсe == pageCommunity.voterContracts(2)

    return instanсe
