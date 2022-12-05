package main

import (
	"fmt"
	"net/http"
)

var driver = Driver{}

func main() {
	http.HandleFunc("/off", turnOff)
	http.HandleFunc("/on", turnOn)
	http.HandleFunc("/status", status)
	http.HandleFunc("/toggle", toggle)
	http.HandleFunc("/", index)
	http.ListenAndServe(":8082", nil)
}

func statusStr(status bool) string {
	if status {
		return "On"
	} else {
		return "Off"
	}
}
func toggle(w http.ResponseWriter, req *http.Request) {
	if driver.isOn {
		driver.Off()
	} else {
		driver.On()
	}
	status(w, req)
}

func turnOff(w http.ResponseWriter, req *http.Request) {
	driver.Off()
	status(w, req)
}
func turnOn(w http.ResponseWriter, req *http.Request) {
	driver.On()
	status(w, req)
}

func status(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, `{"status":"`+statusStr(driver.Status())+`"}`)
}

func index(w http.ResponseWriter, req *http.Request) {
	http.ServeFile(w, req, "/root/index.html")
}
