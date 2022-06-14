from brownie import Contract, PageProxy, PageSafeDeal
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    calc_user_rate = config.get_proxy_calc_user_rate()
    oracle = config.get_proxy_oracle()
    token = config.get_proxy_token()

    print("deployer:", deployer)
    print("admin:", admin)
    print("calc_user_rate:", calc_user_rate)
    print("oracle:", oracle)
    print("token:", token)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageSafeDeal = PageSafeDeal.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageSafeDeal, admin, {'from': deployer}, publish_source=True)

    proxySafeDeal = Contract.from_explorer(pageProxy, as_proxy_for=pageSafeDeal)
    proxySafeDeal.initialize(admin, calc_user_rate, oracle, {'from': deployer})
    proxySafeDeal.setToken(token, {'from': deployer})

    calc_user_rate.grantRole(calc_user_rate.DEAL_ROLE(), proxySafeDeal, {'from': admin})
