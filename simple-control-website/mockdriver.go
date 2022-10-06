//go:build mock
// +build mock

package main

type Driver struct {
	isOn bool
}

func (d *Driver) Status() bool {
	return d.isOn
}

func (d *Driver) Off() error {
	d.isOn = false
	return nil
}

func (d *Driver) On() error {
	d.isOn = true
	return nil
}
