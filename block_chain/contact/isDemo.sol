pragma solidity ^0.4.0;

contract F {
    uint internal u = 10;

    function F(uint _a) returns(uint){
        return 100;
    }
}

contract F1{
    uint public fu;
    function  F1(uint _u){
        fu = _u;
    }
}

contract isDemo is F,F1(20){
    uint public c1;
    uint public c2;
    uint public c3;

    function c(){
        c1 = F.u;
        c2 = F.test();
        c3 = F1.fu;
    }
}
