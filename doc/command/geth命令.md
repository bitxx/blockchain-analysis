#geth命令
##配置geth软链接
```bash
ln -s /Users/singularapple/Documents/sangular_project/go/blockchain-analysis/src/github.com/ethereum/go-ethereum/build/bin/geth /usr/local/bin/geth
```
##启动私有网络
```bash
geth --identity "SJAEthereum" -rpc --rpccorsdomain "*" --datadir "/Users/singularapple/Documents/sangular_project/go/blockchain-analysis/block_chain" --port "30303" --rpcapi "db,eth,net,web3" --networkid 150601 --nodiscover --verbosity=5 console 2>> /Users/singularapple/Documents/sangular_project/go/blockchain-analysis/block_chain/log/block_chain.log
```
##连接已有网络
```bash
geth attach --datadir "/Users/singularapple/Documents/sangular_project/go/blockchain-analysis/block_chain"
```