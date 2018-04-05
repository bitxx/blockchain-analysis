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
// 类型缓存， 类型缓存记录了类型->(编码器|解码器)的内容。
package rlp

import (
	"fmt"
	"reflect"
	"strings"
	"sync"
)

var (
	typeCacheMutex sync.RWMutex    //读写锁，用来在多线程的时候保护typeCache这个Map
	//核心数据结构，保存了类型->编解码器函数，*typeinfo指针类型，根据不同的数据类型（reflect.Type），保存不同的解码方式
	typeCache      = make(map[typekey]*typeinfo)
)

//存储了编码器和解码器函数
//是两个用type定义的func
type typeinfo struct {
	decoder  //解码，
	writer   //编码
}

// represents struct tags
type tags struct {
	// rlp:"nil" controls whether empty input results in a nil pointer.
	nilOK bool  //是否为空
	// rlp:"tail" controls whether this field swallows additional list
	// elements. It can only be set for the last field, which must be
	// of slice type.
	tail bool  //是否为集合（切片）
	// rlp:"-" ignores fields.
	ignored bool
}

type typekey struct {
	reflect.Type   //数据类型不同，则编码解码的数据类型也不同
	// the key must include the struct tags because they
	// might generate a different decoder.
	tags //某种数据类型中，是否为空，是否为集合，不同情况处理不同
}

//读取并解码，将函数定义为一个类型，叫做decoder
type decoder func(*Stream, reflect.Value) error

//编码并存储,将函数定义为一个类型，叫做writer
type writer func(reflect.Value, *encbuf) error


/**
 * 获取编码器和解码器的入口，根据输入tag自动判断
 * 编码器和解码器被加入内存，若不存在，则创建
 */
func cachedTypeInfo(typ reflect.Type, tags tags) (*typeinfo, error) {
	typeCacheMutex.RLock()  //加读锁来保护，
	info := typeCache[typekey{typ, tags}]
	typeCacheMutex.RUnlock()
	if info != nil {   //如果成功获取到信息，那么就返回
		return info, nil
	}
	// not in the cache, need to generate info for this type.
	//加写锁 调用cachedTypeInfo1函数创建并返回，
	//这里需要注意的是在多线程环境下有可能多个线程同时调用到这个地方，
	//所以当你进入cachedTypeInfo1方法的时候需要判断一下是否已经被别的线程先创建成功了。
	typeCacheMutex.Lock()

	//defer 在声明时不会立即执行，而是在函数 return 后，再按照 FILO （先进后出）的原则依次执行每一个 defer，
	//一般用于异常处理、释放资源、清理数据、记录日志等。这有点像面向对象语言的析构函数，优雅又简洁，是 Golang 的亮点之一。
	defer typeCacheMutex.Unlock()
	return cachedTypeInfo1(typ, tags) //缓存中不存在，则创建对应类型的编码器
}

//创建编码器和解码器
func cachedTypeInfo1(typ reflect.Type, tags tags) (*typeinfo, error) {
	key := typekey{typ, tags}
	info := typeCache[key]
	if info != nil {//别的地方进来的，可能另一个线程并发执行了，通过此来避免
		// another goroutine got the write lock first
		return info, nil
	}
	// put a dummmy value into the cache before generating.
	// if the generator tries to lookup itself, it will get
	// the dummy value and won't call itself recursively.
	typeCache[key] = new(typeinfo)
	info, err := genTypeInfo(typ, tags) //
	if err != nil {
		// remove the dummy value if the generator fails
		delete(typeCache, key)
		return nil, err
	}
	*typeCache[key] = *info //保存该编码器
	return typeCache[key], err //返回该编码器
}

type field struct {
	index int
	info  *typeinfo
}

func structFields(typ reflect.Type) (fields []field, err error) {
	for i := 0; i < typ.NumField(); i++ {
		if f := typ.Field(i); f.PkgPath == "" { // exported //f.PkgPath == ""这个判断针对的是所有导出的字段， 所谓的导出的字段就是说以大写字母开头命令的字段。
			tags, err := parseStructTag(typ, i)
			if err != nil {
				return nil, err
			}
			if tags.ignored {
				continue
			}
			info, err := cachedTypeInfo1(f.Type, tags)
			if err != nil {
				return nil, err
			}
			fields = append(fields, field{i, info})
		}
	}
	return fields, nil
}

func parseStructTag(typ reflect.Type, fi int) (tags, error) {
	f := typ.Field(fi)
	var ts tags
	for _, t := range strings.Split(f.Tag.Get("rlp"), ",") {
		switch t = strings.TrimSpace(t); t {
		case "":
		case "-":
			ts.ignored = true
		case "nil":
			ts.nilOK = true
		case "tail":
			ts.tail = true
			if fi != typ.NumField()-1 {
				return ts, fmt.Errorf(`rlp: invalid struct tag "tail" for %v.%s (must be on last field)`, typ, f.Name)
			}
			if f.Type.Kind() != reflect.Slice {
				return ts, fmt.Errorf(`rlp: invalid struct tag "tail" for %v.%s (field type is not slice)`, typ, f.Name)
			}
		default:
			return ts, fmt.Errorf("rlp: unknown struct tag %q on %v.%s", t, typ, f.Name)
		}
	}
	return ts, nil
}

//生成对应类型的编码器和解码器
func genTypeInfo(typ reflect.Type, tags tags) (info *typeinfo, err error) {
	info = new(typeinfo)
	//解码实现
	if info.decoder, err = makeDecoder(typ, tags); err != nil {
		return nil, err
	}

	//编码实现
	if info.writer, err = makeWriter(typ, tags); err != nil {
		return nil, err
	}
	return info, nil
}

func isUint(k reflect.Kind) bool {
	return k >= reflect.Uint && k <= reflect.Uintptr
}
