FROM ubuntu:22.04

RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install \
    build-essential \
    git \
    clang \
    llvm

# https://lists.llvm.org/pipermail/llvm-dev/2014-September/076375.html
RUN git clone https://github.com/ishanthilina/Pthreads-Monte-Carlo-Pi-Calculation /opt/code
WORKDIR /opt/code

# This generates <filename>.ll
# Original compile might be: gcc -Wall -g -O0 serial.c -lm
RUN clang serial.c -S -emit-llvm && \
    clang pthreadTimed.c -S -emit-llvm && \
    clang pthread.c -S -emit-llvm && \
    # Compile them for comparison
    gcc -Wall -g -O0 pthreadTimed.c -lm -o pthreadTimed && \
    gcc -Wall -g -O0 serial.c -lm -o serial && \
    gcc -Wall -g -O0 pthread.c -lm -o pthread
    
# Later we will finish like: https://borretti.me/article/compiling-llvm-ir-binary
