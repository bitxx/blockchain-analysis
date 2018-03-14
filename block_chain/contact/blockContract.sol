pragma solidity ^0.4.0;

contract blockContract {
    bytes32 public _blockHash;
    address public _coinbase = block.coinbase;
    uint public _difficulty = block.difficulty;
    uint public _gasLimit = block.gaslimit;
    uint public _number = block.number;
    uint public _timestamp = block.timestamp;
    bytes public _data = msg.data;
    address public _sender = msg.sender;
    uint public _gas = gasleft();
    uint public _value = msg.value;
    uint public _gasPrice = tx.gasprice;
    address public _origin = tx.origin;

    //payable表示该合约可以接收以太币
    function blockContract() public payable {}

    //获取区块hash值
    function getHash(uint _u){
        _blockHash = block.blockhash(_u);
    }
}
