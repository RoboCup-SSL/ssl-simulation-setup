.PHONY: all ubuntu-vnc ubuntu-vnc-java

all: ubuntu-vnc ubuntu-vnc-java

ubuntu-vnc:
	docker build -t robocupssl/ubuntu-vnc:latest src/ubuntu-vnc

ubuntu-vnc-java: ubuntu-vnc
	docker build -t robocupssl/ubuntu-vnc-java:latest src/ubuntu-vnc-java
