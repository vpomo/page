from brownie import Contract, PageProxy, PageCalcUserRate
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    userRateToken = config.get_proxy_user_rate_token()
    print("deployer:", deployer)
    print("admin:", admin)
    print("userRateToken:", userRateToken)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageCalcUserRate = PageCalcUserRate.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageCalcUserRate, admin, {'from': deployer}, publish_source=True)

    proxyCalcUserRate = Contract.from_explorer(pageProxy, as_proxy_for=pageCalcUserRate)
    proxyCalcUserRate.initialize(admin, userRateToken, {'from': deployer})

