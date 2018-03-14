pragma solidity ^0.4.21;  //编译器版本要大于0.4.21，但不能高于0.5

contract Coin {
    /**
     * 该行声明一个可公开访问的地址类型的状态变量
     * 1.address：是一个不允许任何运算的160位的值，
     *   可以用来存储智能合约地址或者外部用户的地址
     * 2.public 以允许别的智能合约来访问
     *   只有这个关键词可以让外部合约访问本合约
     * 3.public 会将minter自动生成类似这样的一个函数：
     * function minter() returns (address) { return minter; }
     */
    address public minter;

    //把address映射为无符号整型
    //public 会将balances自动生成类似这样一个函数：
    //function balances(address _account) public view returns (uint) {return balances[_account];}
    mapping (address => uint) public balances;

    //定义的事件，类似日志，当有相关消息时候，会及时展示
    //定义后，最后一行就可以发出消息了，为了接收到相关消息，可以使用如下方式来监听：

    /** 该方法需要由前端代码来执行：
     * Coin.Sent().watch({}, '', function(error, result) {
           if (!error) {
              console.log("Coin transfer: " + result.args.amount +
                  " coins were sent from " + result.args.from +
                  " to " + result.args.to + ".");
              console.log("Balances now:\n" +
                  "Sender: " + Coin.balances.call(result.args.from) +
                  "Receiver: " + Coin.balances.call(result.args.to));
               } //注意balances的生成方式
            })
     */
    event Sent(address from, address to, uint amount);

    /**
     * 合约的构造函数，合约创建时候就会被调用唯一一次
     * msg,tx,block是比较特殊的全局变量，包含了一些允许进入区块链的属性
     * msg.sender总是外部函数调用某函数的人的地址(当前消息发送者)
     * ，比如此处Coin智能合约创建人先调用的Coin()，因此，minter代表智能合约创建者
     */
    function Coin() public {
        minter = msg.sender; //m
    }

    /**
     * 类似挖矿
     * 此处，只有合约部署者可以挖矿
     */
    function mint(address receiver, uint amount) public {
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }

    /**
     * 币的发送
     */
    function send(address receiver, uint amount) public {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}