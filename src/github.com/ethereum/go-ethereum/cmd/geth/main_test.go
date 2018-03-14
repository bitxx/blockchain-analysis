package main
import (
	"os"
	"github.com/ethereum/go-ethereum/common"
	"fmt"
	"gopkg.in/urfave/cli.v1"
)

var r = common.HexToAddress("0xfa7b9770ca4cb04296cac84f37736d4041251cdf")

/**
 是小编后来新加的一个测试文件，方便自己测试用
 */
func ExampleMain(){
	app := cli.NewApp()
	app.Name = "boom"
	app.Usage = "make an explosive entrance"
	app.Action = func(c *cli.Context) error {
		fmt.Println("boom! I say!")
		return nil
	}

	err := app.Run(os.Args)
	if err != nil {
		fmt.Println(err)
	}

	// Output:
	//sss
}