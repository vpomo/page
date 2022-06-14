from brownie import Contract, PageProxy, PageOracle
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    token = config.get_proxy_token()
    pool = config.get_pool()
    bank = config.get_proxy_bank()

    print("deployer:", deployer)
    print("admin:", admin)
    print("token:", token)
    print("pool:", pool)
    print("bank:", bank)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageOracle = PageOracle.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageOracle, admin, {'from': deployer}, publish_source=True)

    proxyPageOracle = Contract.from_explorer(pageProxy, as_proxy_for=pageOracle)
    proxyPageOracle.initialize(token, pool, {'from': deployer})

    bank.setOracle(proxyPageOracle, {'from': deployer})
