pragma solidity ^0.4.11;

import './ERC20Basic.sol';

/**
 * 对基本规范的扩充
 * @title ERC20 interface
 * @dev Implements ERC20 Token Standard: https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    //指定账户进行交易
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    //授权某账户交易额度
    function approve(address _spender, uint256 _value) public returns (bool success);
    //查询_owner允许_spender花费多少额度
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
