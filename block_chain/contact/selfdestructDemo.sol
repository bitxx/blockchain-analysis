pragma solidity ^0.4.0;

contract selfdestructDemo {
    uint internal u = 10;

    event e(address addr);
    function test() returns(uint){
        return 100;
    }

    function selfdestructDemo() payable{
        //创建时候，可以向该合约发送以太币
    }
    function kill(address add){
        e(add);  //当执行kill方法时，会自动打印出add信息
        selfdestruct(add);//自毁前，余额传递给add地址的账户
    }
}
