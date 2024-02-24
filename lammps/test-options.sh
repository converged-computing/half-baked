#!/bin/bash

echo "Options are: $@"

# Clean up previous runs
rm -rf /usr/local/bin/half-baked-lmp /usr/lib/liblammps.so
rm -rf /opt/lammps/build/llvm-ir/lammps_bc/*.o /opt/lammps/build/llvm-ir/lammps_bc/*.so
rm -rf /opt/lammps/build/llvm-ir/lmp_bc/*.o /opt/lammps/build/llvm-ir/lmp_bc/lmp

# Test random sets of options to see how long lammps runs
cd /opt/lammps/build/llvm-ir/lammps_bc
startTime=$(( $(date +%s) + secs ))

# Clean up previous files
for filename in $(ls *.ll); do
    llc -filetype=obj $@ --relocation-model=pic --runtime-counter-relocation --relax-elf-relocations  $filename -o $filename.o
done
clang -shared -lstdc++ -lmpi -lmpi_cxx -lm *.o -o lammps.so
cp lammps.so /usr/lib/liblammps.so

cd /opt/lammps/build/llvm-ir/lmp_bc
llc -filetype=obj $@ --relocation-model=pic --runtime-counter-relocation --relax-elf-relocations main.cpp.bc -o lmp.o
clang -lstdc++ -lmpi -lmpi_cxx -lm -llammps lmp.o -o lmp
cp lmp /usr/local/bin/half-baked-lmp

endTime=$(( $(date +%s) + secs ))
compileSeconds="$((endTime-startTime))"

cd /opt/lammps/examples/reaxff/HNS/
half-baked-lmp -v x 2 -v y 2 -v z 2 -in ./in.reaxc.hns -nocite
echo "TIME_COMPILE_SECONDS=$compileSeconds"

