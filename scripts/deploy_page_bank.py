from brownie import PageBank, Wei
from utils import config


def main():
    deployer = config.get_deployer_account(config.get_is_live())
    print("Deployer:", deployer)

    sys.stdout.write("Proceed? [y/n]: ")
    if not config.prompt_bool():
        print("Aborting")
        return

    PageBank.deploy(deployer, {'from': deployer}, publish_source=True)


