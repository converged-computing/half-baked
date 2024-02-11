FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y git cmake build-essential \
    lsb-release wget software-properties-common gnupg
RUN add-apt-repository 'deb http://apt.llvm.org/jammy/  llvm-toolchain-jammy-16 main' && \
    wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 16
RUN apt-get install -y python3 python3-pip python3-setuptools \
      python3-wheel ninja-build && \
      pip3 install meson
RUN git clone https://github.com/aengelke/rellume /opt/rellume
WORKDIR /opt/rellume
RUN meson setup builddir && cd builddir && meson compile # meson test
