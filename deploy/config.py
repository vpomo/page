import os
import sys
from brownie import network, accounts, Contract, PageCalcUserRate
#before <export ETHERSCAN_TOKEN=AKTI...4HZ>

#========= main addreses ============
rate_token_url = 'https://'
deployer_private_key = '0x9...ba'

admin = '0x0000000000000000000000000000000000000001'

user_rate_token = '0x0000000000000000000000000000000000000001' #It will be known after the installation of the PageUserRateToken
proxy_user_rate_token = '0x0000000000000000000000000000000000000001' #It will be known after the installation of the PageUserRateToken


#========= proxy contracts ============



def get_is_live():
    return network.show_active() != "rinkeby" #mainnet

def get_admin():
    return accounts.at(admin)

def get_rate_token_url():
    return rate_token_url

def get_proxy_user_rate_token():
    return Contract.from_explorer(proxy_user_rate_token, as_proxy_for=user_rate_token)

def get_deployer_account(is_live):
    if not is_live:
        deployer = accounts.add(deployer_private_key)
        return deployer

def get_proxy_bank():
    return Contract.from_explorer('0x87fc6fb07b8fc018b34126bdf390f7d0a711e2f5', as_proxy_for='0xec95a659153634c87417a2d95f0b561221288649')

def get_calc_user_rate():
    return Contract.from_explorer('0x7e47dd1b1689b9ab3ce3c54e2ccb9a97054c52ac')


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
