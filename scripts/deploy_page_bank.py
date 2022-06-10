from brownie import PageBank, PageProxy, PageCalcUserRate
from utils import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    admin = config.get_admin()
    treasury = deployer
    calcUserRate = PageCalcUserRate.at("0x7e47dd1b1689b9ab3ce3c54e2ccb9a97054c52ac")

    print("Deployer:", deployer)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    pageBank = PageBank.deploy({'from': deployer}, publish_source=True)
    pageProxy = PageProxy.deploy(pageBank, admin, {'from': deployer}, publish_source=True)


