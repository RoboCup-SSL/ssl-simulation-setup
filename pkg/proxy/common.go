package proxy

const maxDatagramSize = 8192

type Stoppable interface {
	Stop()
}
