.PHONY: all ubuntu-vnc ubuntu-vnc-java ubuntu-vnc-go

all: ubuntu-vnc ubuntu-vnc-java

ubuntu-vnc:
	docker build -t robocupssl/ubuntu-vnc:latest src/ubuntu-vnc

ubuntu-vnc-java: ubuntu-vnc
	docker build -t robocupssl/ubuntu-vnc-java:latest src/ubuntu-vnc-java

ubuntu-vnc-go: ubuntu-vnc
	docker build -t robocupssl/ubuntu-vnc-go:latest src/ubuntu-vnc-go
