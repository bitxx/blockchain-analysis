# rlp模块源码解析  
* 也可以在[rlp模块源码](/src/github.com/ethereum/go-ethereum/rlp)中查阅源码的中文备注，其中加入了小编比较详细的解释和见解  
* 可参考：https://github.com/jason-wj/go-ethereum-code-analysis/blob/master/rlp%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90.md  
小编是在此基础上进一步完善的  
## 概述
* rlp是以太坊用来序列化的工具，可以将各类数据编码为byte[]数组，也可以从byte[]数组还原为原始数据。方便数据交互等行为。  
* rlp模块中，涉及到编码(encode)和解码(decode)两部分，这两部分都类似，在此，小编只解析编码部分(encode)
***
###正文
1. 经过小编分析，从[encoder_example_test.go](/src/github.com/ethereum/go-ethereum/rlp/encoder_example_test.go)这个文件作为入口是最合适不过  
    1. 这个文件是用来将一个实现了 自定义数据类型接口的结构体 转换为byte[]数组的例子  
        1. 定义了一个结构体：  
        2. 该结构体实现的自定义的数据类型  
        图中EncodeRLP(w io.Writer)方法是一个接口，代表了一种自定义的数据类型接口
        从具体代码可以看出，这个自定义类型为[x,y]，只有两个元素的集合
        3. **注意**：  
        在当前以太坊版本(1.8.1)中，当结构体实现了EncodeRLP接口后，编码时，只会以该接口具体实现的方式来编码，结构体外的数据不会参与编码，因此，上述的MyCoolType结构体中的Name,a,b本身不会参与编码