from brownie import Contract, PageProxy, PageNFT
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    bank = config.get_proxy_bank()
    nft_url = config.get_nft_url()

    print("deployer:", deployer)
    print("admin:", admin)
    print("bank:", bank)
    print("nft_url:", nft_url)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageNFT = PageNFT.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageNFT, admin, {'from': deployer}, publish_source=True)

    proxyPageNFT = Contract.from_explorer(pageProxy, as_proxy_for=pageNFT)
    proxyPageNFT.initialize(bank, nft_url, {'from': deployer})
