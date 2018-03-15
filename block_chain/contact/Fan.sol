// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity ^0.4.10;

contract Token {
    /// 所有的token种类
    uint256 public totalSupply;

    /// @notice 查询余额
    /// @param _owner 该地址对应的余额
    /// @return 返回余额
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice 从msg.sender发送token给_to
    /// @param token接受人
    /// @param _value 要转移的token数量
    /// @return 返回交易成功或者失败
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice 从_from发送token给_to
    /// @param _from 发送者
    /// @param _to 接收者
    /// @param _value 发送的token数量
    /// @return 是否成功
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice 设置帐户允许支付的最大金额
    /// @param _spender 待批准交易的账户
    /// @param _value 授权交易的token总数
    /// @return 是否成功
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner 拥有token的账户
    /// @param _spender 被交易用户的账户
    /// @return 最多允许交易多少token
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

//迁移，貌似是要将当前代币移到uip上
contract IMigrationContract {
    function migrate(address addr, uint256 uip) returns (bool success);
}

contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }
}

/*  ERC 20 token */
contract StandardToken is Token {

    //msg.sender发送token给_to
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;  //存储每个账户余额
    mapping (address => mapping (address => uint256)) allowed; //发送账户允许转的上线，比如：allowed[_from][msg.sender] msg.sender账户最多允许从_from账户交易的token的数量
}

contract UnlimitedIPToken is StandardToken, SafeMath {

    // metadata
    string  public constant name = "UnlimitedIP Token";
    string  public constant symbol = "UIP";
    uint256 public constant decimals = 18;
    string  public version = "1.0";

    // contracts
    address public ethFundDeposit;          // deposit address for ETH for UnlimitedIP Team.
    address public newContractAddr;         // the new contract for UnlimitedIP token updates;

    // crowdsale parameters
    bool    public isFunding;                // switched to true in operational state
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;

    uint256 public currentSupply;           // current supply tokens for sell
    uint256 public tokenRaised = 0;         // the number of total sold token
    uint256 public tokenMigrated = 0;     // the number of total transferted token
    uint256 public tokenExchangeRate = 1000;             // 1000 UIP tokens per 1 ETH

    // events
    event IssueToken(address indexed _to, uint256 _value);      // issue token for public sale;
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _to, uint256 _value);
    event Burn(address indexed from, uint256 _value);
    // format decimals.
    function formatDecimals(uint256 _value) internal returns (uint256 ) {
        return _value * 10 ** decimals;
    }

    // constructor
    function UnlimitedIPToken()
    {
        ethFundDeposit = 0xBbf91Cf4cf582600BEcBb63d5BdB8D969F21779C;

        isFunding = false;                           //controls pre through crowdsale state
        fundingStartBlock = 0;
        fundingStopBlock = 0;

        currentSupply = formatDecimals(0);
        totalSupply = formatDecimals(3000000000);
        require(currentSupply <= totalSupply);
        balances[ethFundDeposit] = totalSupply-currentSupply;
    }

    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }

    /// @dev set the token's tokenExchangeRate,
    function setTokenExchangeRate(uint256 _tokenExchangeRate) isOwner external {
        require(_tokenExchangeRate > 0);
        require(_tokenExchangeRate != tokenExchangeRate);
        tokenExchangeRate = _tokenExchangeRate;
    }

    /// @dev increase the token's supply
    function increaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        require (value + currentSupply <= totalSupply);
        require (balances[msg.sender] >= value && value>0);
        balances[msg.sender] -= value;
        currentSupply = safeAdd(currentSupply, value);
        IncreaseSupply(value);
    }

    /// @dev decrease the token's supply
    function decreaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        require (value + tokenRaised <= currentSupply);
        currentSupply = safeSubtract(currentSupply, value);
        balances[msg.sender] += value;
        DecreaseSupply(value);
    }

    /// @dev turn on the funding state
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {
        require(!isFunding);
        require(_fundingStartBlock < _fundingStopBlock);
        require(block.number < _fundingStartBlock) ;
        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }

    /// @dev turn off the funding state
    function stopFunding() isOwner external {
        require(isFunding);
        isFunding = false;
    }

    /// @dev set a new contract for recieve the tokens (for update contract)
    function setMigrateContract(address _newContractAddr) isOwner external {
        require(_newContractAddr != newContractAddr);
        newContractAddr = _newContractAddr;
    }

    /// @dev set a new owner.
    function changeOwner(address _newFundDeposit) isOwner() external {
        require(_newFundDeposit != address(0x0));
        ethFundDeposit = _newFundDeposit;
    }

    /// sends the tokens to new contract
    function migrate() external {
        require(!isFunding);
        require(newContractAddr != address(0x0));

        uint256 tokens = balances[msg.sender];
        require (tokens > 0);

        balances[msg.sender] = 0;
        tokenMigrated = safeAdd(tokenMigrated, tokens);

        IMigrationContract newContract = IMigrationContract(newContractAddr);
        require(newContract.migrate(msg.sender, tokens));

        Migrate(msg.sender, tokens);               // log it
    }

    /// @dev withdraw ETH from contract to UnlimitedIP team address
    function transferETH() isOwner external {
        require(this.balance > 0);
        require(ethFundDeposit.send(this.balance));
    }

    function burn(uint256 _value) isOwner returns (bool success){
        uint256 value = formatDecimals(_value);
        require(balances[msg.sender] >= value && value>0);
        balances[msg.sender] -= value;
        totalSupply -= value;
        Burn(msg.sender,value);
        return true;
    }

    /// buys the tokens
    function () payable {
        require (isFunding);
        require(msg.value > 0);

        require(block.number >= fundingStartBlock);
        require(block.number <= fundingStopBlock);

        uint256 tokens = safeMult(msg.value, tokenExchangeRate);
        require(tokens + tokenRaised <= currentSupply);

        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[msg.sender] += tokens;

        IssueToken(msg.sender, tokens);  // logs token issued
    }
}