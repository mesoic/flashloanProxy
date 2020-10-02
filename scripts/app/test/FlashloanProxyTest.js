const fs  = require('fs');
const Web3 = require('web3');
const ethers = require('ethers');

/*
	Connect to web3 and configure account
*/ 
env = JSON.parse(fs.readFileSync(".env", 'utf8'));
const provider = new Web3.providers.HttpProvider("http://localhost:8545");
const web3 = new Web3(provider);
web3.eth.net.isListening()
	  	.then(() => console.log(''))
		.catch(e => console.log('web3 connection error'));

// const keystore = "Contents of keystore file";
// const account = web3.eth.accounts.decrypt(keystore, 'PASSWORD');
const account = web3.eth.accounts.privateKeyToAccount(env.local.secret);
console.log("\nUsing Account: " + account.address)
/*
	In order to interact with the contract, we need two things 
	|	ABI (created by compiler and located in builc/contracts) 
	|	Contract address
*/
appConfig = JSON.parse(fs.readFileSync("./scripts/app/config/app.env", 'utf8'));
const FlashloanProxyABI = JSON.parse(fs.readFileSync(appConfig.flashloanProxy.abi, 'utf8'));
const FlashloanProxy 	= new web3.eth.Contract(FlashloanProxyABI.abi, appConfig.flashloanProxy.address);
console.log("Using Proxy: " + appConfig.flashloanProxy.address)

// Gas settings
// FlashloanProxy.options.gasPrice = '20000000000000'; // default gas price in wei
// FlashloanProxy.options.gas = 500000; 				// provide as fallback always 5M gas

/*
	Unit test the functionality of the proxy from javascript 
*/
const testLogicProvider = async () => {

	// Test setting and getting logic provider contract address
	var result = await FlashloanProxy.methods.getLogicProvider().call()
	console.log("Logic Provider: " + result)

	var addressLogicProvider = appConfig.logicProvider.address
	var hash   = await FlashloanProxy.methods.setLogicProvider(addressLogicProvider).send({from: account.address})
	var result = await FlashloanProxy.methods.getLogicProvider().call()
	console.log("Logic Provider: " + result)

	var addressLogicProvider = "0x0000000000000000000000000000000000000000"
	var hash   = await FlashloanProxy.methods.setLogicProvider(addressLogicProvider).send({from: account.address})
	var result = await FlashloanProxy.methods.getLogicProvider().call()
	console.log("Logic Provider: " + result)

}
// testLogicProvider();

const testTransferEther = async() => {
	// Test tranfer and withdraw of eth out of contract (verifying balace)
	var assetAddress  = "0x0000000000000000000000000000000000000000" 
	var depositAmount 	= web3.utils.toWei("0.10");
	var result 	= await FlashloanProxy.methods.assetBalance(assetAddress).call()
	console.log("Balance: " + result)

	var hash 	= await web3.eth.sendTransaction({from: account.address, to: appConfig.flashloanProxy.address, value: depositAmount})
	var result  = await FlashloanProxy.methods.assetBalance(assetAddress).call()
	console.log("Balance: " + result)

	var hash 	= await FlashloanProxy.methods.assetWithdraw(assetAddress).send({from: account.address})
	var result 	= await FlashloanProxy.methods.assetBalance(assetAddress).call()
	console.log("Balance: " + result)
}
// testTransferEther();

const testFlashloan = async () => {

	// Test flashloan functionality (note we must send in a bit of ETH to pay the fee)
	var depositAmount 	= web3.utils.toWei("1.00");
	var flashloanAmount = web3.utils.toWei("10.0");

	var addressLogicProvider = appConfig.logicProvider.address
	var hash   = await FlashloanProxy.methods.setLogicProvider(addressLogicProvider).send({from: account.address})
	var result = await FlashloanProxy.methods.getLogicProvider().call()
	console.log("Logic Provider: " + result)

	var assetAddress  = "0x0000000000000000000000000000000000000000" 
	var hash 	= await web3.eth.sendTransaction({from: account.address, to: appConfig.flashloanProxy.address, value: depositAmount})
	var result 	= await FlashloanProxy.methods.assetBalance(assetAddress).call()
	console.log("Balance (flashloan): " + result)
	
	// 0.0189013 ETH @ 102gwei (185307 gas)
 	var result 	= await FlashloanProxy.methods.executeFlashloan( flashloanAmount, "0x00" ).send({from: account.address, gas: 300000})
	var result 	= await FlashloanProxy.methods.assetBalance(assetAddress).call()
	console.log("Balance (flashloan): " + result)
	
	var hash 	= await FlashloanProxy.methods.assetWithdraw(assetAddress).send({from: account.address})
	var result 	= await FlashloanProxy.methods.assetBalance(assetAddress).call()
	console.log("Balance (flashloan): " + result)

	var addressLogicProvider = "0x0000000000000000000000000000000000000000"
	var hash   = await FlashloanProxy.methods.setLogicProvider(addressLogicProvider).send({from: account.address})
	var result = await FlashloanProxy.methods.getLogicProvider().call()
	console.log("Logic Provider: " + result)
}
testFlashloan();
