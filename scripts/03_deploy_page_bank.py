from brownie import Contract, PageProxy, PageBank
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    treasury = config.get_treasury()
    calcUserRate = config.get_proxy_calc_user_rate()

    print("deployer:", deployer)
    print("admin:", admin)
    print("calcUserRate:", calcUserRate)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageBank = PageBank.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageBank, admin, {'from': deployer}, publish_source=True)

    proxyBank = Contract.from_explorer(pageProxy, as_proxy_for=pageBank)
    proxyBank.initialize(treasury, admin, calcUserRate, {'from': deployer})

    calcUserRate.grantRole(calcUserRate.BANK_ROLE(), proxyBank, {'from': admin})
