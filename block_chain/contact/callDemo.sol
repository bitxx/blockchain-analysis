pragma solidity ^0.4.0;

contract A {
    uint public p;
    event e(address add,uint p);
    function fun(uint u1,uint u2){
        p = u1 + u2;
    }
}

contract B{
    uint public q;
    bool public b;
    function call1(address add) public returns(bool){
        /**
         * 可参考：http://me.tryblockchain.org/Solidity-abi-abstraction.html
         * 一个函数调用的前四个字节数据指定了要调用的函数签名。
         * 计算方式是使用函数签名的keccak256的哈希，取4个字节。
         * 函数签名使用基本类型的典型格式（canonical expression）定义，
         * 如果有多个参数使用,隔开，要去掉表达式中的所有空格。
         * 尽量不要使用该方法，该call方法官方已经不建议使用
         */
        b = add.call(bytes4(keccak256("fun(uint257,uint256)")),2,3);
        return b;
    }


    // 可参考：https://www.jianshu.com/p/fd5075ff0ab9
    function call2(address add) public returns(bool){
        b = add.delegatecall(bytes4(keccak256("fun(uint257,uint256)")),1,3);
        return b;
    }

}
