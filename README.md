# blockchain-analysis
* 小编是个初学者，会在业余时候逐步更新这里的内容
* 主要涉及区块链相关资料以及主流区块链源码解析
* 小编为方便阅读和学习，将这两部分内容都放一起了，请谅解 
* 本项目是在IntelliJ idea 2017.3.1版中部署的，项目直接放入其中就好，不要随意改变项目结构，以太坊官方源码只有在此中结构下才能正常运行，具体部署不是小编的重点，此处就不详细解释了，有需要的可以别的网站查阅，资料很多
* go-ethereum version：**1.8.1** 文中描述的源码解析，在源码中也有详细备注  
* **关于文章：小编将其copy过来重新编辑了一下，主要是方便按着自己习惯随时翻阅和标注（文中内容会根据自己的思考进行一些改编）**
## 感谢 
* 列出的有些文章来自不同的博客，在此非常感谢文章原作者，每篇文章小编都会加入对应文章链接，若对作者造成影响，请联系下方微信，小编会及时删除
* 源码解析参考了[ZtesoftCS](https://github.com/ZtesoftCS/go-ethereum-code-analysis)，在此也感谢道友的无私分享。
## 联系方式
* 小编微信二维码 ：  
 ![image](/doc/img/my_wechat.png)  
 **关注时，请添加备注：github区块链爱好者，谢谢^_^**     
## 目录
- 技术文章（顺序不分先后） 
    - [用GO语言实现比特币算法-巴比特](/doc/article/用GO语言实现比特币算法.md) 
    - [以太坊ERC20 Token标准完整说明-CSDN](/doc/article/以太坊ERC20_Token标准完整说明.md)
        - [Token源码实现-附详细中文注释](/block_chain/contact/Fan.sol)
- go-ethereum
    - 源码解析  
        - [常用命令汇总](/doc/command)
        - [rlp源码解析](/doc/eth_src_analysis/rlp源码解析.md)
    - Truffle
        - [基于Truffle的Bodhi Token项目分析](/doc/truffle/bodhi)
        - Truffle官方文档翻译(小编基于4.1.3版翻译)
            - [第1讲 概述](/doc/truffle/doc/第1讲_概述.md)  
            - [第2讲 安装](/doc/truffle/doc/第2讲_安装.md) 
            - [第3讲 创建项目](/doc/truffle/doc/第3讲_创建项目.md)
            - [第4讲 选择一个以太坊客户端](/doc/truffle/doc/第4讲_选择一个以太坊客户端.md)
            - [第5讲 编译合约](/doc/truffle/doc/第5讲_编译合约.md)
            - [第6讲 发布合约](/doc/truffle/doc/第6讲_合约发布.md)
            - [第7.1讲 合约测试](/doc/truffle/doc/第7.1讲_合约测试.md)
            - [第7.2讲 编写一个JavaScript测试文件](/doc/truffle/doc/第7.2讲_编写一个JavaScript测试文件.md)
            - [第12讲 Truffle的develop环境和console环境](/doc/truffle/doc/第12讲_Truffle的develop环境和console环境.md)
            - [第13讲 编写外部脚本](/doc/truffle/doc/第13讲_编写外部脚本.md)
            - [第14讲 各种配置文件](/doc/truffle/doc/第14讲_各种配置文件（truffle.js、MochaJS、Solidity）.md)
            - [第15讲 网络和app发布](/doc/truffle/doc/第15讲_网络和app发布.md)  
            - [第16讲 将应用和truffle集成编译](/doc/truffle/doc/第15讲_将应用和truffle集成编译.md)  
            
- EOS
    - 源码解析
- 其余