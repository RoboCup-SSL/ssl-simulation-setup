package proxy

type MulticastProxy struct {
	sourceAddress string
	targetAddress string
	source        *MulticastServer
	target        *UdpClient
	Stoppable
}

func NewMulticastProxy(sourceAddress, targetAddress string) (p *MulticastProxy) {
	p = new(MulticastProxy)
	p.sourceAddress = sourceAddress
	p.targetAddress = targetAddress
	p.source = NewMulticastServer(p.newDataFromSource)
	p.target = NewUdpClient(p.targetAddress, p.newDataFromTarget)
	return
}

func (p *MulticastProxy) newDataFromSource(data []byte) {
	p.target.Send(data)
}
func (p *MulticastProxy) newDataFromTarget(_ []byte) {
	// ignore
}

func (p *MulticastProxy) Start() {
	p.target.Start()
	p.source.Start(p.sourceAddress)
}

func (p *MulticastProxy) Stop() {
	p.source.Stop()
	p.target.Stop()
}

func (p *MulticastProxy) SkipInterfaces(ifis []string) {
	p.source.SkipInterfaces = ifis
}
