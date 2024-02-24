ARG tag=latest
FROM ubuntu:${tag}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y fftw3-dev fftw3 pdsh libfabric-dev libfabric1 \
        dnsutils telnet strace cmake git g++ \
        wget curl unzip vim ffmpeg python3-pip

# llvm https://apt.llvm.org/
RUN /bin/bash -c "wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -" && \
    apt-get update && \
    apt-get install -y clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python3-clang

# Install MPI from source
WORKDIR /opt/
RUN wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.2.tar.gz && \
    tar -xzvf openmpi-4.1.2.tar.gz && \
    cd openmpi-4.1.2 && \
    ./configure --prefix=/usr --enable-mpi-cxx && \
    make && make install

# These are the changes we made to the CMakeLists.txt, here.
# This after modules (this line)
# include(LAMMPSUtils)
# include(LLVMIRUtil)
# Add these to end
# SET_TARGET_PROPERTIES(lammps PROPERTIES LINKER_LANGUAGE CXX)
# SET_TARGET_PROPERTIES(lmp PROPERTIES LINKER_LANGUAGE CXX)
# llvmir_attach_bc_target(lammps_bc lammps)
# llvmir_attach_bc_target(lmp_bc lmp)
  
# install laamps and enable IR with add_compile_options(-emit-llvm) in the CMakeLists.txt
# -O1 -Xclang -disable-llvm-passes
RUN python3 -m pip install clang-format
RUN git clone --depth 1 --branch stable_29Sep2021_update2 https://github.com/lammps/lammps.git /opt/lammps

# This is "baked lammps" built on the original machine
RUN cd /opt/lammps && \
    mkdir build && \
    cd build && \
    . /etc/profile && \ 
    cmake ../cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DPKG_REAXFF=yes -DBUILD_MPI=yes -DPKG_OPT=yes -DFFT=FFTW3 -DCMAKE_C_FLAGS="-O0 -fPIC -g -DNDEBUG" -DCMAKE_CXX_FLAGS="-O0 -fPIC -g -DNDEBUG" -DCMAKE_PREFIX_PATH=/usr/lib/mpich -DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu && \
    make && mv ./lmp /usr/local/bin/baked-lmp

RUN rm -rf /opt/lammps && \
    git clone --depth 1 --branch stable_29Sep2021_update2 https://github.com/lammps/lammps.git /opt/lammps

# This adds the llvm ir cmake modules
COPY ./CMakeLists.txt /opt/lammps/cmake/CMakeLists.txt

# This disables default -O2 optimization
COPY ./gcc.cmake /opt/lammps/cmake/presets/gcc.cmake
RUN cd /opt/lammps && \
    mkdir build && \
    cd build && \
    . /etc/profile && \ 
    git clone https://github.com/compor/llvm-ir-cmake-utils /tmp/cmake-utils && \
    cp /tmp/cmake-utils/cmake/* /opt/lammps/cmake/Modules && \
    cmake ../cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_C_FLAGS="-O0 -fPIC -g -DNDEBUG" -DCMAKE_CXX_FLAGS="-O0 -fPIC -g -DNDEBUG" -DPKG_REAXFF=yes -DBUILD_MPI=yes -DPKG_OPT=yes -DFFT=FFTW3 -DCMAKE_PREFIX_PATH=/usr/lib/mpich -DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu -DLINKER_LANGUAGE=CXX -DCMAKE_CXX_COMPILER=clang++ && \
    cmake --build . --target gitversion && \
    cmake --build . --target lmp_bc lammps_bc && \
    cd ./llvm-ir/lmp_bc && \
    llvm-dis ./main.cpp.bc && \
    cd ../lammps_bc && \
    llvm-dis ./*.bc 

# To finish this build see instructions in the README.
# 1. The lammps.so needs to be built first
# 2. Then the lmp executable, linking to it
WORKDIR /opt/lammps/build/llvm-ir
COPY ./test-options.sh ./test-options.sh
