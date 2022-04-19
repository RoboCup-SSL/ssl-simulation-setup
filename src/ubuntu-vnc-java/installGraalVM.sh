#!/usr/bin/env bash

set -e

mkdir -p /usr/lib/jvm/
cd /usr/lib/jvm/ || exit 1
wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-22.0.0.2/graalvm-ce-java17-linux-amd64-22.0.0.2.tar.gz -q -O - | tar xz
update-alternatives --install /usr/bin/java java /usr/lib/jvm/graalvm-ce-java17-22.0.0.2/bin/java 100
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/graalvm-ce-java17-22.0.0.2/bin/javac 100
update-alternatives --set java /usr/lib/jvm/graalvm-ce-java17-22.0.0.2/bin/java
update-alternatives --set javac /usr/lib/jvm/graalvm-ce-java17-22.0.0.2/bin/javac
