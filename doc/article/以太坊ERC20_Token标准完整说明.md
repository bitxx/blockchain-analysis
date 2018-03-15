# 以太坊ERC20_Token标准完整说明  
市面上出现了大量的用ETH做的代币，他们都遵守REC20协议，那么我们需要知道什么是REC20协议。   
**idea_wj小编备注：**  
* 本文参考了：http://blog.csdn.net/diandianxiyu_geek/article/details/78082551?utm_source=gold_browser_extension  
* 原文中涉及到了以太坊官方的翻译，但部分翻译不太好理解，小编按自己理解改了一下。  
* 以太坊Token涉及官方标准：https://ethereum.org/token#the-code
* 基于此规范,小编实现了Token合约[MyToken](../../block_chain/contact/Fan.sol):
## 什么是ERC20 token  
* token代表数字资产，具有价值，但是并不是都符合特定的规范。  
* 基于ERC20的货币更容易互换，并且能够在Dapps上相同的工作。  
* 新的标准可以让token更兼容，允许其他功能，包括投票标记化。操作更像一个投票操作  
* Token的持有人可以完全控制资产，遵守ERC20的token可以跟踪任何人在任何时间拥有多少token.基于eth合约的子货币，所以容易实施。只能自己去转让。  
* 标准化非常有利，也就意味着这些资产可以用于不同的平台和项目，否则只能用在特定的场合。  
## ERC20 Token标准(Github)  
### 序言
```
EIP: 20
Title: ERC-20 Token Standard
Author: Fabian Vogelsteller fabian@ethereum.org, Vitalik Buterin vitalik.buterin@ethereum.org
Type: Standard
Category: ERC
Status: Accepted
Created: 2015-11-19
```  
### 总结  
token的接口标准  
### 抽象  
以下标准允许在智能合约中实施标记的标记API。 该标准提供了转移token的基本功能，并允许token被批准，以便他们可以由另一个在线第三方使用。  
### 动机  
标准接口可以让Ethereum上的任何令牌被其他应用程序重新使用：从钱包到分散式交换。
### Token规则
#### 方法  
注意：当方法返回false时，方法调用者必须对这种状况进行处理。  
* 获取这个token的名称
    ```
    //@return name：返回这个令牌的名字
    function name() constant returns (string name)
    ```
* 获取这个令牌（token）的符号  
    ```
    //@return symbol：返回这个令牌的符号
    function symbol() constant returns (string symbol)
    ```  
* 获取token使用的小数点的后几位，比如 8,表示分配token数量为100000000 
    ```
    //@return decimals：返回这个小数点的后几位
    function decimals() constant returns (uint8 decimals)
    ```  
* 获取token的供应总量 
    ```
    //@return totalSupply：返回token的总供应量。
    function totalSupply() constant returns (uint256 totalSupply)
    ```  
* 获取的地址是_owner的账户的账户余额 
    ```
    //@param _owner: 用户地址
    //@return balance：返回token的总供应量。
    function balanceOf(address _owner) constant returns (uint256 balance)
    ```  
* 转移token，也就是交易 
    ```
    //@param _to 使用msg.sender发送代币给_to
    //@param _value token值
    //@return success：返回交易是否成功
    function transfer(address _to, uint256 _value) returns (bool success)
    ``` 
#### 事件  
* 当token被转移（包括0值），必须被触发。  
    ```
    event Transfer(address indexed _from, address indexed _to, uint256 _value)
    ```  
* 允许的最大交易  
    ```
    event Approval(address indexed _owner, address indexed _spender, uint256 _val
    ```