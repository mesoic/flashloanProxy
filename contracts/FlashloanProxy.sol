pragma solidity ^0.6.6;

/**
    This contract is FlashLoanRecieverBase, which inherits from Withdrawable.sol 
    Withdrawable.sol includes the ERC20 token interface "IERC20".
*/
import "./aave/FlashLoanReceiverBase.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/ILendingPool.sol";

/**
    ArbitrageProxy sets up an interface for performing arbitrage using flashloans.
    The proxy is reaponsible for initating and finalzing a flashloan. ArbitrageProxy
    allows the owner to assign a LogicProvider (as a contract address) which will be 
    called with (bytes memory data) inside of executeOperation.
*/
import "./logic/ILogicProvider.sol";

/**
    Expose the function signature of the logic provider so the compiler can figure out 
    the function signature. This will allow us to delegate call the cotract
*/

contract FlashloanProxy is FlashLoanReceiverBase {

    /**
        Initialize address of logicProvider to 0x00
    */
    address logicProviderAddress = 0x0000000000000000000000000000000000000000;

    /** 
        Constructor inherits FlashloanRecieverBase and assigns pointer to a logic contract.
        This allows us to introdude upgradable behaviour to the logic contract. 
    */ 
    constructor(address _addressProviderAddress) FlashLoanReceiverBase(_addressProviderAddress) public {}


    function setLogicProvider( address _logicProviderAddress ) public onlyOwner { 
        logicProviderAddress = _logicProviderAddress;
    }    

    function getLogicProvider() public view returns ( address ) { 
        return logicProviderAddress; 
    }

    /**
        This function is called after your contract has received the flash loaned amount. 
        Note that it must have exactly this signature.
    */
    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata data
    )
        external
        override
    {
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance, was the flashLoan successful?");

        /**
            Call logicProvider. The proxy architecture separates the logic portion of the arbitrage
            operation from the flashloan execution (which is always the same).
        */

        ILogicProvider LogicProvider = ILogicProvider( logicProviderAddress );
        LogicProvider.executeLogic{ value: _amount }( address(this), data );

        uint totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    /**
        Flash loan amount of "_asset" in wei (1 = 1000000000000000000)
    */
    function executeFlashloan(
        uint256 _amount,
        bytes memory _data
    ) 
        public
        onlyOwner 
    {

        /**
            Arbitrage will always be perfoemed againt Ethereum 
        */
        address asset = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

        /**
            Store flashloan amount and data payload for logicProvider (pass-through)
        */
        uint256 amount = _amount;
        bytes memory data = _data;

        /**
            Initiate the flashloan
        */
        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(address(this), asset, amount, data);
    }
}