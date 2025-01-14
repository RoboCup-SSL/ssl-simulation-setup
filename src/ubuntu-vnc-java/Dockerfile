FROM robocupssl/ubuntu-vnc:latest@sha256:7114162376a39db603712c76f5dc6c4f2f82437d42204d2b685937801c04634d

USER root
RUN apt-get update && apt-get install -y openjdk-17-jdk && apt-get clean -y
COPY installGraalVM.sh /temp/installGraalVM.sh
RUN bash /temp/installGraalVM.sh
USER default
