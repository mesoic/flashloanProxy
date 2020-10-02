pragma solidity ^0.6.6;

/**
	A utility contract with aims to extend the functioality of solidity-bytes-utils/BytesLib.sol
	This library contains methods to encode common data types as bytes arrays for message passing
*/
library BytesEncode {

	/**
		Encode address as bytes array
	*/
	function addressToBytes( address a ) public pure returns ( bytes memory b ){
	    assembly {
	        let m := mload(0x40)
	        a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
	        mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
	        mstore(0x40, add(m, 52))
	        b := m
	   }
	}

	/**
		Encode uint256 as bytes array
	*/	
	function toBytes( uint256 x ) public returns ( bytes memory b ) {
	    b = new bytes(32);
	    assembly { mstore(add(b, 32), x) }
	}
}