package proxy

import (
	"log"
	"net"
	"sync"
)

type UdpServer struct {
	address  string
	Consumer func([]byte, *net.UDPAddr)
	conn     *net.UDPConn
	running  bool
	mutex    sync.Mutex
}

func NewUdpServer(address string, consumer func([]byte, *net.UDPAddr)) (t *UdpServer) {
	t = new(UdpServer)
	t.address = address
	t.Consumer = consumer
	return
}

func (s *UdpServer) Start() {
	s.running = true
	go s.receive()
}

func (s *UdpServer) Stop() {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	s.running = false
	if err := s.conn.Close(); err != nil {
		log.Println("Could not close client connection: ", err)
	}
}

func (s *UdpServer) isRunning() bool {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	return s.running
}

func (s *UdpServer) receive() {
	addr, err := net.ResolveUDPAddr("udp", s.address)
	if err != nil {
		log.Printf("Could resolve address %v: %v", s.address, err)
		return
	}

	s.conn, err = net.ListenUDP("udp", addr)
	if err != nil {
		log.Printf("Could not listen at %v: %v", s.address, err)
		return
	}

	if err := s.conn.SetReadBuffer(maxDatagramSize); err != nil {
		log.Println("Could not set read buffer: ", err)
	}

	log.Printf("Listening on %s", s.address)

	data := make([]byte, maxDatagramSize)
	for {
		n, clientAddr, err := s.conn.ReadFromUDP(data)
		if err != nil {
			log.Printf("Could not receive data from %s: %s", s.address, err)
			break
		}
		s.Consumer(data[:n], clientAddr)
	}

	log.Printf("Stop listening on %s", s.address)
}

func (s *UdpServer) Respond(data []byte, addr *net.UDPAddr) {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	if _, err := s.conn.WriteToUDP(data, addr); err != nil {
		log.Printf("Could not respond to %s: %s", s.address, err)
	}
}
