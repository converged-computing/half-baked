# Half Baked LAMMPS

Let's build the half baked image, manually first. This is going to use [llvm-ir-cmake-utils](https://github.com/compor/llvm-ir-cmake-utils).

```bash
docker build -t half-baked-lammps .
```

Eww, what? Who eats lammps?

Note that I see the "LLVM IR Utils" in the cmake configuration:

```console
-- LLVM IR Utils
-- Running check for auto-generated files from make-based build system
-- Generating style headers...
-- Generating package headers...
-- Generating lmpinstalledpkgs.h...
-- The following tools and libraries have been found and configured:
 * Git
 * OpenMP
 * ClangFormat (required version >= 8.0)

-- <<< Build configuration >>>
   Operating System: Linux Ubuntu 22.04
   Build type:       RelWithDebInfo
   Install path:     /usr
   Generator:        Unix Makefiles using /usr/bin/gmake
-- Enabled packages: OPT;REAXFF
-- <<< Compilers and Flags: >>>
-- C++ Compiler:     /usr/bin/clang++
      Type:          Clang
      Version:       14.0.0
      C++ Flags:    -O0 -fPIC -O2 -g -DNDEBUG
      Defines:       LAMMPS_SMALLBIG;LAMMPS_MEMALIGN=64;LAMMPS_OMP_COMPAT=4;LAMMPS_GZIP;LAMMPS_FFMPEG
-- <<< Linker flags: >>>
-- Executable name:  lmp
-- Static library flags:    
-- Configuring done
-- Generating done
-- Build files have been written to: /opt/lammps/build
-- Git Directory: /opt/lammps/.git
-- Generating lmpgitversion.h...
Built target gitversion
```

We will likely want some derivative of this akin to how we did pi (TBA).

```bash
for filename in $(ls *.ll); do
    llc -filetype=obj -O0 --relocation-model=pic --runtime-counter-relocation --relax-elf-relocations  $filename -o $filename.o
done
clang -shared -lstdc++ -lmpi -lmpi_cxx -lm *.o -o lammps.so
cp lammps.so /usr/lib/liblammps.so
```

And for the lmp executable:

```bash
llc -filetype=obj -O0 --relocation-model=pic --runtime-counter-relocation --relax-elf-relocations main.cpp.bc -o lmp.o
cp ../lammps_bc/lammps.so .
clang -lstdc++ -lmpi -lmpi_cxx -lm -llammps lmp.o -o lmp
```

Did it work?

```bash
cp lmp /usr/local/bin/half-baked-lmp
cd /opt/lammps/examples/reaxff/HNS/

half-baked-lmp -v x 2 -v y 2 -v z 2 -in ./in.reaxc.hns -nocite
```

OHMAHGOSH! Half baked lammps! 🤯️

<details>

<summary>Half Baked LAMMPS</summary>

