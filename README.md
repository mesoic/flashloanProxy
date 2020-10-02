# flashloanProxy

This repository provisions a framework for deploying and testing smart contract development in the context of an Aave flashloan. The proxy contract handles the request and repayment of the flashloan. The proxy contract contains an address variable which points to another contract which contains specifies how flashloaned funds should be manipulated.

### Install nodejs (Linux)

Run install script (remote source). This method seems to work better than installing via distribution package managers

`curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash`

Check available versions and install node (and nvm)

`nvm ls-remote`

`nvm install node`

Check node and npm version after installation

`node -v`

`npm -v`

### Install base 

`npm install -g truffle`

`npm install -g ganache-cli`

If truffle instillation results in gyp errors, it might be necessary to install node-gyp. If node-gyp instillation is required, be sure to exit the shell after installing node-gyp. Then attempt to install truffle from a new shell. 

`npm install -g node-gyp`

### Install node version 12 (for ganache-cli) and node packages

`nvm install 12` 

`npm install`

### Set up your .env file (JSON format)

`{
	"local" :	{
		"api"		  :	INFURA_API_KEY,
		"secret"	:	DEPLOYER_ACCOUNT_PRIVATE_KEY
	}
}
`

### Deploying the contract to local ganache

Start ganache-cli. Ganache is configured to fork mainnet using a provided Infura API key. Note that this script requires node 12 to be installed.

`./scripts/utils/ganache-cli-fork-mainnet.sh`

Deploy the contract

`truffle migrate`

Run the javascript interface to test contract interation

`node ./scripts/app/test/FlashloanProxyTest.js` 

In case it is necessary to force recopmilation and redeployment

./scripts/utils/truffle-migrate-force-deploy.sh 

After deploying the conract, it is also possible to interact dynamically via truffle console. The following sequece of commands gets a handle to the contract, transfers 0.1 ETH to the contract, takes a flashloan for 10 ETH, and withdraws the funds back to the requseting account.

  `truffle console`

   `truffle(developmet)> let f = await FlashloanProxy.deployed()`
	
  `truffle(developmet)> let accounts = await web3.eth.getAccounts()`
	
  `truffle(developmet)> web3.eth.sendTransaction({from: accounts[0], to: f.address, value: 100000000000000000})`
  
  `truffle(developmet)> await f.flashloan("10000000000000000000", "0x00")`
  
  `truffle(developmet)> f.assetBalance("0x0000000000000000000000000000000000000000")`

  `truffle(developmet)> f.assetWithdraw("0x0000000000000000000000000000000000000000")`


