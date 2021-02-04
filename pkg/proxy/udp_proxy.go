package proxy

import (
	"net"
)

type UdpProxy struct {
	sourceAddress string
	targetAddress string
	server        *UdpServer
	clients       map[string]*Client
	Stoppable
}

type Client struct {
	address   *net.UDPAddr
	udpClient *UdpClient
	udpServer *UdpServer
}

func NewUdpProxy(sourceAddress, targetAddress string) (p *UdpProxy) {
	p = new(UdpProxy)
	p.sourceAddress = sourceAddress
	p.targetAddress = targetAddress
	p.server = NewUdpServer(sourceAddress, p.newDataFromSource)
	p.clients = map[string]*Client{}
	return
}

func (p *UdpProxy) newDataFromSource(data []byte, sourceAddr *net.UDPAddr) {
	client, ok := p.clients[sourceAddr.String()]
	if !ok {
		client = &Client{address: sourceAddr, udpServer: p.server}
		client.udpClient = NewUdpClient(p.targetAddress, client.newData)
		client.Start()
		p.clients[sourceAddr.String()] = client
	}
	client.send(data)
}

func (c *Client) newData(data []byte) {
	c.udpServer.Respond(data, c.address)
}
func (c *Client) send(data []byte) {
	c.udpClient.Send(data)
}

func (c *Client) Start() {
	c.udpClient.Start()
}

func (c *Client) Stop() {
	c.udpClient.Stop()
}

func (p *UdpProxy) Start() {
	p.server.Start()
}

func (p *UdpProxy) Stop() {
	p.server.Stop()
	for _, c := range p.clients {
		c.Stop()
	}
	p.clients = map[string]*Client{}
}
