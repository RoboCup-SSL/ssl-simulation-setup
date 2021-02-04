package main

import (
	"flag"
	"github.com/RoboCup-SSL/ssl-simulation-setup/pkg/proxy"
	"os"
	"os/signal"
	"syscall"
)

var sourceAddressSimControl = flag.String("sourceAddressSimControl", ":10300", "")
var sourceAddressRobotControlBlue = flag.String("sourceAddressRobotControlBlue", ":10301", "")
var sourceAddressRobotControlYellow = flag.String("sourceAddressRobotControlYellow", ":10302", "")
var targetPortSimControl = flag.String("targetPortSimControl", "10300", "")
var targetPortRobotControlBlue = flag.String("targetPortRobotControlBlue", "10301", "")
var targetPortRobotControlYellow = flag.String("targetPortRobotControlYellow", "10302", "")
var targetHost = flag.String("targetHost", "simulator", "")

func main() {
	flag.Parse()

	simControlProxy := proxy.NewUdpProxy(*sourceAddressSimControl, *targetHost+":"+*targetPortSimControl)
	simControlProxy.Start()

	robotControlBlueProxy := proxy.NewUdpProxy(*sourceAddressRobotControlBlue, *targetHost+":"+*targetPortRobotControlBlue)
	robotControlBlueProxy.Start()

	robotControlYellowProxy := proxy.NewUdpProxy(*sourceAddressRobotControlYellow, *targetHost+":"+*targetPortRobotControlYellow)
	robotControlYellowProxy.Start()

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, syscall.SIGINT, syscall.SIGTERM)
	<-signals
	simControlProxy.Stop()
	robotControlBlueProxy.Stop()
	robotControlYellowProxy.Stop()
}
