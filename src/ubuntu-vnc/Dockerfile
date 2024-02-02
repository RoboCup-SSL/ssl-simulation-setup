FROM ubuntu:22.04

ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    SSH_PORT=2222
EXPOSE $VNC_PORT $NO_VNC_PORT $SSH_PORT

ENV HOME=/home/default \
    TERM=xterm \
    DOCKER_DIR=/docker \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword

COPY setup.sh $DOCKER_DIR/
RUN /bin/bash $DOCKER_DIR/setup.sh
COPY Xvnc-session /etc/X11/Xvnc-session
RUN chmod 755 /etc/X11/Xvnc-session
COPY startup.sh $DOCKER_DIR/
COPY sshd_config /etc/ssh/sshd_config

RUN useradd -ms /bin/bash default
WORKDIR $HOME
USER default
COPY --chown=default:default .icewm $HOME/.icewm/

ENTRYPOINT ["/docker/startup.sh"]
