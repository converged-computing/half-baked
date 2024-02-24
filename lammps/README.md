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
-- Generating lmpgitversion.h...
Built target gitversion
```

Shell in to test:

```bash
docker run -it half-baked-lammps
```

### basic options

First, here is what works for a basic build:

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

### explore options

Notably, there are a lot of options to explore.

```bash
llc --help

# or this is more readable, but you need to have the man pages unpacked / installed
man llc
```

<details>

<summary>llc options</summary>

```console
OVERVIEW: llvm system compiler

USAGE: llc [options] <input bitcode>

OPTIONS:

Color Options:

  --color                                                               - Use colors in output (default=autodetect)

General options:

  -I=<string>                                                           - include search path
  -O=<char>                                                             - Optimization level. [-O0, -O1, -O2, or -O3] (default = '-O2')
  --aarch64-neon-syntax=<value>                                         - Choose style of NEON code to emit from AArch64 backend:
    =generic                                                            -   Emit generic NEON assembly
    =apple                                                              -   Emit Apple-style NEON assembly
  --aarch64-use-aa                                                      - Enable the use of AA during codegen.
  --abort-on-max-devirt-iterations-reached                              - Abort when the max iterations for devirtualization CGSCC repeat pass is reached
  --addrsig                                                             - Emit an address-significance table
  --align-loops=<uint>                                                  - Default alignment for loops
  --allow-ginsert-as-artifact                                           - Allow G_INSERT to be considered an artifact. Hack around AMDGPU test infinite loops.
  --amdgpu-bypass-slow-div                                              - Skip 64-bit divide for dynamic 32-bit values
  --amdgpu-disable-loop-alignment                                       - Do not align and prefetch loops
  --amdgpu-disable-power-sched                                          - Disable scheduling to minimize mAI power bursts
  --amdgpu-dpp-combine                                                  - Enable DPP combiner
  --amdgpu-dump-hsa-metadata                                            - Dump AMDGPU HSA Metadata
  --amdgpu-enable-flat-scratch                                          - Use flat scratch instructions
  --amdgpu-enable-merge-m0                                              - Merge and hoist M0 initializations
  --amdgpu-promote-alloca-to-vector-limit=<uint>                        - Maximum byte size to consider promote alloca to vector
  --amdgpu-sdwa-peephole                                                - Enable SDWA peepholer
  --amdgpu-use-aa-in-codegen                                            - Enable the use of AA during codegen.
  --amdgpu-verify-hsa-metadata                                          - Verify AMDGPU HSA Metadata
  --amdgpu-vgpr-index-mode                                              - Use GPR indexing mode instead of movrel for vector indexing
  --arm-add-build-attributes                                            - 
  --arm-implicit-it=<value>                                             - Allow conditional instructions outdside of an IT block
    =always                                                             -   Accept in both ISAs, emit implicit ITs in Thumb
    =never                                                              -   Warn in ARM, reject in Thumb
    =arm                                                                -   Accept in ARM, reject in Thumb
    =thumb                                                              -   Warn in ARM, emit implicit ITs in Thumb
  --asm-show-inst                                                       - Emit internal instruction representation to assembly file
  --asm-verbose                                                         - Add comments to directives.
  --atomic-counter-update-promoted                                      - Do counter update using atomic fetch add  for promoted counters only
  --atomic-first-counter                                                - Use atomic fetch add for first counter in a function (usually the entry counter)
  --basic-block-sections=<all | <function list (file)> | labels | none> - Emit basic blocks into separate sections
  --bounds-checking-single-trap                                         - Use one trap block per function
  --cfg-hide-cold-paths=<number>                                        - Hide blocks with relative frequency below the given value
  --cfg-hide-deoptimize-paths                                           - 
  --cfg-hide-unreachable-paths                                          - 
  --code-model=<value>                                                  - Choose code model
    =tiny                                                               -   Tiny code model
    =small                                                              -   Small code model
    =kernel                                                             -   Kernel code model
    =medium                                                             -   Medium code model
    =large                                                              -   Large code model
  --cost-kind=<value>                                                   - Target cost kind
    =throughput                                                         -   Reciprocal throughput
    =latency                                                            -   Instruction latency
    =code-size                                                          -   Code size
    =size-latency                                                       -   Code size and latency
  --data-sections                                                       - Emit data into separate sections
  --debug-entry-values                                                  - Enable debug info for the debug entry values.
  --debug-info-correlate                                                - Use debug info to correlate profiles.
  --debugger-tune=<value>                                               - Tune debug info for a particular debugger
    =gdb                                                                -   gdb
    =lldb                                                               -   lldb
    =dbx                                                                -   dbx
    =sce                                                                -   SCE targets (e.g. PS4)
  --debugify-level=<value>                                              - Kind of debug info to add
    =locations                                                          -   Locations only
    =location+variables                                                 -   Locations and Variables
  --debugify-quiet                                                      - Suppress verbose debugify output
  --denormal-fp-math=<value>                                            - Select which denormal numbers the code is permitted to require
    =ieee                                                               -   IEEE 754 denormal numbers
    =preserve-sign                                                      -   the sign of a  flushed-to-zero number is preserved in the sign of 0
    =positive-zero                                                      -   denormals are flushed to positive zero
  --denormal-fp-math-f32=<value>                                        - Select which denormal numbers the code is permitted to require for float
    =ieee                                                               -   IEEE 754 denormal numbers
    =preserve-sign                                                      -   the sign of a  flushed-to-zero number is preserved in the sign of 0
    =positive-zero                                                      -   denormals are flushed to positive zero
  --disable-i2p-p2i-opt                                                 - Disables inttoptr/ptrtoint roundtrip optimization
  --disable-promote-alloca-to-lds                                       - Disable promote alloca to LDS
  --disable-promote-alloca-to-vector                                    - Disable promote alloca to vector
  --disable-simplify-libcalls                                           - Disable simplify-libcalls
  --disable-tail-calls                                                  - Never emit tail calls
  --do-counter-promotion                                                - Do counter register promotion
  --dot-cfg-mssa=<file name for generated dot file>                     - file name for generated dot file
  --dwarf-version=<int>                                                 - Dwarf version
  --dwarf64                                                             - Generate debugging info in the 64-bit DWARF format
  --emit-call-site-info                                                 - Emit call site debug information, if debug information is enabled.
  --emscripten-cxx-exceptions-allowed=<string>                          - The list of function names in which Emscripten-style exception handling is enabled (see emscripten EMSCRIPTEN_CATCHING_ALLOWED options)
  --emulated-tls                                                        - Use emulated TLS model
  --enable-cse-in-irtranslator                                          - Should enable CSE in irtranslator
  --enable-cse-in-legalizer                                             - Should enable CSE in Legalizer
  --enable-emscripten-cxx-exceptions                                    - WebAssembly Emscripten-style exception handling
  --enable-emscripten-sjlj                                              - WebAssembly Emscripten-style setjmp/longjmp handling
  --enable-gvn-hoist                                                    - Enable the GVN hoisting pass (default = off)
  --enable-gvn-memdep                                                   - 
  --enable-gvn-sink                                                     - Enable the GVN sinking pass (default = off)
  --enable-load-in-loop-pre                                             - 
  --enable-load-pre                                                     - 
  --enable-loop-simplifycfg-term-folding                                - 
  --enable-name-compression                                             - Enable name/filename string compression
  --enable-no-infs-fp-math                                              - Enable FP math optimizations that assume no +-Infs
  --enable-no-nans-fp-math                                              - Enable FP math optimizations that assume no NaNs
  --enable-no-signed-zeros-fp-math                                      - Enable FP math optimizations that assume the sign of 0 is insignificant
  --enable-no-trapping-fp-math                                          - Enable setting the FP exceptions build attribute not to use exceptions
  --enable-split-backedge-in-load-pre                                   - 
  --enable-unsafe-fp-math                                               - Enable optimizations that may decrease FP precision
  --exception-model=<value>                                             - exception model
    =default                                                            -   default exception handling model
    =dwarf                                                              -   DWARF-like CFI based exception handling
    =sjlj                                                               -   SjLj exception handling
    =arm                                                                -   ARM EHABI exceptions
    =wineh                                                              -   Windows exception model
    =wasm                                                               -   WebAssembly exception handling
  --experimental-debug-variable-locations                               - Use experimental new value-tracking variable locations
  --fatal-warnings                                                      - Treat warnings as errors
  --filetype=<value>                                                    - Choose a file type (not all types are supported by all targets):
    =asm                                                                -   Emit an assembly ('.s') file
    =obj                                                                -   Emit a native object ('.o') file
    =null                                                               -   Emit nothing, for performance testing
  --float-abi=<value>                                                   - Choose float ABI type
    =default                                                            -   Target default float ABI type
    =soft                                                               -   Soft float ABI (implied by -soft-float)
    =hard                                                               -   Hard float ABI (uses FP registers)
  --force-dwarf-frame-section                                           - Always emit a debug frame section.
  --fp-contract=<value>                                                 - Enable aggressive formation of fused FP ops
    =fast                                                               -   Fuse FP ops whenever profitable
    =on                                                                 -   Only fuse 'blessed' FP ops.
    =off                                                                -   Only fuse FP ops when the result won't be affected.
  --frame-pointer=<value>                                               - Specify frame pointer elimination optimization
    =all                                                                -   Disable frame pointer elimination
    =non-leaf                                                           -   Disable frame pointer elimination for non-leaf frame
    =none                                                               -   Enable frame pointer elimination
  --fs-profile-debug-bw-threshold=<uint>                                - Only show debug message if the source branch weight is greater  than this value.
  --fs-profile-debug-prob-diff-threshold=<uint>                         - Only show debug message if the branch probility is greater than this value (in percentage).
  --function-sections                                                   - Emit functions into separate sections
  --generate-merged-base-profiles                                       - When generating nested context-sensitive profiles, always generate extra base profile for function with all its context profiles merged into it.
  --gpsize=<uint>                                                       - Global Pointer Addressing Size.  The default size is 8.
  --hash-based-counter-split                                            - Rename counter variable of a comdat function based on cfg hash
  --hot-cold-split                                                      - Enable hot-cold splitting pass
  --ignore-xcoff-visibility                                             - Not emit the visibility attribute for asm in AIX OS or give all symbols 'unspecified' visibility in XCOFF object file
  --import-all-index                                                    - Import all external functions in index.
  --incremental-linker-compatible                                       - When used with filetype=obj, emit an object file which can be used with an incremental linker
  --instcombine-code-sinking                                            - Enable code sinking
  --instcombine-guard-widening-window=<uint>                            - How wide an instruction window to bypass looking for another guard
  --instcombine-max-iterations=<uint>                                   - Limit the maximum number of instruction combining iterations
  --instcombine-max-num-phis=<uint>                                     - Maximum number phis to handle in intptr/ptrint folding
  --instcombine-maxarray-size=<uint>                                    - Maximum array size considered when doing a combine
  --instcombine-negator-enabled                                         - Should we attempt to sink negations?
  --instcombine-negator-max-depth=<uint>                                - What is the maximal lookup depth when trying to check for viability of negation sinking.
  --instrprof-atomic-counter-update-all                                 - Make all profile counter updates atomic (for testing only)
  --internalize-public-api-file=<filename>                              - A file containing list of symbol names to preserve
  --internalize-public-api-list=<list>                                  - A list of symbol names to preserve
  --iterative-counter-promotion                                         - Allow counter promotion across the whole loop nest.
  --load=<pluginfilename>                                               - Load the specified plugin
  --lto-embed-bitcode=<value>                                           - Embed LLVM bitcode in object files produced by LTO
    =none                                                               -   Do not embed
    =optimized                                                          -   Embed after all optimization passes
    =post-merge-pre-opt                                                 -   Embed post merge, but before optimizations
  --lto-pass-remarks-filter=<regex>                                     - Only record optimization remarks from passes whose names match the given regular expression
  --lto-pass-remarks-format=<format>                                    - The format used for serializing remarks (default: YAML)
  --lto-pass-remarks-output=<filename>                                  - Output filename for pass remarks
  --march=<string>                                                      - Architecture to generate code for (see --version)
  --matrix-default-layout=<value>                                       - Sets the default matrix layout
    =column-major                                                       -   Use column-major layout
    =row-major                                                          -   Use row-major layout
  --mattr=<a1,+a2,-a3,...>                                              - Target specific attributes (-mattr=help for details)
  --max-counter-promotions=<int>                                        - Max number of allowed counter promotions
  --max-counter-promotions-per-loop=<uint>                              - Max number counter promotions per loop to avoid increasing register pressure too much
  --mc-relax-all                                                        - When used with filetype=obj, relax all fixups in the emitted object file
  --mcabac                                                              - tbd
  --mcpu=<cpu-name>                                                     - Target a specific cpu type (-mcpu=help for details)
  --meabi=<value>                                                       - Set EABI type (default depends on triple):
    =default                                                            -   Triple default EABI version
    =4                                                                  -   EABI version 4
    =5                                                                  -   EABI version 5
    =gnu                                                                -   EABI GNU
  --merror-missing-parenthesis                                          - Error for missing parenthesis around predicate registers
  --merror-noncontigious-register                                       - Error for register names that aren't contigious
  --mhvx                                                                - Enable Hexagon Vector eXtensions
  --mhvx=<value>                                                        - Enable Hexagon Vector eXtensions
    =v60                                                                -   Build for HVX v60
    =v62                                                                -   Build for HVX v62
    =v65                                                                -   Build for HVX v65
    =v66                                                                -   Build for HVX v66
    =v67                                                                -   Build for HVX v67
    =v68                                                                -   Build for HVX v68
    =v69                                                                -   Build for HVX v69
  --mips-compact-branches=<value>                                       - MIPS Specific: Compact branch policy.
    =never                                                              -   Do not use compact branches if possible.
    =optimal                                                            -   Use compact branches where appropriate (default).
    =always                                                             -   Always use compact branches if possible.
  --mips16-constant-islands                                             - Enable mips16 constant islands.
  --mips16-hard-float                                                   - Enable mips16 hard float.
  --mir-strip-debugify-only                                             - Should mir-strip-debug only strip debug info from debugified modules by default
  --mno-compound                                                        - Disable looking for compound instructions for Hexagon
  --mno-fixup                                                           - Disable fixing up resolved relocations for Hexagon
  --mno-ldc1-sdc1                                                       - Expand double precision loads and stores to their single precision counterparts
  --mno-pairing                                                         - Disable looking for duplex instructions for Hexagon
  --mtriple=<string>                                                    - Override target triple for module
  --mwarn-missing-parenthesis                                           - Warn for missing parenthesis around predicate registers
  --mwarn-noncontigious-register                                        - Warn for register names that arent contigious
  --mwarn-sign-mismatch                                                 - Warn for mismatching a signed and unsigned value
  --no-deprecated-warn                                                  - Suppress all deprecated warnings
  --no-discriminators                                                   - Disable generation of discriminator information.
  --no-type-check                                                       - Suppress type errors (Wasm)
  --no-warn                                                             - Suppress all warnings
  --no-xray-index                                                       - Don't emit xray_fn_idx section
  --nozero-initialized-in-bss                                           - Don't place zero-initialized symbols into bss section
  --nvptx-sched4reg                                                     - NVPTX Specific: schedule for register pressue
  -o=<filename>                                                         - Output filename
  --opaque-pointers                                                     - Use opaque pointers
  --pass-remarks-filter=<regex>                                         - Only record optimization remarks from passes whose names match the given regular expression
  --pass-remarks-format=<format>                                        - The format used for serializing remarks (default: YAML)
  --pass-remarks-output=<filename>                                      - Output filename for pass remarks
  --poison-checking-function-local                                      - Check that returns are non-poison (for testing)
  --print-pipeline-passes                                               - Print a '-passes' compatible string describing the pipeline (best-effort only).
  --r600-ir-structurize                                                 - Use StructurizeCFG IR pass
  --rdf-dump                                                            - 
  --rdf-limit=<uint>                                                    - 
  --relax-elf-relocations                                               - Emit GOTPCRELX/REX_GOTPCRELX instead of GOTPCREL on x86-64 ELF
  --relocation-model=<value>                                            - Choose relocation model
    =static                                                             -   Non-relocatable code
    =pic                                                                -   Fully relocatable, position independent code
    =dynamic-no-pic                                                     -   Relocatable external references, non-relocatable code
    =ropi                                                               -   Code and read-only data relocatable, accessed PC-relative
    =rwpi                                                               -   Read-write data relocatable, accessed relative to static base
    =ropi-rwpi                                                          -   Combination of ropi and rwpi
  --run-pass=<pass-name>                                                - Run compiler only for specified passes (comma separated list)
  --runtime-counter-relocation                                          - Enable relocating counters at runtime.
  --safepoint-ir-verifier-print-only                                    - 
  --sample-profile-check-record-coverage=<N>                            - Emit a warning if less than N% of records in the input profile are matched to the IR.
  --sample-profile-check-sample-coverage=<N>                            - Emit a warning if less than N% of samples in the input profile are matched to the IR.
  --sample-profile-max-propagate-iterations=<uint>                      - Maximum number of iterations to go through when propagating sample block/edge weights through the CFG.
  --skip-ret-exit-block                                                 - Suppress counter promotion if exit blocks contain ret.
  --speculative-counter-promotion-max-exiting=<uint>                    - The max number of exiting blocks of a loop to allow  speculative counter promotion
  --speculative-counter-promotion-to-loop                               - When the option is false, if the target block is in a loop, the promotion will be disallowed unless the promoted counter  update can be further/iteratively promoted into an acyclic  region.
  --split-dwarf-file=<string>                                           - Specify the name of the .dwo file to encode in the DWARF output
  --split-dwarf-output=<filename>                                       - .dwo output filename
  --split-machine-functions                                             - Split out cold basic blocks from machine functions based on profile information
  --stack-size-section                                                  - Emit a section containing stack size metadata
  --stack-symbol-ordering                                               - Order local stack symbols.
  --stackrealign                                                        - Force align the stack to the minimum alignment
  --strict-dwarf                                                        - use strict dwarf
  --summary-file=<string>                                               - The summary file to use for function importing.
  --swift-async-fp=<value>                                              - Determine when the Swift async frame pointer should be set
    =auto                                                               -   Determine based on deployment target
    =always                                                             -   Always set the bit
    =never                                                              -   Never set the bit
  --tail-predication=<value>                                            - MVE tail-predication pass options
    =disabled                                                           -   Don't tail-predicate loops
    =enabled-no-reductions                                              -   Enable tail-predication, but not for reduction loops
    =enabled                                                            -   Enable tail-predication, including reduction loops
    =force-enabled-no-reductions                                        -   Enable tail-predication, but not for reduction loops, and force this which might be unsafe
    =force-enabled                                                      -   Enable tail-predication, including reduction loops, and force this which might be unsafe
  --tailcallopt                                                         - Turn fastcc calls into tail calls by (potentially) changing ABI.
  --thinlto-assume-merged                                               - Assume the input has already undergone ThinLTO function importing and the other pre-optimization pipeline changes.
  --thread-model=<value>                                                - Choose threading model
    =posix                                                              -   POSIX thread model
    =single                                                             -   Single thread model
  --threads=<int>                                                       - 
  --time-trace                                                          - Record time trace
  --time-trace-file=<filename>                                          - Specify time trace file destination
  --tls-size=<uint>                                                     - Bit size of immediate TLS offsets
  --unique-basic-block-section-names                                    - Give unique names to every basic block section
  --unique-section-names                                                - Give unique names to every section
  --use-ctors                                                           - Use .ctors instead of .init_array.
  --vec-extabi                                                          - Enable the AIX Extended Altivec ABI.
  --verify-region-info                                                  - Verify region info (time consuming)
  --vp-counters-per-site=<number>                                       - The average number of profile counters allocated per value profiling site.
  --vp-static-alloc                                                     - Do static counter allocation for value profiler
  --wasm-enable-eh                                                      - WebAssembly exception handling
  --wasm-enable-sjlj                                                    - WebAssembly setjmp/longjmp handling
  -x=<string>                                                           - Input language ('ir' or 'mir')
  --x86-align-branch=<string>                                           - Specify types of branches to align (plus separated list of types):
                                                                          jcc      indicates conditional jumps
                                                                          fused    indicates fused conditional jumps
                                                                          jmp      indicates direct unconditional jumps
                                                                          call     indicates direct and indirect calls
                                                                          ret      indicates rets
                                                                          indirect indicates indirect unconditional jumps
  --x86-align-branch-boundary=<uint>                                    - Control how the assembler should align branches with NOP. If the boundary's size is not 0, it should be a power of 2 and no less than 32. Branches will be aligned to prevent from being across or against the boundary of specified size. The default value 0 does not align branches.
  --x86-branches-within-32B-boundaries                                  - Align selected instructions to mitigate negative performance impact of Intel's micro code update for errata skx102.  May break assumptions about labels corresponding to particular instructions, and should be used with caution.
  --x86-pad-max-prefix-size=<uint>                                      - Maximum number of prefixes to use for padding
  --xcoff-traceback-table                                               - Emit the XCOFF traceback table

