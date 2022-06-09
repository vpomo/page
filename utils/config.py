import os
import sys
from brownie import network, accounts
#before <export ETHERSCAN_TOKEN=AKTI...4HZ>


def get_is_live():
    return network.show_active() != "rinkeby" #mainnet


def get_deployer_account(is_live):
    if not is_live:
        deployer = accounts.add('0x...5e5283ba') #private key
        return deployer


def prompt_bool():
    choice = input().lower()
    if choice in {"yes", "y"}:
        return True
    elif choice in {"no", "n"}:
        return False
    else:
        sys.stdout.write("Please respond with 'yes' or 'no'")


def get_env(name, default=None):
    if name not in os.environ:
        if default is not None:
            return default
        raise EnvironmentError(f"Please set {name} env variable")
    return os.environ[name]
