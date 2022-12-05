//go:build !mock
// +build !mock

package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path"
)

const hub = "1-1"
const dir = "/sys/bus/usb/drivers/usb"

func init() {
	// sudo uhubctl -l 2 -a 0 -e
	// sudo uhubctl -l 1-1 -p 2 -a 0 -e
	err := exec.Command("bash", "-c", "uhubctl -l 2 -a 0 -e").Run()
	if err != nil {
		panic(err)
	}
	exec.Command("uhubctl", "-l 1-1", "-p 2", "-a 0", "-e").Run()
	if err != nil {
		panic(err)
	}
}

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
	d.isOn = false
	err := os.WriteFile(path.Join(dir, "unbind"), []byte(hub+"\n"), 0)
	if err != nil {
		fmt.Println("Err", err)
	}
	return nil
}

func (d *Driver) On() error {
	d.isOn = true
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
