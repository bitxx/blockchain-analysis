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

//编码器测试
//用于测试一个结构题导入结果
package rlp

import (
	"fmt"
	"io"
)

type MyCoolType struct {
	Name string  //字符串，名称
	a, b uint    //两个整型数据
}

// EncodeRLP writes x as RLP list [a, b] that omits the Name field.
// MyCoolType的方法
func (x *MyCoolType) EncodeRLP(w io.Writer) (err error) {
	// Note: the receiver can be a nil pointer. This allows you to
	// control the encoding of nil, but it also means that you have to
	// check for a nil receiver.
	if x == nil {
		err = Encode(w, []uint{0, 0})
	} else {
		err = Encode(w, []uint{x.a, x.b})
	}
	return err
}

// 可单独测试该方法，若输出结果与下方Output格式一致，则结果不报错，否则报错
// 测试一个结构体
// 切记，go的测试方法，Output:的格式一定要按如下写出，否则无法测试
//  Output:
func ExampleEncoder() {
	var t *MyCoolType // t is nil pointer to MyCoolType
	bytes, _ := EncodeToBytes(t)
	fmt.Printf("%v → %X\n", t, bytes)

	t = &MyCoolType{Name: "foobar", a: 5, b: 6}
	bytes, _ = EncodeToBytes(t)
	fmt.Printf("%v → %X\n", t, bytes)

	// Output:
	// <nil> → C28080
	// &{foobar 5 6} → C20506
}
