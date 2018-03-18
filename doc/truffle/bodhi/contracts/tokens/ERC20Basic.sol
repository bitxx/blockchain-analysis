pragma solidity ^0.4.11;

/**
 * @title ERC20Basic 基本规范
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  //总发行量
  uint256 public totalSupply;
  //账户余额
  function balanceOf(address _owner) public constant returns (uint256 balance);
  //当前账户交易
  function transfer(address _to, uint256 _value) public returns (bool success);
  //日志
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
}