Generic Options:

  --help                                                                - Display available options (--help-hidden for more)
  --help-list                                                           - Display list of available options (--help-list-hidden for more)
  --version                                                             - Display the version of this program

Polly Options:
Configure the polly loop optimizer

  --polly                                                               - Enable the polly optimizer (with -O1, -O2 or -O3)
  --polly-2nd-level-tiling                                              - Enable a 2nd level loop of loop tiling
  --polly-ast-print-accesses                                            - Print memory access functions
  --polly-context=<isl parameter set>                                   - Provide additional constraints on the context parameters
  --polly-dce-precise-steps=<int>                                       - The number of precise steps between two approximating iterations. (A value of -1 schedules another approximation stage before the actual dead code elimination.
  --polly-delicm-max-ops=<int>                                          - Maximum number of isl operations to invest for lifetime analysis; 0=no limit
  --polly-detect-full-functions                                         - Allow the detection of full functions
  --polly-dump-after                                                    - Dump module after Polly transformations into a file suffixed with "-after"
  --polly-dump-after-file=<string>                                      - Dump module after Polly transformations to the given file
  --polly-dump-before                                                   - Dump module before Polly transformations into a file suffixed with "-before"
  --polly-dump-before-file=<string>                                     - Dump module before Polly transformations to the given file
  --polly-enable-simplify                                               - Simplify SCoP after optimizations
  --polly-ignore-func=<string>                                          - Ignore functions that match a regex. Multiple regexes can be comma separated. Scop detection will ignore all functions that match ANY of the regexes provided.
  --polly-isl-arg=<argument>                                            - Option passed to ISL
  --polly-on-isl-error-abort                                            - Abort if an isl error is encountered
  --polly-only-func=<string>                                            - Only run on functions that match a regex. Multiple regexes can be comma separated. Scop detection will run on all functions that match ANY of the regexes provided.
  --polly-only-region=<identifier>                                      - Only run on certain regions (The provided identifier must appear in the name of the region's entry block
  --polly-only-scop-detection                                           - Only run scop detection, but no other optimizations
  --polly-optimized-scops                                               - Polly - Dump polyhedral description of Scops optimized with the isl scheduling optimizer and the set of post-scheduling transformations is applied on the schedule tree
  --polly-parallel                                                      - Generate thread parallel code (isl codegen only)
  --polly-parallel-force                                                - Force generation of thread parallel code ignoring any cost model
  --polly-pattern-matching-based-opts                                   - Perform optimizations based on pattern matching
  --polly-postopts                                                      - Apply post-rescheduling optimizations such as tiling (requires -polly-reschedule)
  --polly-pragma-based-opts                                             - Apply user-directed transformation from metadata
  --polly-pragma-ignore-depcheck                                        - Skip the dependency check for pragma-based transformations
  --polly-process-unprofitable                                          - Process scops that are unlikely to benefit from Polly optimizations.
  --polly-register-tiling                                               - Enable register tiling
  --polly-report                                                        - Print information about the activities of Polly
  --polly-reschedule                                                    - Optimize SCoPs using ISL
  --polly-show                                                          - Highlight the code regions that will be optimized in a (CFG BBs and LLVM-IR instructions)
  --polly-show-only                                                     - Highlight the code regions that will be optimized in a (CFG only BBs)
  --polly-stmt-granularity=<value>                                      - Algorithm to use for splitting basic blocks into multiple statements
    =bb                                                                 -   One statement per basic block
    =scalar-indep                                                       -   Scalar independence heuristic
    =store                                                              -   Store-level granularity
  --polly-target=<value>                                                - The hardware to target
    =cpu                                                                -   generate CPU code
  --polly-tiling                                                        - Enable loop tiling
  --polly-vectorizer=<value>                                            - Select the vectorization strategy
    =none                                                               -   No Vectorization
    =polly                                                              -   Polly internal vectorizer
    =stripmine                                                          -   Strip-mine outer loops for the loop-vectorizer to trigger
```

</details>

That's a lot! But we are going to test them out. I wrote a script [test-options.sh](test-options.sh) that we can run to test each.
I'll put results (compile time and lammps) in the table here. Note this is just on my local machine, and I'm running it once.
E.g.,

```console
./test-options.sh "-O0"
```

Note that the above adds on to options I think are required:

```console
--relocation-model=pic --runtime-counter-relocation --relax-elf-relocations
```

Most of this will be learning for me, since I'll read about the different options as I try.

| Options | Compile Time | LAMMPS time | 
|---------|--------------|-------------|
| "-O0"   |      44s     |  21s        |
| "-O1"   |      69s     |  21s        |
| "-O2"   |      66s     |  21s        |
| "-O3"   |      67s     |  23s        |
| "--frame-pointer=all"            | 65s | 21s    |
| "--frame-pointer=none"           | 66s | 20s   |
| "--frame-pointer=non-leaf"       | 66s | 20s |
| "--disable-type-promotion"  | 64s | 21s |
| "--enable-no-signed-zeros-fp-math" | 66s | 21s |
| "--enable-no-trapping-fp-math" | 65s | 20s |
| "--enable-unsafe-fp-math"| 67s | 21s |
| "--regalloc=basic" | 64s | 20s |
| "--regalloc=greedy" (default for optimized) | 67s | 21s |
| "--regalloc=fast" (default for unoptimized) | segfault | segfault |
| "--regalloc=pbqp" (Partitioned Boolean Quadratic Programming) | 74s | 22s | 
| "--x86-asm-syntax=att" | 65s | 21s |
| "--x86-asm-syntax=intel" | 64s | 20s |
| "--code-model=small" | 65s | 20s |
| "--code-model=kernel" | 72s | 20s |
| "--code-model=medium" | 74s | 21s |
| "--code-model=large" | 80s | 20s |
| "--cost-kind=throughput" | 64s | 20s |
| "--cost-kind=latency" | 63s | 20s |
| "--cost-kind=code-size" | 66s | 22s |
| "--cost-kind=size-latency" |65s  | 20s |
| "--do-counter-promotion" | 65s | 21s |
| "--enable-cse-in-legalizer" | 66s | 21s |
| "--enable-cse-in-irtranslator" | 67s | 21s |
| "--enable-load-in-loop-pre" |68s | 20s |
| "--enable-load-pre" | 65s | 21s |
| "--enable-loop-simplifycfg-term-folding" | 66s | 20s |
| "--enable-split-backedge-in-load-pre" | 64s | 20s |
| "--experimental-debug-variable-locations" | 65s | 20s |
| "--float-abi=default" | 65s | 20s |
| "--float-abi=soft" | 65s | 21s |
| "--float-abi=hard" | 65s | 20s |
| "--fp-contract=fast" | 64s | 20s |
| "--fp-contract=on" | 66s | 20s |
| "--fp-contract=off" | 65s | 20s |    
| "--function-sections" |  65s| 20s |
| "--generate-merged-base-profiles" | 66s | 22s |
| "--hot-cold-split" | 68s | 21s  |
| "--import-all-index" | 65s | 20s | 
| "--matrix-default-layout=column-major" | 64s | 20s |
| "--matrix-default-layout=row-major" | 64s | 21s |
| "--mc-relax-all" | 66s | 20s |
| "--mips-compact-branches=never" | 66s | 20s |
| "--mips-compact-branches=optimal" | 66s | 20s |
| "--mips-compact-branches=always" | 65s | 20s |
| "--tail-predication=disabled" | 64s | 20s |
| "--tail-predication=enabled-no-reductions" | 65s | 20s |
| "--tail-predication=enabled" | 62s | 20s  |
| "--thread-model=posix" | 65s | 20s |
| "--thread-model=single" | 65s | 20s |
| "--polly -O1" | 67s | 20s |
| "--polly -O2" | 66s | 20s |
| "--polly -O3" | 67s | 20s |
| "--polly -O3 --polly-2nd-level-tiling" | 65s | 22s  |
| "--polly -O3 --polly-register-tiling" | 63s | 20s |
| "--polly -O3 --polly-reschedule" | 65s | 20s |
| "--polly -O3 --polly-tiling" | 63s | 20s |
| "--polly -O3 --polly-stmt-granularity=bb" | 63s | 20s |
| "--polly -O3 --polly-stmt-granularity=scalar-indep" | 64s | 20s |
| "--polly -O3 --polly-stmt-granularity=store" | 64s  | 20s |
| "--polly -O3 --polly-vectorizer=none" | 64s | 20s |
| "--polly -O3 --polly-vectorizer=polly" | 64s | 20s |
| "--polly -O3 --polly-vectorizer=stripmine" | 65s | 20s |

Polly is [LLVM Framework for High-Level Loop and Data Locality Optimizations](https://polly.llvm.org/) (note `--polly-report` might be cool). But note, I don't see much difference in any of the above. I think the most salient flag is `-march`, which is detected from the system. We might just need to try this on a cluster with different nodes.


We probably want to test this one:

```
--mcpu=<cpu-name>                                                     - Target a specific cpu type (-mcpu=help for details)
```

Questions: do we need/want to set the target triple?

```
-mtriple=<target triple>
              Override the target triple specified in the input file with the specified string.
```

These might be useful for our experiments:

```
 --stats
              Print statistics recorded by code-generation passes.

 --time-passes
              Record the amount of time needed for each pass and print a report to standard error.
```

This might be cool to visualize something:

```
 --dot-cfg-mssa=<file name for generated dot file>                     - file name for generated dot file
```

### Testing

I did some brief testing that compares 'base cases' to some of the above. I realize I don't have a good sense of what a base case is (and tested a few ideas).

- [testing/c2d-standard-8-size-4-no-optimization-flag-vs-O0.txt](testing/c2d-standard-8-size-4-no-optimization-flag-vs-O0.txt): a base case without any optimization flags (would do what the compiler does by default) vs. llc compile with O0 - the second is much slower.
- [testing/c2d-standard-8-size-4-O0-vs-O0.txt](testing/c2d-standard-8-size-4-O0-vs-O0.txt): made a more fair comparison - O0 vs O0 and the second was slightly faster (one second) of course that does not offset the time it took to finish building.
- [testing/c2d-standard-8-size-4-O0-vs-clang-03.txt](testing/c2d-standard-8-size-4-O0-vs-clang-03.txt) I added O3 to clang, but not to llc.
- [testing/c2d-standard-8-size-4-O0-vs-clang-02.txt](testing/c2d-standard-8-size-4-O0-vs-clang-02.txt) I added O2 to clang, but not to llc.
- [testing/c2d-standard-8-size-4-01-llc-and-clang.txt](testing/c2d-standard-8-size-4-01-llc-and-clang.txt): Using 01 for both llc commands and clang.
- [testing/c2d-standard-8-size-4-02-llc-and-clang.txt](testing/c2d-standard-8-size-4-02-llc-and-clang.txt): Using 02 for both llc commands and clang.
- [testing/c2d-standard-8-size-4-03-llc-and-clang.txt](testing/c2d-standard-8-size-4-03-llc-and-clang.txt): Using 03 for both llc commands and clang.

None of the above seem to have improvement, but that's OK, still learning. ;)

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
    --machine-type=c2d-standard-8 \
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
