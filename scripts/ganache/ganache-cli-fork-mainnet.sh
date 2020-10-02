#!/bin/bash
SECRET=$(cat .env | jq -r ".local.secret")
API=$(cat .env | jq -r ".local.api")

# Source nvm and fork mainnet in ganache. Initialize account to 10ETH
source ~/.nvm/nvm.sh
nvm use 12 && ganache-cli --account="${SECRET},10000000000000000000" --fork https://mainnet.infura.io/v3/"${API}" -i 1