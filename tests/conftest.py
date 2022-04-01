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
def pageBank(PageBank, treasury, admin, deployer):
    instanсe = PageBank.deploy({'from': deployer})
    instanсe.initialize(treasury, admin)
    instanсe.setWETHPagePool('0x64a078926ad9f9e88016c199017aea196e3899e1', {'from': deployer})
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
def pageCommunity(PageCommunity, pageNFT, pageBank, pageToken, deployer, admin):
    instanсe = PageCommunity.deploy({'from': deployer})
    instanсe.initialize(pageNFT, pageBank)
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

    return instanсe
