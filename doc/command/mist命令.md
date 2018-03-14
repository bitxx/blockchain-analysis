##mist相关命令
1. 连接私有网络,以下为mac的命令，windows类似  
备注：若要连接私有网络，建议geth启动以太坊时候，
不要设置--port 端口为30303，这是供公共测试网络使用的，建议设置为别的端口，如30309
    ```bash
    /Applications/Mist.app/Contents/MacOS/Mist --rpc ./geth.ipc
    ```
2. 