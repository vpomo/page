import os
import sys
from brownie import network, accounts, Contract, PageCalcUserRate
#before <export ETHERSCAN_TOKEN=AKTI...4HZ>

#========= main addreses ============
rate_token_url = 'https://'
nft_url = 'https://'
deployer_private_key = '0x9...ba'
admin_private_key = '0x9...ba'

admin = '0x0000000000000000000000000000000000000000'
treasury = '0x0000000000000000000000000000000000000000'
page_token_pool = '0x0000000000000000000000000000000000000000'

user_rate_token = '0x0000000000000000000000000000000000000000' #It will be known after the installation of the PageUserRateToken
proxy_user_rate_token = '0x0000000000000000000000000000000000000000' #It will be known after the installation of the PageUserRateToken

calc_user_rate = '0x0000000000000000000000000000000000000000'
proxy_calc_user_rate = '0x0000000000000000000000000000000000000000'

bank = '0x0000000000000000000000000000000000000000'
proxy_bank = '0x0000000000000000000000000000000000000000'

token = '0x0000000000000000000000000000000000000000'
proxy_token = '0x0000000000000000000000000000000000000000'

oracle = '0x0000000000000000000000000000000000000000'
proxy_oracle = '0x0000000000000000000000000000000000000000'

nft = '0x0000000000000000000000000000000000000000'
proxy_nft = '0x0000000000000000000000000000000000000000'

#========= proxy contracts ============



def get_is_live():
    return network.show_active() != "rinkeby" #mainnet

def get_admin():
    return accounts.add(admin_private_key)

def get_treasury():
    return accounts.at(treasury)

def get_pool():
    return accounts.add(page_token_pool)

def get_rate_token_url():
    return rate_token_url

def get_nft_url():
    return nft_url

def get_proxy_user_rate_token():
    return Contract.from_explorer(proxy_user_rate_token, as_proxy_for=user_rate_token)

def get_proxy_calc_user_rate():
    return Contract.from_explorer(proxy_calc_user_rate, as_proxy_for=calc_user_rate)

def get_proxy_bank():
    return Contract.from_explorer(proxy_bank, as_proxy_for=bank)

def get_proxy_token():
    return Contract.from_explorer(proxy_token, as_proxy_for=token)

def get_proxy_oracle():
    return Contract.from_explorer(proxy_oracle, as_proxy_for=oracle)

def get_proxy_nft():
    return Contract.from_explorer(proxy_nft, as_proxy_for=nft)


def get_deployer_account(is_live):
    if not is_live:
        deployer = accounts.add(deployer_private_key)
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
