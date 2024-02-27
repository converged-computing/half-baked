# Half Baked Gromacs

Let's build the half baked image, manually first. This is going to use [llvm-ir-cmake-utils](https://github.com/compor/llvm-ir-cmake-utils).

```bash
docker build -t half-baked-gromacs .
```

Build the image, then inside at `/opt/gromacs-5.1.2/build/llvm-ir/gmx_bc`. Note that this is only possible
if you disable libgromacs.

```bash
for filename in $(ls *.ll); do
    llc -filetype=obj -O0 --relocation-model=pic --runtime-counter-relocation --relax-elf-relocations  $filename -o $filename.o
done
clang -lstdc++ -lm *.o -o gmx
```
