pragma solidity ^0.6.6;

interface ILogicProvider { 
	function executeLogic( uint256 _amount, bytes memory _data ) external; 
}
