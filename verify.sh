#!/bin/bash

TRESHERY_ADDRESS="0x09d6a2224c62ec977bc29e438c3cf0df16d4775a"

PAGE_ADMIN=$( cat contracts.json | jq '.PAGE_ADMIN' | sed 's/"//g' )
PAGE_TOKEN=$( cat contracts.json | jq '.PAGE_TOKEN' | sed 's/"//g' )
PAGE_NFT=$( cat contracts.json | jq '.PAGE_NFT' | sed 's/"//g' )
PAGE_MINTER=$( cat contracts.json | jq '.PAGE_MINTER' | sed 's/"//g' )

#RINKEBY
echo "PAGE_ADMIN = $PAGE_ADMIN"
npx hardhat verify --network rinkeby --contract contracts/CryptoPageAdmin.sol:PageAdmin $PAGE_ADMIN "$TRESHERY_ADDRESS"

echo "PAGE_TOKEN = $PAGE_TOKEN"
npx hardhat verify --network rinkeby --contract contracts/CryptoPageToken.sol:PageToken $PAGE_TOKEN "$PAGE_MINTER"

echo "PAGE_NFT = $PAGE_NFT"
npx hardhat verify --network rinkeby --contract contracts/CryptoPageMinterNFT.sol:PageMinterNFT $PAGE_NFT "$PAGE_MINTER" "$PAGE_TOKEN"

echo "PAGE_MINTER = $PAGE_MINTER"
npx hardhat verify --network rinkeby --contract contracts/CryptoPageMinter.sol:PageMinter $PAGE_MINTER "$PAGE_ADMIN" "$TRESHERY_ADDRESS"

#    TEST DATA ...
#    "PAGE_ADMIN":  "0x774b03E220CC42d122353BD87927078C93D373d3"
#    "PAGE_TOKEN":  "0xE4C1915903846977FD05EE22A3Fa031774d486f8"
#    "PAGE_NFT":    "0xf9D158B5583b5183570722818AF4C8C1B2F7255e"
#    "PAGE_MINTER": "0x774b03E220CC42d122353BD87927078C93D373d3"