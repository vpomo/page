from brownie import Contract, PageProxy, PageUserRateToken
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    url = config.get_rate_token_url()
    print("Deployer:", deployer)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageUserRateToken = PageUserRateToken.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageUserRateToken, admin, {'from': deployer}, publish_source=True)

    proxyUserRateToken = Contract.from_explorer(pageProxy, as_proxy_for=pageUserRateToken)
    proxyUserRateToken.initialize(url, {'from': deployer})

