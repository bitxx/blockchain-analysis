#geth常用命令
##通用命令
1. 赋值，或者说是起别名
    ```bash
    # 此处以为账户昵称起别名为例
    sja1=web3.eth.accounts[0]
    ```
##admin命令
1. 检查当前对接哪些节点
    ```bash
    admin.peers
    ```  
2. 静态添加节点
    ```bash
    # ip_addr为被添加的节点地址
    admin.addPeer("node://xxxx@ip_addr:30303")
    ```  
3. 查看自己的网络节点信息
    ```bash
    admin.nodeInfo
    ```
## personal命令
1. 查看总共有哪些用户
    ```bash
    personal.listAccounts
    ```
2. 创建用户
    ```bash
    # 回车后手动输入两遍密码
    personal.newAccount() 
    ``` 
    ```bash
    # 直接输入密码
    personal.newAccount("密码") 
    ``` 
3. 解锁
    ```bash
    personal.unlockAccount(eth.accounts[0], "sja123")
    ```
##eth命令
1. 查看有多少块  
    ```bash
    eth.blockNumber
    ```
2. 查看总共有哪些用户
    ```bash
    eth.accounts
    ```
3. 获取当前默认账号：
    ```bash
    eth.coinbase
    ```
4. 以wei为单位获取某账户财产
    ```bash
    eth.getBalance(eth.accounts[0])
    ```
5. 转账  
    ```bash
    eth.sendTransac0xe3ac04d1f30877de3948b1b0979882971440b6dation({from:eth.accounts[0],to:eth.accounts[3],value:web3.toWei(1000,"ether")})
    ```
6. 查看交易  
    ```bash
    eth.getTransaction("0x4d235f83e62d62553397184cd49d8a106a395dee3d55f1545761ec71d279a02b")
    ```
7. 查看块信息  
    ```bash
    eth.getBlock(8112)
    ```
##miner命令
1. 为挖矿设置默认账号
    ```bash
    miner.setEtherbase(eth.accounts[0])
    ```
2. 开始挖矿
    ```bash
    # 其中10为线程数
    miner.start(10)
    ```
3. 停止挖矿
    ```bash
    miner.stop()
    ```
##web3命令
1. 以eth单位获取某账户财产信息
    ```bash
    web3.fromWei(eth.getBalance(eth.coinbase), "ether")
    ```
2. 将数据转换为10进制
    ```bash
    web3.toDecimal("0xff")
    ```
3. 将数据转为UTF-8的
    ```bash
    web3.toUtf8("0x6162")
    ```
4. 以eth单位查看账户余额  
    ```bash
    web3.fromWei(eth.getBalance(eth.coinbase), "ether")
    ```
