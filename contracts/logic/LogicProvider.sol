pragma solidity ^0.6.6;

import "./ILogicProvider.sol";
/** 
	The BasicLogicProvider contract implements the ILogicProvider interface. 
	The contract itself 
*/
contract LogicProvider is ILogicProvider { 

	function executeLogic( uint256 _amount, bytes memory _data ) external override { // Does not compile without override

		uint256 amount = _amount;
		bytes memory data = _data;

	} 
}