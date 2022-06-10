from brownie import PageBank, PageProxy, PageCalcUserRate
from deploy import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    treasury = deployer
    calcUserRate = config.get_calc_user_rate()
    proxyPageBank = config.get_proxy_bank()

    print("Deployer:", deployer)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    proxyPageBank.initialize(treasury, admin, calcUserRate, {'from': deployer})


