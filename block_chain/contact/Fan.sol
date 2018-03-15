// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
// 此token为UnlimitedIP未来版权发行币的源码，我将它中文翻译了一下，顺便改了下token名字，
// 参考地址：https://github.com/linkentertainments/UnlimitedIP-Token

/**
 * 需要注意，该token是将所有兑换到的eth锁定在一个地址上
 */
pragma solidity ^0.4.10;

contract Token {
    /// token的总发行量
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

    /// @notice _owner允许_spender最多交易多少token，保存映射：allowed[_owner][_spender];
    /// @param _owner 拥有token的账户
    /// @param _spender 被交易用户的账户
    /// @return 最多允许交易多少token
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

//迁移，将当前代币移到eos平台上
contract IMigrationContract {
    function migrate(address addr, uint256 fb) returns (bool success);
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

    //allowed[_from][msg.sender]：其中_from允许_to最多交易_value个token
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

    //查询余额
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    //设置msg.sender允许_spender转多少token
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    //查询_owner最多允许spender转多少token
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;  //存储每个账户余额
    mapping (address => mapping (address => uint256)) allowed; //发送账户允许转的上线，比如：allowed[_from][msg.sender] msg.sender账户最多允许从_from账户交易的token的数量
}

contract FBToken is StandardToken, SafeMath {

    // 元数据
    string  public constant name = "FB Token";
    string  public constant symbol = "FB";
    uint256 public constant decimals = 18; //小数位数，如此可以计算出以最小单位的token的值是多少
    string  public version = "1.0";

    // 合约
    address public ethFundDeposit;          // FB存储ETH的地址
    address public newContractAddr;         // FBtoken 新更新的合约地址

    // crowdsale parameters（很高大上的名字对吧？其实这crowdsale就叫做ICO，此处用来设置参数）
    bool    public isFunding;                // 是否开始募集，开始时候，设为true
    uint256 public fundingStartBlock;        // 开始募集的块的高度
    uint256 public fundingStopBlock;         // 截止募集的块的高度

    uint256 public currentSupply;           // 当前供应的token总数（由指定账户从总发行的地址中取出放在此处）
    uint256 public tokenRaised = 0;         // 当前私募用eth兑换了的token总数
    uint256 public tokenMigrated = 0;       // 新迁移的token的额度，用于更新合约后，将token转移在这新的合约中
    uint256 public tokenExchangeRate = 1000;             // 1个eth可以兑换1000个FB，测试使用

    // 事件
    event IssueToken(address indexed _to, uint256 _value);      // issue token for public sale;
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _to, uint256 _value);  //总的
    event Burn(address indexed from, uint256 _value);  //销毁

    // 所有涉及到token额度的，都是以最小单位计算
    //@notice _value也就是指定数目的token最小单位有多大，比如，以太坊最小单位有18位 1eth = 1*10**18wei。
    //@param 以最小单位的tokeny
    function formatDecimals(uint256 _value) internal returns (uint256 ) {
        return _value * 10 ** decimals;  //**表示次方
    }

    // 结构体
    function FBToken()
    {
        //发行token的起始地址,
        // 兑换token后的eth也存在此处，注意eth和token的概念
        ethFundDeposit = 0xBbf91Cf4cf582600BEcBb63d5BdB8D969F21779C;

        isFunding = false;                           //crowdsale（ICO）开始前更改
        fundingStartBlock = 0;
        fundingStopBlock = 0;

        currentSupply = formatDecimals(0);  //当前发行的
        totalSupply = formatDecimals(3000000000);  //总共发行的token,用最小单位
        require(currentSupply <= totalSupply);
        balances[ethFundDeposit] = totalSupply-currentSupply;
    }

    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }

    /// @dev 设置token的交易率
    function setTokenExchangeRate(uint256 _tokenExchangeRate) isOwner external {
        require(_tokenExchangeRate > 0);
        require(_tokenExchangeRate != tokenExchangeRate);
        tokenExchangeRate = _tokenExchangeRate;
    }

    /// @dev 增加token的总的供应量，
    function increaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        require (value + currentSupply <= totalSupply);
        require (balances[msg.sender] >= value && value>0);
        balances[msg.sender] -= value;
        currentSupply = safeAdd(currentSupply, value);
        IncreaseSupply(value);
    }

    /// @dev 减少token的供应，tokenRaised为用eth兑换的token的总量
    function decreaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        require (value + tokenRaised <= currentSupply);
        currentSupply = safeSubtract(currentSupply, value);
        balances[msg.sender] += value;
        DecreaseSupply(value);
    }

    /// @dev 启动私募
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {
        require(!isFunding);
        require(_fundingStartBlock < _fundingStopBlock);
        require(block.number < _fundingStartBlock) ;
        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }

    /// @dev 关闭私募机制
    function stopFunding() isOwner external {
        require(isFunding);
        isFunding = false;
    }

    /// @dev 设置一个新的合约用来接收token (用于更新合约)
    function setMigrateContract(address _newContractAddr) isOwner external {
        require(_newContractAddr != newContractAddr);
        newContractAddr = _newContractAddr;
    }

    /// @dev 设置一个新的合约拥有者
    function changeOwner(address _newFundDeposit) isOwner() external {
        require(_newFundDeposit != address(0x0));
        ethFundDeposit = _newFundDeposit;
    }

    /// 把token发到新的合约上
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

    /// @dev 将合约地址的以太坊币转移到token开发团队指定的地址
    function transferETH() isOwner external {
        require(this.balance > 0);
        require(ethFundDeposit.send(this.balance)); //转移eth到ethFundDeposit
    }

    //指定账户销毁token
    function burn(uint256 _value) isOwner returns (bool success){
        uint256 value = formatDecimals(_value);
        require(balances[msg.sender] >= value && value>0);
        balances[msg.sender] -= value;
        totalSupply -= value;
        Burn(msg.sender,value);
        return true;
    }

    /// 用eth购买token
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