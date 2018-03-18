# 基于Truffle的Bodhi Token项目分析  
* 虽然Truffle官方文档给出了详细的使用描述，但对于第一次接触的人来说，在实际项目中的使用还是会感到无处下手。
* 这里小编通过分析一个已经比较成熟的菩提Token项目来更详细的了解一下Truffle在一个真实的项目中是怎样运转的。
* 小编此处上传的菩提Token源码仅限用于分析（其中有部分源码小编加上了中文注释），具体环境搭建以及安装部署请参考官方描述官方：https://github.com/bodhiproject/contracts
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
## 测试文件分析  
chai、mocha、bluebrid等测试工具，要是一个个专门去学去了解想想也心累。在此，小编通过分析base_token.js文件来了解下整个测试方式。总共涉及到三个文件：  
base_token.js **//基本token合约测试**  
block_height_manager.js **//base_token依赖文件**  
BasicTokenMock.sol **//该合约继承自BasicToken.sol，用于测试，该文件小编就不分析了**  
### block_height_manager.js分析  
base_token.js需要依赖此文件，因此先分析此文件  
```js
const bluebird = require('bluebird');  //bluebird测试工具
function BlockHeightManager(web3) {
    let getBlockNumber = bluebird.promisify(web3.eth.getBlockNumber); //获取当前块数
    let snapshotId;  
    
    this.revert = () => {
        return new Promise((resolve, reject) => {
            web3.currentProvider.sendAsync({
                jsonrpc: '2.0',
                method: 'evm_revert',
                id: new Date().getTime(),
                params: [snapshotId]
            }, (err, result) => {
                if (err)
                    return reject(err);
                return resolve(this.snapshot());
            });
        });
    }  
    
    this.snapshot = () => {
        return new Promise((resolve, reject) => {
            web3.currentProvider.sendAsync({
                jsonrpc: '2.0',
                method: 'evm_snapshot',
                id: new Date().getTime(),
                params: []
            }, (err, result) => {
                if (err)
                    return reject(err);
                snapshotId = web3.toDecimal(result.result);
                return resolve();
            });
        })
    }  
    
    this.proceedBlock = () => {
        return new Promise((resolve, reject) => {
            web3.currentProvider.sendAsync({
                jsonrpc: '2.0',
                method: 'evm_mine',
                id: new Date().getTime(),
                //params: [numOfBlocks]
            }, (err, result) => {
                if (err)
                    return reject(err);
                return resolve();
            });
        });
    }  
    
    this.mine = async (numOfBlocks) => {
        let i = 0;
        for (i = 0; i < numOfBlocks; i++)
            await this.proceedBlock();
    }  
    
    this.mineTo = async (height) => {
        let currentHeight = await getBlockNumber();
        if (currentHeight > height)
            throw new Error('Expecting height: ' + height + 'is not reachable');
        return this.mine(height - currentHeight);
    }
}

module.exports = BlockHeightManager;
```  
### base_token.js分析  
```js
const BasicTokenMock = artifacts.require('./mocks/BasicTokenMock.sol');
const BlockHeightManager = require('./helpers/block_height_manager');
const assert = require('chai').assert;
const web3 = global.web3;  

contract('BasicToken', function(accounts) {
    const blockHeightManager = new BlockHeightManager(web3);
    const owner = accounts[0];
    const acct1 = accounts[1];
    const acct2 = accounts[2];
    const acct3 = accounts[3];
    const tokenParams = {
        _initialAccount: owner,
        _initialBalance: 10000000
    };  
    
    let instance;
    beforeEach(blockHeightManager.snapshot);
    afterEach(blockHeightManager.revert);
    beforeEach(async function() {
        instance = await BasicTokenMock.new(...Object.values(tokenParams), { from: owner }); //合约最后一项是转账参数
    });  
    
    describe('constructor', async function() {
        it('should initialize all the values correctly', async function() {
            assert.equal(await instance.balanceOf(owner, { from: owner }), tokenParams._initialBalance, 
                'owner balance does not match');
            assert.equal(await instance.totalSupply.call(), tokenParams._initialBalance, 'totalSupply does not match');
        });
    });  
    
    describe('transfer', async function() {
        it('should allow transfers if the account has tokens', async function() {
            var ownerBalance = tokenParams._initialBalance;
            assert.equal(await instance.balanceOf(owner, { from: owner }), ownerBalance, 'owner balance does not match');
            let acct1TransferAmt = 300000;
            await instance.transfer(acct1, acct1TransferAmt, { from: owner });
            assert.equal(await instance.balanceOf(acct1), acct1TransferAmt, 'accounts[1] balance does not match');  
            
            ownerBalance = ownerBalance - acct1TransferAmt;
            assert.equal(await instance.balanceOf(owner), ownerBalance, 
                'owner balance does not match after first transfer');  
            
            let acct2TransferAmt = 250000;
            await instance.transfer(acct2, acct2TransferAmt, { from: owner });
            assert.equal(await instance.balanceOf(acct2), acct2TransferAmt, 'accounts[2] balance does not match');  
            ownerBalance = ownerBalance - acct2TransferAmt;
            assert.equal(await instance.balanceOf(owner, { from: owner }), ownerBalance, 
                'new owner balance does not match after second transfer');  
            
            await instance.transfer(acct3, acct2TransferAmt, { from: acct2 });
            assert.equal(await instance.balanceOf(acct3), acct2TransferAmt, 'accounts[3] balance does not match');
            assert.equal(await instance.balanceOf(acct2), 0, 'accounts[2] balance should be 0');
        });  
        
        it('should throw if the to address is not valid', async function() {
            try {
                await instance.transfer(acct1, 1, { from: owner }); //owner发送token给acct1
            } catch(e) {
                assert.match(e.message, /invalid opcode/);
            }
        });  
        
        it('should throw if the balance of the transferer is less than the amount', async function() {
            assert.equal(await instance.balanceOf(owner), tokenParams._initialBalance, 'owner balance does not match');
            try {
                await instance.transfer(acct1, tokenParams._initialBalance + 1, { from: owner });
            } catch(e) {
                assert.match(e.message, /invalid opcode/);
            }  
            try {
                await instance.transfer(acct3, 1, { from: acct2 });
            } catch(e) {
                assert.match(e.message, /invalid opcode/);
            }
        });
    });  
    
    describe('balanceOf', async function() {
        it('should return the right balance', async function() {
            assert.equal(await instance.balanceOf(owner), tokenParams._initialBalance, 'owner balance does not match');
            assert.equal(await instance.balanceOf(acct1), 0, 'accounts[1] balance should be 0');
            assert.equal(await instance.balanceOf(acct2), 0, 'accounts[2] balance should be 0');
        });
    });
});
```      
    
