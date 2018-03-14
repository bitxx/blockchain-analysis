# 用GO语言实现比特币算法
* 文章原始地址：http://www.8btc.com/go-bitcoin  
## 概述
本节的这个例子展示一点点高精度数学包一点点散列包hash一点点加密包还有一点点测试包的知识。这里不介绍协议和算法——尽管它们很有趣，而是试图指出，对多种操作系统的支持，是实现这种跨平台应用的理想语言。
## 位钱（bitcoin）  
位钱（bitcoin）是一种使用加密手段制作的分布式电子货币。它最初于1998年由Wei Dai提出，并由中本聪（Satoshi Nakamoto）及其伙伴，于2009年在Windows、Linux和Mac OS X上实现。这些客户端软件帮助用户管理电子钱包，钱包里面包括一系列的公钥加密密钥对（public-key cryptographic keypair）。每个密钥对的公钥（public key）转化为一个位钱地址，作为交易的接收地址。这个地址是可以供人使用的，大约33个字符，使用的是Base58的编码方式。而每个私钥（private key）用来签发发自此钱包的交易。  
![image](./doc/img/1-1.png)
## 实现  
* 我们看看如何使用Go来完成位钱地址所需的Base58编码
```go language
package bitcoin
 
import (
    "math/big"
    "strings"
)
 
const base58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijk lmnopqrstuvwxyz"
 
func EncodeBase58(ba []byte) []byte {
    if len(ba) == 0 {
        return nil
    }
    //Expected size increase from base58 conversion 25 approximately 137%,use 138% to be safe
    ri := len(ba) * 138 / 100
    ra := make([]byte, ri+1)
    x := new(big.Int).SetBytes(ba) // ba is big-endian
    x.Abs(x)
    y := big.NewInt(58)
    m := new(big.Int)

    for x.Sign() > 0 {
        x, m = x.DivMod(x, y, m)
        ra[ri] = base58[int32(m.Int64())]
        ri--
    }

    //Leading zeros encoded as base58 zeros
    for i := 0; i < len(ba); i++ {
        if ba[i] != 0 {
            break
        }
        ra[ri] = '1'
        ri--
    }
    return ra[ri+1:]
}
 
func DecodeBase58(ba []byte) []byte {
    if len(ba) == 0 {
        return nil
    }

    x := new(big.Int)
    y := big.NewInt(58)
    z := new(big.Int)
    for _, b := range ba {
        v := strings.IndexRune(base58, rune(b))
        z.SetInt64(int64(v))
        x.Mul(x, y)
        x.Add(x, z)
    }
    xa := x.Bytes()

    // Restore leading zeros
    i := 0
    for i < len(ba) && ba[i] == '1' {
        i++
    }
    ra := make([]byte, i+len(xa))
    copy(ra[i:], xa)
    return ra
}
 
func EncodeBase58Check(ba []byte) []byte {
    //add 4-byte hash check to the end
    hash := Hash(ba)
    ba = append(ba, hash[:4]...)
    ba = EncodeBase58(ba)
    return ba
}
 
func DecodeBase58Check(ba []byte) bool {
    ba = DecodeBase58(ba)
    if len(ba) < 4 || ba == nil {
        return false
    }

    k := len(ba) - 4
    hash := Hash(ba[:k])
    for i := 0; i < 4; i++ {
        if hash[i] != ba[k+i] {
        return false
        }
    }
    return true
}

```
* big包实现的是任意精度的整数和分数运算，包括四则运算、位运算、取余数、幂、求最大公约数和随机数等。在计算超长位密码时，通常会用到这些运算，例如256位的SHA算法。此处，我们直接把任意长度的字节切片作为一个整数，除以58取余数，就方便地得到了这个字节切片的Base58编码。  
* big包运算通常使用  ```func (z *Int) Op(x, y *Int) *Int```格式。计算是在z上进行的，并且返回z。所以多个运算可以连续地执行。例如，x.Mul(x,y).Add(x.z)和下面分开写的形式是等价的：  
```
x.Mul(x, y)
x.Add(x, z)
```  
* 位钱地址编码使用EncodeBase58Check函数，它把一个切片散列两次得到的4字节加在后面，再使用Base58编码，把它转换为人可以读的、由58个字符组成的字符串。而DecodeBase58Check则用来检查这4字节，确保地址没有传输错误。
***
* 作为电子支付手段，比特币是未雨绸缪、宁枉勿纵的。它在散列时不仅使用了很可靠的SHA256算法，而且还要散列两次： 
```
package bitcoin
 
import (
    "crypto/sha256"
    "hash"
)
 
var sha, sha2 hash.Hash
 
func init() {
    sha = sha256.New()
    sha2 = sha256.New() // hash twice
}
 
func Hash(ba []byte) []byte {
    sha.Reset()
    sha2.Reset()
    ba = sha.Sum(ba)
    return sha2.Sum(ba)
}
```  
* hash.Hash是一个界面，而具体实现依靠的是SHA256算法。这里可以看到Go的加密包使用起来是多么简单。无论使用怎样的散列算法，只要一个New和一个Sum就可以了。Reset用于将值重新置0。Size用于返回Sum所需的字节数。而它还内置了另一个界面io.Writer，可以使用Writer提供的方法追加数值。  
* crypto包的子目录提供了一些常用的散列算法和加密解密算法，例如MD5、SHA1、SHA256等散列算法；AES、DES、Elliptic等加密算法，以及RSA、DSA、TLS等协议。这些都用来实现对Go的http包所使用的HTTPS因特网加密通信协议的支持。我们此处只是使用了最简单的SHA256算法。说它简单，不是因为算法简单，也不是因为计算机代码实现简单，而是编程界面API简单。对于普通程序员来说，能够正确实施复杂精密的密码操作才是最关键的。Go在简化API方面可以说是不遗余力。只要访问http://code.google.com/p/go/，看看crypto和hash这两个包的API的演变过程就很清楚了。在密码学里，这通常总结为：链条断在最弱的一环。而写程序的人，总是最不可靠、最易出差错的。
* 为了确保程序少出差错，最直接的做法是随程序源代码一起编写测试用例。每次修订程序时，就自动测试，保证没有不同结果。Go的测试包可以使用go test工具。它会自动执行包目录中所有以_test.go结尾的文件里所有以Test开头的使用测试签名的函数。例如：  
    ```
    package bitcoin
     
    import (
        "testing"
    )
     
    type test struct {
        en, de string
    }
     
    var golden = []test{
        {"", ""},
        {"\x61″, "2g"},
        {"\x62\x62\x62″, "a3gV"},
        {"\x63\x63\x63″, "aPEr"},
        {"\x73\x69\x6d\x70\x6c\x79\x20\x61\x20\x6c\x6f\x6e\x67\x20\x73\x74\x72\x69\x6e\x67″, "2cFupjhnEsSn59qHXstmK2ffpLv2″},
        {"\x00\xeb\x15\x23\x1d\xfc\xeb\x60\x92\x58\x86\xb6\x7d\x06\x52\x99\x92\x59\x15\xae\xb1\x72\xc0\x66\x47″, "1NS17iag9jJgTHD 1VXjvLCEnZuQ3rJDE9L"},
        {"\x51\x6b\x6f\xcd\x0f", "ABnLTmg"},
        {"\xbf\x4f\x89\x00\x1e\x67\x02\x74\xdd", "3SEo3LWLoPntC"},
        {"\x57\x2e\x47\x94″, "3EFU7m"},
        {"\xec\xac\x89\xca\xd9\x39\x23\xc0\x23\x21″, "EJDM8drfXA 6uyA"},
        {"\x10\xc8\x51\x1e", "Rt5zm"},
        {"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00″, "1111111111″},
    }
     
    func TestEncodeBase58(t *testing.T) {
        for _, g := range golden {
            s := string(EncodeBase58([]byte(g.en)))
            if s != g.de {
                t.Errorf("EncodeBase58. Need=%v, Got=%v", g.de, s)
            }
        }
    }  
      
    func TestDecodeBase58(t *testing.T) {
        for _, g := range golden {
            s := string(DecodeBase58([]byte(g.de)))
            if s != g.en {
                t.Errorf("DecodeBase58. Need=%v, Got=%v", g.en, s)
            }
        }
    }  
      
    func TestBase58Check(t *testing.T) {
        ba := []byte("Bitcoin")
        ba = EncodeBase58Check(ba)
        if !DecodeBase58Check(ba) {
            t.Errorf("TestBase58Check. Got=%v", ba)
        }
    }
```  
* 对于编写支持所有桌面操作系统的位钱程序，这只是个开始。Go提供了RIPEMD160散列算法，也提供了ECDSA公钥算法。而Go的网络包net，可以用来实现点对点联网（peer-to-peer networking）。这些已经可以支持位钱的实现了。