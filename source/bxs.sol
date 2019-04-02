pragma solidity ^0.5.2;

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public token_balance;  
    mapping (address => uint256)  public eth_balance;   
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of
the contract
     */
    constructor (
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public payable {
// Update total supply with the decimal amount
totalSupply = initialSupply * 10 ** uint256(decimals);

// Give the creator all initial tokens
token_balance[msg.sender] = totalSupply;

// initialize Ether balance of Fleet Coin contract
eth_balance[msg.sender] = msg.value;
// Set the name for display purposes

name = tokenName;
// Set the symbol for display purposes
symbol = tokenSymbol;
}

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer_token(address _from, address _to, uint _value)
internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0) );
        // Check if the sender has enough
        require(token_balance[_from] >= _value);
        // Check for overflows
        require(token_balance[_to] + _value > token_balance[_to]);
        // Save this for an assertion in the future
        uint previousBalances = token_balance[_from] + token_balance[_to];
        // Subtract from the sender
        token_balance[_from] -= _value;
        // Add the same to the recipient
        token_balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(token_balance[_from] + token_balance[_to] ==
previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer_token(address _to, uint256 _value) public {
        _transfer_token(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer_token_from(address _from, address _to, uint256
_value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer_token(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your
behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your
behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved
contract
     */

    

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(token_balance[msg.sender] >= _value);   // Check if the sender has enough
        token_balance[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of
`_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool
success) {
        require(token_balance[_from] >= _value);                // Check if  the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        token_balance[_from] -= _value;                         // Subtractvfrom the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract blackswan is owned, TokenERC20 {

        /* This generates a public event on the blockchain that will notify clients */
        event FrozenFunds(address target, bool frozen);

        uint master_exchange_rate;
        string[4] greetings;
        
    /* Initializes contract with initial supply tokens to the creator of
the contract */
    constructor (
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public payable  {

        master_exchange_rate = 1000;                        // 1 ETH = 1000 FC

        greetings[0] = "My name is Omar Metwally.";
        greetings[1] = "I am the creator of this contract.";
        greetings[2] = "To the future machine with the computational power to unlock today's encrypted secrets";
        greetings[3] = "To the future human with the spiritual power to unlock all secrets.";
        
}    
    
        struct Record {
            address author;
            string desc;
            uint start_index;
            uint end_index;
        }
    
        mapping(address => bytes32[]) chunks;
        mapping (address => bool) frozenAccount;
        mapping (address => Record[]) records;

    function new_record( string memory _desc, uint _start_index, uint _end_index) public returns (bool) {
        
        records[msg.sender].push( Record( { author: msg.sender, desc: _desc, start_index: _start_index,
            end_index: _end_index}) );
        return true;
    }
    
    function new_chunk(uint _index, bytes32 _data ) public returns (bool) {
        
        require (_index == chunks[msg.sender].length );
        
        chunks[msg.sender].push( _data ); 
        
        return true;    
    }
    
    function get_num_records(address _author) public view returns (uint) {
        return records[ _author ].length;
    }
    
    function get_num_chunks(address _owner) public view returns (uint) {

        return chunks[_owner].length;
    }
    
    function update_record( uint _index, string memory _desc, uint _start_index, uint _end_index) public returns (bool) {
        require( _index < records[msg.sender].length );
        
        records[msg.sender][_index].desc = _desc; 
        records[msg.sender][_index].start_index = _start_index;
        records[msg.sender][_index].end_index = _end_index;
        
        return true;
    }    
    
    function update_chunk(uint _index, bytes32 _data )  public returns (bool) {
        require( _index < chunks[msg.sender].length, "Invalid index." );
        chunks[msg.sender][_index] = _data;
        return true;
    }
    
    function get_chunk(address _owner, uint _index) public view returns( bytes32 _data ) {

        require( _index < chunks[_owner].length, "Invalid index." );
        bytes32 ch = chunks[_owner][_index];
        
        _data = ch;
    }
    
    function get_record(address _author, uint _index) public view returns( string memory _desc, 
        uint _start_index, uint _end_index ) {
            
            _desc = records[_author][_index].desc;
            _start_index = records[_author][_index].start_index;
            _end_index = records[_author][_index].end_index;
        }

    function get_eth_balance(address eth_addr) public view returns
(uint balance) {
        return eth_balance[eth_addr];
    }

    function get_token_balance(address eth_addr) public view returns
(uint balance) {
        return token_balance[eth_addr];
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != address(0x0) );                               // Prevent transfer to 0x0 address. Use burn() instead
        require (token_balance[_from] >= _value);               // Check if the sender has enough
        require (token_balance[_to] + _value > token_balance[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        token_balance[_from] -= _value;                         // Subtract from the sender
        token_balance[_to] += _value;                           // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value * master_exchange_rate;  // buyPrice;
        // calculates the amount
        _transfer(owner, msg.sender, amount);
  // makes the transfers
        eth_balance[msg.sender] += msg.value;
 // update eth_balance
        token_balance[msg.sender] += amount;  // update token_balance
    }

    /// @notice Sell `amount` tokens to contract
    /// @param amount amount of tokens to be sold
    function sell(uint256 amount) public {
        require(eth_balance[address(this)] >= (amount / master_exchange_rate) );      // checks if the contract has enough ether to buy
        _transfer(msg.sender, owner, amount);              // makes the transfers
        msg.sender.transfer(amount / master_exchange_rate);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
        token_balance[msg.sender] -= amount;   // update token_balance
        eth_balance[msg.sender] -= (amount/master_exchange_rate) ;   // update eth_balance
    }

    function set_master_exchange_rate(uint new_rate) public  returns (uint
exchange_rate) {
        require(msg.sender == owner);
        master_exchange_rate = new_rate;
        return master_exchange_rate;
    }
    function greet_omar(uint _i) public view returns (string memory greeting) {
        require(_i>=0);
        require(_i<greetings.length);
        return greetings[_i];
    }
}




