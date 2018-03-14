// Copyright 2014 The go-ethereum Authors
// This file is part of the go-ethereum library.
//
// The go-ethereum library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The go-ethereum library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the go-ethereum library. If not, see <http://www.gnu.org/licenses/>.

/*
文档代码
递归长度前缀编码，是以太坊中的序列化方法，以太坊的所有对象都会使用RLP方法序列化为字节数组。
一个字节8位。
1. 拥有两种结构,树形结构以及字节数组，将这两种结构序列化
2. 对于所有B类型的字节数组。我们定义了如下的处理规则。
   如果字节数组只包含一个字节（ASCII码），而且这个字节的大小小于128，那么不对数据进行处理，处理结果就是原数据
   如果字节数组的长度小于56，那么处理结果就等于在原始数据前面加上（128+字节数据的长度)的前缀。
   如果不是上面两种情况，那么处理结果就等于在原始数据前面加上原始数据长度的大端表示，然后在前面加上（183 + 原始数据大端表示的长度)
3. 大端模式，是指数据的高字节保存在内存的低地址中，而数据的低字节保存在内存的高地址中，这样的存储模式有点儿类似于把数据当作字符串顺序处理：地址由小向大增加，而数据从高位往低位放；这和我们的阅读习惯一致。
   小端模式，是指数据的高字节保存在内存的高地址中，而数据的低字节保存在内存的低地址中，这种存储模式将地址的高低和数据位权有效地结合起来，高地址部分权值高，低地址部分权值低。
Package rlp implements the RLP serialization format.

The purpose of RLP (Recursive Linear Prefix) is to encode arbitrarily
nested arrays of binary data, and RLP is the main encoding method used
to serialize objects in Ethereum. The only purpose of RLP is to encode
structure; encoding specific atomic data types (eg. strings, ints,
floats) is left up to higher-order protocols; in Ethereum integers
must be represented in big endian binary form with no leading zeroes
(thus making the integer value zero equivalent to the empty byte
array).

RLP values are distinguished by a type tag. The type tag precedes the
value in the input stream and defines the size and kind of the bytes
that follow.
*/
package rlp
