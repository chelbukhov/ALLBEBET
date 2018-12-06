pragma solidity 0.4.25;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address _who) external view returns (uint256);

  function allowance(address _owner, address _spender) external view returns (uint256);

  function transfer(address _to, uint256 _value) external returns (bool);

  function approve(address _spender, uint256 _value) external returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b,"Math error");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0,"Math error"); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a,"Math error");
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a,"Math error");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0,"Math error");
        return a % b;
    }
}


/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal balances_;

    mapping (address => mapping (address => uint256)) private allowed_;

    uint256 private totalSupply_;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances_[_owner];
    }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
    function allowance(
        address _owner,
        address _spender
    )
      public
      view
      returns (uint256)
    {
        return allowed_[_owner][_spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances_[msg.sender],"Invalid value");
        require(_to != address(0),"Invalid address");

        balances_[msg.sender] = balances_[msg.sender].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed_[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
      public
      returns (bool)
    {
        require(_value <= balances_[_from],"Value is more than balance");
        require(_value <= allowed_[_from][msg.sender],"Value is more than alloved");
        require(_to != address(0),"Invalid address");

        balances_[_from] = balances_[_from].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
      public
      returns (bool)
    {
        allowed_[msg.sender][_spender] = (allowed_[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
      public
      returns (bool)
    {
        uint256 oldValue = allowed_[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed_[msg.sender][_spender] = 0;
        } else {
            allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param _account The account that will receive the created tokens.
    * @param _amount The amount that will be created.
    */
    function _mint(address _account, uint256 _amount) internal {
        require(_account != address(0),"Invalid address");
        totalSupply_ = totalSupply_.add(_amount);
        balances_[_account] = balances_[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }


}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    function safeTransfer(
        IERC20 _token,
        address _to,
        uint256 _value
    )
      internal
    {
        require(_token.transfer(_to, _value),"Transfer error");
    }

    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    )
      internal
    {
        require(_token.transferFrom(_from, _to, _value),"Tranfer error");
    }

    function safeApprove(
        IERC20 _token,
        address _spender,
        uint256 _value
    )
      internal
    {
        require(_token.approve(_spender, _value),"Approve error");
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable {
    event Paused();
    event Unpaused();

    bool public paused = false;


    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused,"Contract is paused, sorry");
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused, "Contract is running now");
        _;
    }

}


/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is ERC20, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

/**
 * @title Contract ALLBEBET token
 * @dev ERC20 compatible token contract
 */
contract ALLBEBETToken is ERC20Pausable {
    string public constant name = "ALLBEBET";
    string public constant symbol = "ALB";
    uint32 public constant decimals = 18;
    uint256 public INITIAL_SUPPLY = 700000000 * 1 ether; // 700 000 000
    address public CrowdsaleAddress;
    bool public ICOover;


    constructor(address _CrowdsaleAddress) public {
    
        CrowdsaleAddress = _CrowdsaleAddress;
        _mint(_CrowdsaleAddress, INITIAL_SUPPLY);
    }


    modifier onlyOwner() {
        require(msg.sender == CrowdsaleAddress,"Only CrowdSale contract can run this");
        _;
    }
    
    modifier validDestination( address to ) {
        require(to != address(0),"Empty address");
        require(to != address(this),"ALLBEBET Token address");
        _;
    }
    
    modifier isICOover {
        if (msg.sender != CrowdsaleAddress){
            require(ICOover == true,"Transfer of tokens is prohibited until the end of the ICO");
        }
        _;
    }
    
    /**
     * @dev Override for testing address destination
     */
    function transfer(address _to, uint256 _value) public validDestination(_to) isICOover returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Override for testing address destination
     */
    function transferFrom(address _from, address _to, uint256 _value) 
    public validDestination(_to) isICOover returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

    
  /**
   * @dev Function to mint tokens
   * can run only from crowdsale contract
   * @param to The address that will receive the minted tokens.
   * @param _value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
    function mint(address to, uint256 _value) public onlyOwner {
        _mint(to, _value);
    }



    /**
    * @dev function set ICOOver bool to true
    * can run only from crowdsale contract
    */
    function setICOover() public onlyOwner {
        ICOover = true;
    }


    /**
     * @dev called from crowdsale contract to pause, triggers stopped state
     * can run only from crowdsale contract
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused();
    }

    /**
     * @dev called from crowdsale contract to unpause, returns to normal state
     * can run only from crowdsale contract
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpaused();
    }
 
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public manager;
    address private candidate;

    constructor() public {
        owner = msg.sender;
        manager = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Access denied");
        _;
    }

    modifier restricted() {
        require(msg.sender == owner || msg.sender == manager,"Access denied");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0),"Invalid address");
        candidate = _newOwner;
    }

    function setManager(address _newManager) public onlyOwner {
        require(_newManager != address(0),"Invalid address");
        manager = _newManager;
    }


    function confirmOwnership() public {
        require(candidate == msg.sender,"Only from candidate");
        owner = candidate;
        delete candidate;
    }

}



/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale
 */
contract Crowdsale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ALLBEBETToken;

    event LogStateSwitch(State newState);
    event LogRefunding(address indexed to, uint256 amount);
    mapping(address => uint) public crowdsaleBalances;


//!!! softCap for testing !!!
    uint256 public softCap = 70 * 1 ether;
    address internal myAddress = address(this);
    ALLBEBETToken public token = new ALLBEBETToken(myAddress);
    uint64 public crowdSaleStartTime;       
    uint64 public crowdSaleEndTime = 1611100800;       // 20.01.2021 0:00:00
    uint256 public minValue = 0.1 ether;

      
    // How many token units a buyer gets per wei.
    uint256 public rate;
    bool public originalRate;

    // Amount of wei raised
    uint256 public weiRaised;
    
    event ChangeRate(
        uint256 newRate
    );

    event LogWithdraw(
        address indexed from, 
        address indexed to, 
        uint256 amount
    );

    event LogTokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    // Create state of contract
    enum State { 
        Init,    
        CrowdSale,
        Refunding,
        WorkTime
    }

    State public currentState = State.Init;

    modifier onlyInState(State state){ 
        require(state==currentState, "Wrong stage"); 
        _; 
    }


    constructor() public {

        rate = 1000;
        originalRate = true;
        setState(State.CrowdSale);
        crowdSaleStartTime = uint64(now);
    }


    // -----------------------------------------
    // Crowdsale external interface
    // -----------------------------------------


    /**
     * @dev public function finishing crowdsale if enddate is coming or softcap is passed
     */
    function finishCrowdSale() public onlyInState(State.CrowdSale) {
        require(now >= crowdSaleEndTime || myAddress.balance >= softCap, "Too early");
        if(myAddress.balance >= softCap) {
        setState(State.WorkTime);
        token.setICOover();
        crowdSaleEndTime = uint64(now);
        } else {
        setState(State.Refunding);
        }
    }


    /**
    * @dev fallback function
    */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
    * @dev token purchase
    * @param _beneficiary Address performing the token purchase
    */
    function buyTokens(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);

        crowdsaleBalances[_beneficiary] = crowdsaleBalances[_beneficiary].add(weiAmount);
        
        emit LogTokensPurchased(
            msg.sender,
            _beneficiary,
            weiAmount,
            tokens
        );

    }


    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pauseCrowdsale() public onlyOwner {
        token.pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpauseCrowdsale() public onlyOwner {
        token.unpause();
    }

    /**
     * @dev called by the owner to set new rate
     */
    function setRate(uint256 _newRate) public onlyOwner {
        rate = _newRate;
        originalRate = false;
        emit ChangeRate(_newRate);
    }

    /**
     * @dev this function updates tokens rates until the rate has been manually changed
     * @return rates of tokens
    */
    function calcRate() public returns (uint256) {
        if (originalRate) {
            // 1547942400   20.01.2019 - set rate 769 tokens for 1 ETH
            // 1579478400   20.01.2020 - set rate 625 tokens for 1 ETH
            if (now >= 1547942400 && now < 1579478400) {
                rate = 769;
            }
            if (now >= 1579478400) {
                rate = 625;
            }
        }
        return rate;
    }
    
    /**
     * @dev called by the owner to set new minValue
     */
    function setMinValue(uint256 _newValue) public onlyOwner {
        minValue = _newValue;
    }

    /**
     * @dev Function transfer token to new investors
     * Access restricted 
     */ 
    function transferTokens(address _newInvestor, uint256 _tokenAmount) public restricted {
        _deliverTokens(_newInvestor, _tokenAmount);
    }

    /**
     * @dev function returns funds to investors in case of project failure.
     */
    function refund() public payable{
        require(currentState == State.Refunding, "Only for Refunding stage.");
        // refund ether to investors
        uint value = crowdsaleBalances[msg.sender]; 
        crowdsaleBalances[msg.sender] = 0; 
        msg.sender.transfer(value);
        emit LogRefunding(msg.sender, value);
    }

    /**
     * @dev function of withdrawal of funds for the development of the project if successful
     */
    function withdrawFunds (address _to, uint256 _value) public onlyOwner {
        require(currentState == State.WorkTime, "CrowdSale is not finished yet. Access denied.");
        require (myAddress.balance >= _value,"Value is more than balance");
        require(_to != address(0),"Invalid address");
        _to.transfer(_value);
        emit LogWithdraw(msg.sender, _to, _value);
    }

    
    // -----------------------------------------
    // Internal interface 
    // -----------------------------------------

    function setState(State _state) internal {
        currentState = _state;
        emit LogStateSwitch(_state);
    }

    /**
     * @dev Validation of an incoming purchase. internal function.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view{
        require(_beneficiary != address(0),"Invalid address");
        require(_weiAmount >= minValue,"Your amount is less then minValue");
        require(currentState != State.Refunding, "Only for CrowdSale and Work stage.");
    }

    /**
     * @dev internal function
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.safeTransfer(_beneficiary, _tokenAmount);
    }


    /**
    * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
    * @param _beneficiary Address receiving the tokens
    * @param _tokenAmount Number of tokens to be purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
        
    }


    /**
    * @dev this function is ether converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount) internal returns (uint256) {
        return _weiAmount.mul(calcRate());
    }

}