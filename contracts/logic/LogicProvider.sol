pragma solidity ^0.6.6;

import "./ILogicProvider.sol";
import "../utils/Withdrawable.sol";

/** 
	The LogicProvider contract implements a minimum working example of the ILogicProvider 
	interface. The logic provider correctly recieves and returns funds to sender. Note that
	the contract is labeled as Withdrawable in case funds get stuck.
*/
contract LogicProvider is ILogicProvider, Withdrawable { 

	function executeLogic( 
		address payable addressFlashloanProxy,  
		bytes memory _data 
	) 
		external 
		payable 
		override // Does not compile without override
	{ 
		addressFlashloanProxy = msg.sender;

		bytes memory data = _data;

		addressFlashloanProxy.transfer( address(this).balance );
		
	}
}