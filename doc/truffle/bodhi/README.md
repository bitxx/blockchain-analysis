# 基于Truffle的Bodhi Token项目分析  
* 虽然Truffle官方文档给出了详细的使用描述，但对于第一次接触的人来说，在实际项目中的使用还是会感到无处下手。
* 这里小编通过分析一个已经比较成熟的菩提Token项目来更详细的了解一下Truffle在一个真实的项目中是怎样运转的。
* 小编此处上传的菩提Token源码仅限用于分析，具体环境搭建以及安装部署请参考官方描述官方：https://github.com/bodhiproject/contracts
* Truffle版本：4.1.3，最好先对此工具有一定的了解
* Nodejs版本：9.8.0，阅读者要有此基础
## 安装部署（概述）
菩提官方的安装流程已经描述的很详细了，在此，小编只是解释下其中的几个步骤。  
* 官方在项目中集成了testrpc环境，小编使用的是"truffle develop环境，将官方的testrpc环境依赖去掉了；另外，truffle中包含有mocha和chai测试工具，另外还单独安装了bluebird工具;最终，小编将package.json修改为如下：  
    ```json
    {
      "name": "bodhi-crowdsale-contracts",
      "version": "1.0.0",
      "description": "Bodhi Token crowdsale contracts",
      "directories": {
        "test": "test"
      },
      "dependencies": {
        "bluebird": "^3.5.0",
        "chai": "^4.1.1"
      }
    }
    ```  
* 官方提到的，在根目录下运行*npm install*，会将package.json中的依赖全部安装（NodeJS基础）。  
* 官方提到的，在根目录下运行*test*，会自动运行test目录下的所有文件，包括合约.sol文件也都会被编译。
* test环境是独立的一个沙盒环境，包括编译(compile)、发布(migrate)等。
* 运行test后，会发现有红色异常显示，这是测试正常现象（断言结果），代码中调整不同参数即可。
## 项目目录介绍  
.  
|____truffle.js **//用于配置truffle的文件，可配置测试网络和正式环境的网络**  
|____migrations **//用于发布合约**  
| |____1_initial_migration.js **//发布合约必要的对接文件，按顺序，第一个，不要动**  
| |____2_deploy_contracts.js **//发布自己指定的合约，先要在上面文件之后**  
|____test **//用于测试**  
| |____mocks  **//测试使用的智能合约**  
| | |____BasicTokenMock.sol **//用于测试的基本Token合约（继承）**  
| | |____StandardTokenMock.sol **//用于测试的标准Token合约（继承）**  
| |____standard_token.js **//使用框架测试标准token**  
| |____crowdsale_bodhi_token.js **//使用框架测试菩提用于私募token**  
| |____basic_token.js **//使用框架测试基本token**  
| |____bodhi_token.js **//使用框架菩提token**  
| |____helpers **//测试框架使用的工具**  
|   |____block_height_manager.js **//区块的设置，网络相关**  
|   |____utils.js  **//通用工具**
|____config **//配置合约**  
| |____config.js **//设置合约里的一些参数，比如发行量，起始块等**  
|____contracts **//存放token合约文件**  
| |____Migrations.sol  **//truffle框架中必要的合约，发布自己的合约离不开这文件的对接**  
| |____libs **//辅助的合约包**  
| | |____Ownable.sol **//提供一些基本的鉴定管理，比如合约拥有者鉴定**  
| | |____SafeMath.sol **//安全的加减乘除合约方法**   
| |____tokens  **//存放token合约**  
|   |____StandardToken.sol **//标准token合约**   
|   |____ERC20.sol **//ERC20标准token合约，无具体实现**  
|   |____CrowdsaleBodhiToken.sol **//用于私募token合约**  
|   |____ERC20Basic.sol **//ERC20基本token合约，无具体实现**  
|   |____BasicToken.sol **//基本token合约**   
|   |____BodhiToken.sol **//菩提token合约**  
|____testrpc_high_value.sh **//rpc环境测试，小编没用该文件**  
|____README.md **//你猜这是干嘛**  
|\_\_\_\_.gitignore **//你再猜这是干嘛**  
|____package-lock.json **//nodejs新版，用于记录当前安装包的状态等信息，方便之后安装**     
|____package.json **//该项目依赖的nodejs包都在这里面，主要是测试包bluebird和chai**  
|____solc_compile.sh **//solc编译合约（知道什么是solc吧），小编没用，TruffleDevelop环境就够了**