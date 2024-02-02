#!/usr/bin/env bash

set -e

mkdir -p /usr/lib/jvm/
cd /usr/lib/jvm/ || exit 1
wget https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-21.0.2/graalvm-community-jdk-21.0.2_linux-x64_bin.tar.gz -q -O - | tar xz
update-alternatives --install /usr/bin/java java /usr/lib/jvm/graalvm-community-openjdk-21.0.2+13.1/bin/java 100
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/graalvm-community-openjdk-21.0.2+13.1/bin/javac 100
update-alternatives --set java /usr/lib/jvm/graalvm-community-openjdk-21.0.2+13.1/bin/java
update-alternatives --set javac /usr/lib/jvm/graalvm-community-openjdk-21.0.2+13.1/bin/javac
