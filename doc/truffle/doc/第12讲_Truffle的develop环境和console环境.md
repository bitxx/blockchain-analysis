# 第12讲 Truffle的develop环境和console环境  
## 概述
1. 总之是很叼的东西，有时候方便测试
2. 提供了两种方式
    1. Truffle console :一个基本的交互控制台，用于连接一个已有以太坊网络或者是已有的Truffle Develop环境
    2. Truffle Develop：一个基本的控制台，就是创建独立的一个测试环境（模拟以太坊）
3. 为什么会有这两种方式
    1. 使用Truffle console 
        1. 有一个真实的区块链网络
        2. 想要发布到以太坊公共测网络
        3. 想用别的账户名称
    2. 使用Truffle Develop
        1. 用于测试项目，并不急于发布
        2. 不需要特殊的账户操作
        3. 不想安装或者管理区块链客户端
## 命令
1. 退出环境使用：control+c
2. 所有的命令都需要在你项目的根目录下运行
    1. Truffle console环境，命令：  
        ```
        truffle console
        ```  
        他将会在配置文件truffle.js中查找命名为development的网络，并且连接。你也可以使用  —netwokr <name>，这样就会去truffle.js对应的networks的 name  
        <img src="/doc/img/truffle/12-1.png" width = "300" height = "50"/>  

    2. Truffle Develop环境  
        1. 登陆环境:  
        ```bash
        truffle develop
        ```  
    3. 连接localhost:9545，这种方式不会去考虑truffle.js中配置的环境怎样
    4. Truffle console和Truffle Develop的环境的命令基本都一致
## 主要命令  
如果命令不可用，说明该命令对该阶段的项目并不起作用  
1. build
2. compile
3. create
4. debug
5. exec
6. install
7. migrate
8. networks
9. opcode
10. publish
11. test
12. version