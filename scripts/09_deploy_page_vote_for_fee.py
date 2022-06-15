from brownie import Contract, PageProxy, PageVoteForFeeAndModerator
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    token = config.get_proxy_token()
    community =config.get_proxy_community()
    bank = config.get_proxy_bank()

    print("deployer:", deployer)
    print("admin:", admin)
    print("token:", token)
    print("community:", community)
    print("bank:", bank)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageVote = PageVoteForFeeAndModerator.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageVote, admin, {'from': deployer}, publish_source=True)

    proxyPageVote = Contract.from_explorer(pageProxy, as_proxy_for=pageVote)
    proxyPageVote.initialize(admin, token, community, bank, {'from': deployer})

    bank.grantRole(bank.UPDATER_FEE_ROLE(), proxyPageVote, {'from': admin})
    community.addVoterContract(proxyPageVote, {'from': deployer})


