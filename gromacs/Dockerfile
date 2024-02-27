ARG tag=latest
FROM ubuntu:${tag}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y fftw3-dev fftw3 pdsh libfabric-dev libfabric1 \
        dnsutils telnet strace cmake git g++ \
        mpich wget curl unzip vim ffmpeg python3-pip \
        build-essential openssh-server libxml2-dev
        
# llvm https://apt.llvm.org/
RUN /bin/bash -c "wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -" && \
    apt-get update && \
    apt-get install -y clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python3-clang

ENV GROMACS_VERSION=5.1.2
WORKDIR /opt
RUN wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-${GROMACS_VERSION}.tar.gz && \
    tar zxvf gromacs-${GROMACS_VERSION}.tar.gz
COPY ./CMakeLists.txt /opt/gromacs-${GROMACS_VERSION}/CMakeLists.txt
RUN git clone https://github.com/compor/llvm-ir-cmake-utils /tmp/cmake-utils && \
    cd gromacs-${GROMACS_VERSION} && \
    cp /tmp/cmake-utils/cmake/* /opt/gromacs-${GROMACS_VERSION}/cmake && \
    mkdir build && \
    cd build && \
# Note there is an error here for libgromacs
# Attempt to add a custom rule to output
# /opt/gromacs-5.1.2/build/llvm-ir/libgromacs_bc/md5.c.bc.rule
# which already has a custom rule.
    cmake .. -DGMX_BUILD_OWN_FFTW=ON -Wno-dev -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_C_FLAGS="-O0 -fPIC" -DCMAKE_CXX_FLAGS="-O0 -fPIC" -DLINKER_LANGUAGE=C -DCMAKE_CXX_COMPILER=clang -DCMAKE_C_COMPILER=clang && \
    cmake --build . --target gmx_bc libgromacs_bc && \
    cd ./llvm-ir/gmx_bc && \
    llvm-dis ./*.bc 
