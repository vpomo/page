from brownie import Contract, PageBank, PageProxy, PageCalcUserRate
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    treasury = deployer
    calcUserRate = config.get_calc_user_rate()
    print("Deployer:", deployer)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageBank = PageBank.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageBank, admin, {'from': deployer}, publish_source=True)

    proxyPageBank = Contract.from_explorer(pageProxy, as_proxy_for=pageBank)
    proxyPageBank.initialize(treasury, admin, calcUserRate, {'from': deployer})

