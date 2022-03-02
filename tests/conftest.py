import pytest
from brownie import ZERO_ADDRESS

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
def helpers():
    return Helpers


@pytest.fixture(scope="module")
def pageBank(PageBank, treasury, deployer, admin):
    instanсe = PageBank.deploy({'from': deployer})
    instanсe.initialize(treasury, admin, 100)
    return instanсe


@pytest.fixture(scope="module")
def pageToken(PageToken, treasury, deployer, pageBank):
    instanсe = PageToken.deploy({'from': deployer})
    instanсe.initialize(treasury, pageBank)
    return instanсe
