package proxy

import (
	"log"
	"net"
	"sync"
)

type UdpClient struct {
	address  string
	Consumer func([]byte)
	conn     *net.UDPConn
	running  bool
	mutex    sync.Mutex
}

func NewUdpClient(address string, consumer func([]byte)) (t *UdpClient) {
	t = new(UdpClient)
	t.address = address
	t.Consumer = consumer
	return
}

func (c *UdpClient) Start() {
	c.running = true
	c.connect()
}

func (c *UdpClient) Stop() {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	c.running = false
	if err := c.conn.Close(); err != nil {
		log.Println("Could not close client connection: ", err)
	}
}

func (c *UdpClient) isRunning() bool {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	return c.running
}

func (c *UdpClient) connect() {
	addr, err := net.ResolveUDPAddr("udp", c.address)
	if err != nil {
		log.Printf("Could resolve address %v: %v", c.address, err)
		return
	}

	c.conn, err = net.DialUDP("udp", nil, addr)
	if err != nil {
		log.Printf("Could not connect to %v: %v", c.address, err)
		return
	}

	if err := c.conn.SetReadBuffer(maxDatagramSize); err != nil {
		log.Println("Could not set read buffer: ", err)
	}

	go c.receive()
}

func (c *UdpClient) receive() {
	log.Printf("Connected to %s", c.address)

	data := make([]byte, maxDatagramSize)
	for {
		n, _, err := c.conn.ReadFrom(data)
		if err != nil {
			log.Printf("Could not receive data from %s: %s", c.address, err)
			break
		}
		c.Consumer(data[:n])
	}

	log.Printf("Disconnected from %s", c.address)
}

func (c *UdpClient) Send(data []byte) {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	if _, err := c.conn.Write(data); err != nil {
		log.Printf("Could not write to %s: %s", c.address, err)
	}
}
