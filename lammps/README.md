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


## Kubernetes

Let's now create a small cluster and run the flux operator to run a pre-command to compile the IR.
  
```bash
GOOGLE_PROJECT=myproject
gcloud container clusters create test-cluster \
    --threads-per-core=1 \
    --placement-type=COMPACT \
    --num-nodes=5 \
    --region=us-central1-a \
    --project=${GOOGLE_PROJECT} \
    --machine-type=c2d-standard-8

    --network-performance-configs=total-egress-bandwidth-tier=TIER_1 \
    --enable-gvnic \
    --network=mtu9k
```

## Flux Operator

When the cluster is ready, install the Flux Operator from the development branch.

```bash
kubectl apply -f https://raw.githubusercontent.com/flux-framework/flux-operator/test-refactor-modular/examples/dist/flux-operator-refactor.yaml
```

You can check logs to ensure it is also running, in the `operator-system` namespace.
We can use the deployed container [here](https://github.com/converged-computing/half-baked/pkgs/container/half-baked/181494855?tag=lammps-test-feb-20-2024).
Now run the minicluster. If you set interactive to true you can shell in to poke around.

```bash
kubectl apply -f minicluster.yaml
```

Wait for it to be running:

```
$ kubectl get pods
NAME                        READY   STATUS     RESTARTS   AGE
half-baked-lammps-0-jtj2w   0/1     Init:0/1   0          16s
half-baked-lammps-1-vk6jp   0/1     Init:0/1   0          16s
half-baked-lammps-2-62gfk   0/1     Init:0/1   0          15s
half-baked-lammps-3-lkhvw   0/1     Init:0/1   0          15s
```

Note that the pre block will finish the compile and give you the total time to do that. The main command is then to run the "half-baked-lmp." Here is what the log looks like:

<details>

<summary>Half-baked-lammps on Kubernetes</sunmmary>

```console
Defaulted container "half-baked-lammps" out of: half-baked-lammps, flux-view (init)
TIME_COMPILE_SECONDS=33
LAMMPS (29 Sep 2021 - Update 2)
Reading data file ...
  triclinic box = (0.0000000 0.0000000 0.0000000) to (22.326000 11.141200 13.778966) with tilt (0.0000000 -5.0260300 0.0000000)
  1 by 1 by 1 MPI processor grid
  reading atoms ...
  304 atoms
  reading velocities ...
  304 velocities
  read_data CPU = 0.002 seconds
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
Loop time of 32.3562 on 1 procs for 100 steps with 2432 atoms

Performance: 0.027 ns/day, 898.784 hours/ns, 3.091 timesteps/s
100.0% CPU use with 1 MPI tasks x no OpenMP threads

MPI task timing breakdown:
Section |  min time  |  avg time  |  max time  |%varavg| %total
---------------------------------------------------------------
Pair    | 21.687     | 21.687     | 21.687     |   0.0 | 67.02
Neigh   | 0.72119    | 0.72119    | 0.72119    |   0.0 |  2.23
Comm    | 0.020438   | 0.020438   | 0.020438   |   0.0 |  0.06
Output  | 0.00055216 | 0.00055216 | 0.00055216 |   0.0 |  0.00
Modify  | 9.9263     | 9.9263     | 9.9263     |   0.0 | 30.68
Other   |            | 0.001177   |            |       |  0.00

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
Total wall time: 0:00:33
```

</details>

In the above, the extra compile time was 33 seconds, which (in retrospect) is a lot. The job is also about 30 seconds. You can thus imagine an experiment to try doing this on different node types, and comparing the total run time (to finish compiling) with the runtime of lammps, as compared to "if we didn't do anything case" (which we haven't defined yet). Here is what we see in the logs:

## Experiment Planning

### Prep Work

- **Prepare a base case** We likely want to build the "base case" that will have one LAMMPS time for comparison (without any pre-baked prep)
- **Choose nodes / instance architectures** We then want to chose some number of nodes to deploy to a GKE cluster. If it's annoying, it might make sense to just deploy N different clusters, and run some number of iterations for each with the setup. LAMMPS needs >1 node anyway, and we don't care about performance of LAMMPS, just relative times.

### Procedure 

Here is my idea for the experiment:

1. For each of the base case and instance architecture (list):
  1. Bring up a cluster of size N.
  1. Run M iterations of the half baked setup. The log should have the time for LAMMPS and the compile time
1. Parse results and compare the overall times - what is the tradeoff between the optimization and speedup from it?

We are going to need to be careful about instances / sizes because of GCP networking (which isn't very good) we might not have reasonably running lammps times. If this first run works OK, we can likely do one or two more apps and then write up the small study, probably to present the idea somewhere for fun.

### Clean Up

When you are done:

```bash
gcloud container clusters delete test-cluster --region=us-central1-a
```
