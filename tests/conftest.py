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
def pageOracle(PageOracle, deployer, pageToken):
    instanсe = PageOracle.deploy({'from': deployer})
    instanсe.initialize(FTM_TOKEN, FTM_ETH_POOL)
    return instanсe


@pytest.fixture(scope="module")
def pageSafeDeal(PageSafeDeal, admin, deployer, pageCalcUserRate, pageToken, pageBank):
    instanсe = PageSafeDeal.deploy({'from': deployer})
    instanсe.initialize(admin, pageCalcUserRate, pageBank)
    instanсe.setToken(pageToken, {'from': deployer})
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

    return instanсe


@pytest.fixture(scope="module")
def pageVoteForEarn(pageVoteForFeeAndModerator, PageVoteForEarn, deployer, pageToken, pageCommunity, pageBank, admin):
    instanсe = PageVoteForEarn.deploy({'from': deployer})
    instanсe.initialize(admin, pageToken, pageCommunity, pageBank)
    deployer.transfer(instanсe, Wei('10 ether'))
    pageBank.grantRole(pageBank.VOTE_FOR_EARN_ROLE(), instanсe, {'from': admin})
    pageCommunity.addVoterContract(instanсe, {'from': deployer})
    return instanсe


@pytest.fixture(scope="module")
def pageVoteForSuperModerator(pageVoteForFeeAndModerator, pageVoteForEarn, PageVoteForSuperModerator, deployer, pageToken, pageCommunity, pageBank, admin):
    instanсe = PageVoteForSuperModerator.deploy({'from': deployer})
    instanсe.initialize(admin, pageToken, pageCommunity, pageBank)
    pageCommunity.addVoterContract(instanсe, {'from': deployer})
    assert pageVoteForFeeAndModerator == pageCommunity.voterContracts(0)
    assert pageVoteForEarn == pageCommunity.voterContracts(1)
    assert instanсe == pageCommunity.voterContracts(2)

    return instanсe
