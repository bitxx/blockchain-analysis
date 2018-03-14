pragma solidity ^0.4.0;

contract Test1 {
    uint public x;
    uint public amount;

    function Test1(uint _a) public payable{
        x = _a;
        amount = msg.value;
    }
}

contract Test2{
    event e(uint x,uint amount);
    Test1 t = new Test1(4);
    function Test2(uint _u) public payable{
        emit e(t.x(),t.amount());
        Test1 tt = new Test1(_u);
        emit e(tt.x(),tt.amount());
    }

    function createTest1(uint _x,uint _amount) public {
        Test1 ttt = (new Test1).value(_amount)(_x);
        emit e(ttt.x(),ttt.amount());
    }
}
