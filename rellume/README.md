# Rellume

This is just an example to compile it - if I understand this script, it has byte
code hard coded and then generates LLVM IR from it. We could try reading in some
program as byte code and doing the same. That might be easier than starting from
source code?

```bash
docker build -t ghcr.io/converged-computing/half-baked:rellume .
```

I suspect this is a very simple example and will have issues when it expands, but worth
a shot anyway.
