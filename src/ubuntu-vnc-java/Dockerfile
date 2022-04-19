FROM robocupssl/ubuntu-vnc:latest

USER root
RUN apt-get update && apt-get install -y openjdk-17-jdk && apt-get clean -y
COPY installGraalVM.sh /temp/installGraalVM.sh
RUN bash /temp/installGraalVM.sh
USER default
