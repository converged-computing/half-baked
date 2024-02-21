# Half Baked LAMMPS

Let's build the half baked image, manually first. This is going to use [llvm-ir-cmake-utils](https://github.com/compor/llvm-ir-cmake-utils).

```bash
docker build -t half-baked-lammps .
```

Eww, what? Who eats lammps?

Note that I see the "LLVM IR Utils" in the cmake configuration:

```console
-- <<< Build configuration >>>
   Operating System: Linux Ubuntu 22.04
   Build type:       RelWithDebInfo
   Install path:     /usr
   Generator:        Unix Makefiles using /usr/bin/gmake
-- Enabled packages: OPT;REAXFF
-- <<< Compilers and Flags: >>>
-- C++ Compiler:     /usr/bin/c++
      Type:          GNU
      Version:       11.4.0
      C++ Flags:     -O2 -g -DNDEBUG
      Defines:       LAMMPS_SMALLBIG;LAMMPS_MEMALIGN=64;LAMMPS_OMP_COMPAT=4;LAMMPS_GZIP;LAMMPS_FFMPEG
-- <<< Linker flags: >>>
-- Executable name:  lmp
-- Static library flags:    
-- <<< MPI flags >>>
-- MPI_defines:      MPICH_SKIP_MPICXX;OMPI_SKIP_MPICXX;_MPICC_H
-- MPI includes:     /usr/include/x86_64-linux-gnu/mpich
-- MPI libraries:    /usr/lib/x86_64-linux-gnu/libmpichcxx.so;/usr/lib/x86_64-linux-gnu/libmpich.so;
-- LLVM IR Utils
-- Configuring done
-- Generating done
```

We will likely want some derivative of this akin to how we did pi (TBA).

```bash
llc -filetype=obj pthreadTimed.ll -o half-baked.o
clang -lm half-baked.o -o half-baked
```
