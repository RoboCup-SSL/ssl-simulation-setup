FROM ubuntu:20.04

ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    SSH_PORT=22
EXPOSE $VNC_PORT $NO_VNC_PORT $SSH_PORT

ENV HOME=/home/default \
    TERM=xterm \
    DOCKER_DIR=/docker \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword

RUN useradd -ms /bin/bash default

WORKDIR $HOME

ADD setup.sh $DOCKER_DIR/
RUN /bin/bash $DOCKER_DIR/setup.sh

ADD startup.sh $DOCKER_DIR/

USER default

ENTRYPOINT ["/docker/startup.sh"]
