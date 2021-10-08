#!/bin/bash

MINTER_ADDRESS="0xcE65382a0a49C8b3Cf3C1C446d15DBAA14FCAb86"

PAGE_PROFILE=$( cat contracts.json | jq '.PAGE_PROFILE' | sed 's/"//g' )

#RINKEBY
echo "PAGE_PROFILE = $PAGE_PROFILE"
npx hardhat verify --network rinkeby --contract contracts/CryptoPageProfile.sol:PageProfile $PAGE_PROFILE "$MINTER_ADDRESS"
