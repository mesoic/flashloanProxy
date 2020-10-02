pragma solidity ^0.6.6;


/**
	LogicProvider interface. The FlashloanProxy contract will make a delagate_call
	to the executeLogic function. Several logic providers can be defined which use
	different routines for provisioning flashloaned assets. 
*/
interface ILogicProvider { 
	function executeLogic( address payable addressFlashloanProxy, bytes memory _data ) external payable; 
}
