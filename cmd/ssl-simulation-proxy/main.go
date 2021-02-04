package main

import (
	"flag"
	"fmt"
	"github.com/RoboCup-SSL/ssl-simulation-setup/pkg/proxy"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"
)

func main() {
	flag.Usage = Usage
	flag.Parse()

	var proxies []proxy.Stoppable

	for _, arg := range flag.Args() {
		parts := strings.Split(arg, ";")
		if len(parts) < 3 {
			log.Printf("Expected a string with two ';': %s", arg)
			Usage()
			os.Exit(1)
		}
		switch parts[0] {
		case "udp":
			udpProxy := proxy.NewUdpProxy(parts[1], parts[2])
			udpProxy.Start()
			proxies = append(proxies, udpProxy)
		case "mc":
			multicastProxy := proxy.NewMulticastProxy(parts[1], parts[2])
			if len(parts) > 3 {
				multicastProxy.SkipInterfaces(parseSkipInterfaces(parts[3]))
			}
			multicastProxy.Start()
			proxies = append(proxies, multicastProxy)
		}
	}

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, syscall.SIGINT, syscall.SIGTERM)
	<-signals
	for _, p := range proxies {
		p.Stop()
	}
}

func Usage() {
	fmt.Fprintf(flag.CommandLine.Output(), "Usage of %s:\n", os.Args[0])
	fmt.Fprintf(flag.CommandLine.Output(), "Proxy either udp or multicast (mc)")
	fmt.Fprintf(flag.CommandLine.Output(), "%s [options] [[udp|mc];sourceAddress:targetAddress]...\n", os.Args[0])
	flag.PrintDefaults()
}

func parseSkipInterfaces(ifis string) []string {
	return strings.Split(ifis, ",")
}
