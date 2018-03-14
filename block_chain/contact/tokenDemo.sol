pragma solidity ^0.4.0;

//创建一个基础合约，有些操作只能是当前合约的创建者才能操作
contract owned{
    //声明一个用来接收合约创建者的状态变量
    address public owner;
    //构造函数，把当前交易的发送者（也就是合约的创建者）赋予owner变量
    function owned(){
        owner = msg.sender;
    }

    //声明一个修改器，用于有些方法只有合约的创建者才能操作
    modifier onlyOwner{
        if(msg.sender != owner){
            revert();
        }else{
            _;
        }
    }
    //把该合约的拥有者转给其他人
    function transferOwner(address newOwner) onlyOwner{
        owner = newOwner;
    }
}

contract tokenDemo3 is owned {
    string public name ;//代币名字
    string public symbol; //代币符号
    uint8 public decimals = 0; //代币小数位
    uint public totalSupply; //代币总量

    uint public sellPrice = 1 ether ; //设置代币的卖的价格等于一个以太币
    uint public buyPrice = 1 ether ;//设置代币的买的价格等于一个以太币

    //用一个映射类型的变量，来记录所有账户的代币的余额
    mapping(address => uint) public balanceOf;
    //用一个映射类型的变量，来记录被冻结的账户
    mapping(address=>bool) public frozenAccount;


    event e(string _str);
    //构造函数，初始化代币的变量和初始代币总量
    function tokenDemo3(uint initialSupply,string _name , string _symbol, uint8 _decimals,address centralMinter) payable{
        //手动指定代币的拥有者，如果不填，则默认为合约的部署者
        if(centralMinter !=0){
            owner = centralMinter;
        }

        balanceOf[owner] = initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = initialSupply;
    }

    //发行代币，向指定的目标账户添加代币
    function mintToken(address target,uint mintedAmount) onlyOwner{
        //判断目标账户是否存在
        if(target != 0){
            //设置目标账户相应的代币余额
            balanceOf[target] = mintedAmount;
            //增加总量
            totalSupply +=mintedAmount;
        }else{
            revert();
        }
    }
    //实现账户的冻结和解冻
    function freezeAccount(address target,bool _bool) onlyOwner{
        if(target != 0){
            frozenAccount[target] = _bool;
        }
    }
    //实现账户间，代币的转移
    function transfer(address _to, uint _value) {
        //检测交易的发起者的账户是不是被冻结了
        if(frozenAccount[msg.sender]){
            revert();
        }
        //检测交易发起者的账户的代币余额是否足够
        if(balanceOf[msg.sender] < _value){
            revert();
        }
        //检测溢出
        if((balanceOf[_to] + _value) <balanceOf[_to] ){
            revert();
        }

        //实现代币转移
        balanceOf[msg.sender] -=_value;
        balanceOf[_to] +=_value;
    }

    //设置代币的买卖价格
    function setPrice(uint newSellPrice,uint newBuyPrice) onlyOwner{
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    //实现代币的卖操作
    function sell(uint amount) returns(uint revenue){
        //检测交易的发起者的账户是不是被冻结了
        if(frozenAccount[msg.sender]){
            revert();
        }
        //检测交易发起者的账户的代币余额是否足够
        if(balanceOf[msg.sender] < amount){
            revert();
        }
        //把相应数量的代币给合约的拥有者
        balanceOf[owner] +=amount ;
        //卖家的账户减去相应的余额
        balanceOf[msg.sender] -=amount;
        //计算对应的以太币的价值
        revenue = amount * sellPrice;
        //向卖家的账户发送对应数量的以太币
        if(msg.sender.send(revenue)){
            return revenue;
        }else{
            //如果以太币发送失败，则终止程序，并且恢复状态变量
            revert();
        }
    }

    //实现买操作
    function buy() payable returns(uint amount) {
        //检测买家是不是大于0
        if(buyPrice <= 0){
            //如果不是，则终止
            revert();
        }
        //根据用户发送的以太币的数量和代币的买价，计算出代币的数量
        amount = msg.value / buyPrice;
        //检测合约的拥有者是否有足够多的代币
        if(balanceOf[owner] < amount){
            revert();
        }
        //向合约的拥有者转移以太币
        if(!owner.send(msg.value)){
            //如果失败，则终止
            revert();
        }
        //从拥有者的账户上减去相应的代币
        balanceOf[owner] -=amount ;
        //买家的账户增加相应的余额
        balanceOf[msg.sender] +=amount;

        return amount;
    }
}