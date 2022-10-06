//go:build !mock
// +build !mock

package main

import (
	"errors"
	"fmt"
	"os"
	"path"
)

const hub = "1-1"
const dir = "/sys/bus/usb/drivers/usb"

type Driver struct {
	isOn bool
}

func (d *Driver) Status() bool {
	if _, err := os.Stat(path.Join(dir, hub)); errors.Is(err, os.ErrNotExist) {
		return false
	}
	return true
}

func (d *Driver) Off() error {
	err := os.WriteFile(path.Join(dir, "unbind"), []byte(hub+"\n"), 0)
	if err != nil {
		fmt.Println("Err", err)
	}
	return nil
}

func (d *Driver) On() error {
	err := os.WriteFile(path.Join(dir, "bind"), []byte(hub+"\n"), 0)
	if err != nil {
		fmt.Println("Err", err)
	}
	return nil
}

// func (d *Driver) Status() bool {
// 	return d.isOn
// }

// func (d *Driver) Off() error {
// 	d.isOn = false
// 	cmd := exec.Command("uhubctl", "-l 2", "-a 0", "-e")
// 	out, err := fmt.Println(cmd.Output())
// 	if err != nil {
// 		fmt.Println(out, err)
// 	}
// 	return nil
// }

// func (d *Driver) On() error {
// 	d.isOn = true
// 	cmd := exec.Command("uhubctl", "-l 2", "-a 1", "-e")
// 	out, err := fmt.Println(cmd.Output())
// 	if err != nil {
// 		fmt.Println(out, err)
// 	}
// 	return nil
// }