```console
LAMMPS (29 Sep 2021 - Update 2)
Reading data file ...
  triclinic box = (0.0000000 0.0000000 0.0000000) to (22.326000 11.141200 13.778966) with tilt (0.0000000 -5.0260300 0.0000000)
  1 by 1 by 1 MPI processor grid
  reading atoms ...
  304 atoms
  reading velocities ...
  304 velocities
  read_data CPU = 0.001 seconds
Replicating atoms ...
  triclinic box = (0.0000000 0.0000000 0.0000000) to (44.652000 22.282400 27.557932) with tilt (0.0000000 -10.052060 0.0000000)
  1 by 1 by 1 MPI processor grid
  bounding box image = (0 -1 -1) to (0 1 1)
  bounding box extra memory = 0.03 MB
  average # of replicas added to proc = 8.00 out of 8 (100.00%)
  2432 atoms
  replicate CPU = 0.001 seconds
Neighbor list info ...
  update every 20 steps, delay 0 steps, check no
  max neighbors/atom: 2000, page size: 100000
  master list distance cutoff = 11
  ghost atom cutoff = 11
  binsize = 5.5, bins = 10 5 6
  2 neighbor lists, perpetual/occasional/extra = 2 0 0
  (1) pair reax/c, perpetual
      attributes: half, newton off, ghost
      pair build: half/bin/newtoff/ghost
      stencil: full/ghost/bin/3d
      bin: standard
  (2) fix qeq/reax, perpetual, copy from (1)
      attributes: half, newton off, ghost
      pair build: copy
      stencil: none
      bin: none
Setting up Verlet run ...
  Unit style    : real
  Current step  : 0
  Time step     : 0.1
Per MPI rank memory allocation (min/avg/max) = 215.0 | 215.0 | 215.0 Mbytes
Step Temp PotEng Press E_vdwl E_coul Volume 
       0          300   -113.27833    437.52122   -111.57687   -1.7014647    27418.867 
      10    299.38517   -113.27631    1439.2857   -111.57492   -1.7013813    27418.867 
      20    300.27107   -113.27884    3764.3739   -111.57762   -1.7012246    27418.867 
      30    302.21063   -113.28428    7007.6914   -111.58335   -1.7009363    27418.867 
      40    303.52265   -113.28799      9844.84   -111.58747   -1.7005186    27418.867 
      50    301.87059   -113.28324    9663.0443   -111.58318   -1.7000524    27418.867 
      60    296.67807   -113.26777    7273.7928   -111.56815   -1.6996137    27418.867 
      70    292.19999   -113.25435    5533.6428   -111.55514   -1.6992157    27418.867 
      80    293.58677   -113.25831    5993.4151   -111.55946   -1.6988533    27418.867 
      90    300.62636   -113.27925    7202.8651   -111.58069   -1.6985591    27418.867 
     100    305.38276   -113.29357    10085.748   -111.59518   -1.6983875    27418.867 
Loop time of 18.0086 on 1 procs for 100 steps with 2432 atoms

Performance: 0.048 ns/day, 500.240 hours/ns, 5.553 timesteps/s
99.8% CPU use with 1 MPI tasks x no OpenMP threads

MPI task timing breakdown:
Section |  min time  |  avg time  |  max time  |%varavg| %total
---------------------------------------------------------------
Pair    | 12.223     | 12.223     | 12.223     |   0.0 | 67.87
Neigh   | 0.46972    | 0.46972    | 0.46972    |   0.0 |  2.61
Comm    | 0.0088132  | 0.0088132  | 0.0088132  |   0.0 |  0.05
Output  | 0.00048255 | 0.00048255 | 0.00048255 |   0.0 |  0.00
Modify  | 5.3062     | 5.3062     | 5.3062     |   0.0 | 29.46
Other   |            | 0.0008845  |            |       |  0.00

Nlocal:        2432.00 ave        2432 max        2432 min
Histogram: 1 0 0 0 0 0 0 0 0 0
Nghost:        10685.0 ave       10685 max       10685 min
Histogram: 1 0 0 0 0 0 0 0 0 0
Neighs:        823958.0 ave      823958 max      823958 min
Histogram: 1 0 0 0 0 0 0 0 0 0

Total # of neighbors = 823958
Ave neighs/atom = 338.79852
Neighbor list builds = 5
Dangerous builds not checked
Total wall time: 0:00:18
```

</details>

Note that these are the relocation methods. There are a LOT of options for llc (we should look at them together).

```console
--relocation-model=<value>                                            - Choose relocation model
    =static                                                             -   Non-relocatable code
    =pic                                                                -   Fully relocatable, position independent code
    =dynamic-no-pic                                                     -   Relocatable external references, non-relocatable code
    =ropi                                                               -   Code and read-only data relocatable, accessed PC-relative
    =rwpi                                                               -   Read-write data relocatable, accessed relative to static base
    =ropi-rwpi                                                          -   Combination of ropi and rwpi
  --run-pass=<pass-name>                                                - Run compiler only for specified passes (comma separated list)
  --runtime-counter-relocation
```

This is awesome. I can't even right now.