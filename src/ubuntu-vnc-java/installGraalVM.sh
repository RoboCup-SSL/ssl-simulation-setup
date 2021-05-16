#!/usr/bin/env bash

set -e

mkdir -p /usr/lib/jvm/
cd /usr/lib/jvm/ || exit 1
wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.1.0/graalvm-ce-java16-linux-amd64-21.1.0.tar.gz -q -O - | tar xz

update-alternatives --install /usr/bin/java java /usr/lib/jvm/graalvm-ce-java16-21.1.0/bin/java 100
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/graalvm-ce-java16-21.1.0/bin/javac 100
update-alternatives --set java /usr/lib/jvm/graalvm-ce-java16-21.1.0/bin/java
update-alternatives --set javac /usr/lib/jvm/graalvm-ce-java16-21.1.0/bin/javac
