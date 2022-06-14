from brownie import Contract, PageProxy, PageToken
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    treasury = config.get_treasury()
    bank = config.get_proxy_bank()

    print("deployer:", deployer)
    print("admin:", admin)
    print("treasury:", treasury)
    print("bank:", bank)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageToken = PageToken.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageToken, admin, {'from': deployer}, publish_source=True)

    proxyPageToken = Contract.from_explorer(pageProxy, as_proxy_for=pageToken)
    proxyPageToken.initialize(treasury, bank, {'from': deployer})

    bank.setToken(proxyPageToken, {'from': deployer})
