FROM ubuntu:focal AS builder
WORKDIR /usr
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y git build-essential libc6-dev-i386 curl ca-certificates 
WORKDIR /usr/
ADD . /usr/inferno-os
ENV INFERNO_BRANCH=master
ENV INFERNO_COMMIT=ed97654bd7a11d480b44505c8300d06b42e5fefe
  
#RUN git clone --depth 1 -b ${INFERNO_BRANCH} https://bitbucket.org/inferno-os/inferno-os 
WORKDIR /usr/inferno-os
RUN export PATH=$PATH:/usr/inferno-os/Linux/386/bin &&\
    export MKFLAGS='SYSHOST=Linux OBJTYPE=386 CONF=emu-g ROOT='/usr/inferno-os &&\
    . ./mkconfig &&\
    ./makemk.sh &&\
    mk $MKFLAGS mkdirs         &&\
    mk $MKFLAGS emuinstall     &&\                
    mk $MKFLAGS emunuke        

#ENV EXPORT_PATH /host/execfuse-fs
#ENV EXPORT_PORT 1917

FROM ubuntu:focal

RUN apt-get update && apt-get install -y \
  libc6-dev-i386    
ENV ROOT_DIR /usr/inferno-os
COPY --from=builder ${ROOT_DIR}/Linux/386/bin/emu-g /usr/bin
COPY --from=builder ${ROOT_DIR}/dis $ROOT_DIR/dis
COPY --from=builder ${ROOT_DIR}/appl $ROOT_DIR/appl
COPY --from=builder ${ROOT_DIR}/lib $ROOT_DIR/lib
COPY --from=builder ${ROOT_DIR}/module $ROOT_DIR/module
COPY --from=builder ${ROOT_DIR}/usr $ROOT_DIR/usr


ENTRYPOINT ["emu-g"]
