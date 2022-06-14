from brownie import Contract, PageProxy, PageCommunity
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    nft = config.get_proxy_nft()
    bank = config.get_proxy_bank()
    token = config.get_proxy_token()
    oracle =config.get_proxy_oracle()

    print("deployer:", deployer)
    print("admin:", admin)
    print("nft:", nft)
    print("bank:", bank)
    print("token:", token)
    print("oracle:", oracle)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageCommunity = PageCommunity.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageCommunity, admin, {'from': deployer}, publish_source=True)

    proxyPageCommunity = Contract.from_explorer(pageProxy, as_proxy_for=pageCommunity)
    proxyPageCommunity.initialize(nft, bank, admin, {'from': deployer})

    nft.setCommunity(proxyPageCommunity, {'from': deployer})

    bank.grantRole(bank.MINTER_ROLE(), proxyPageCommunity, {'from': admin})
    bank.grantRole(bank.BURNER_ROLE(), proxyPageCommunity, {'from': admin})
    bank.setToken(token, {'from': deployer})
    bank.setOracle(oracle, {'from': deployer})

