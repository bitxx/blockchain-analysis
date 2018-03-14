pragma solidity ^0.4.0;

contract addressDemo {

    function addressDemo() public payable{

    }
    function sendDemo(address add) public{
        uint u = 1 ether; //1个以太币
        add.transfer(u); //向add发送一个以太币
    }
}
