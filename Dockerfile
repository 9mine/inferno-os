FROM i386/ubuntu:bionic AS builder

RUN apt-get update && apt-get install -y git build-essential

ADD . /usr/inferno-os
WORKDIR /usr/inferno-os

RUN \
  export PATH=$PATH:/usr/inferno-os/Linux/386/bin                             \
  export MKFLAGS='SYSHOST=Linux OBJTYPE=386 CONF=emu-g ROOT='/usr/inferno-os; \
  /usr/inferno-os/Linux/386/bin/mk $MKFLAGS mkdirs                            && \
  /usr/inferno-os/Linux/386/bin/mk $MKFLAGS emuinstall                        && \
  /usr/inferno-os/Linux/386/bin/mk $MKFLAGS emunuke

FROM i386/ubuntu:bionic AS inferno
ENV ROOT_DIR /usr/inferno-os

COPY --from=builder /usr/inferno-os/Linux/386/bin/emu-g /usr/bin
COPY --from=builder /usr/inferno-os/dis $ROOT_DIR/dis
COPY --from=builder /usr/inferno-os/appl $ROOT_DIR/appl
COPY --from=builder /usr/inferno-os/lib $ROOT_DIR/lib
COPY --from=builder /usr/inferno-os/module $ROOT_DIR/module
COPY --from=builder /usr/inferno-os/usr $ROOT_DIR/usr
RUN apt-get update && apt-get upgrade -y && apt-get install -y traceroute 

RUN mkdir /usr/inferno-os/keydb
RUN mkdir -p /usr/inferno-os/mnt/keys
RUN mkdir -p /usr/inferno-os/usr/root/keyring
RUN touch /usr/inferno-os/keydb/keys
COPY profile /usr/inferno-os/lib/sh/profile
ENTRYPOINT ["emu-g"]

