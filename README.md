# Half Baked

![img/half-baked.jpeg](img/half-baked.jpeg)

These are experiments to try building a base image with an [LLVM IR](https://lists.llvm.org/pipermail/llvm-dev/2014-September/076375.html) "internal representation" that can
be finalized (the compilation finished) more on demand to be fit to a node. This approach would be suitable for cases when we need a niche architecture, but don't have one built in advance. It provides an alterative to what we currently consider the only option.
More specifically:

- Option 1: pre-build all options / variants of an application (and maybe miss some or get it wrong)
- Option 2: start with a "half baked" image, and then finish compilation on demand for exactly what we need.

The second option also only requires one image base! Let's give a shot, with a simple LAMMPS build. Our strategy here will be the following:

1. Try first a manual approach, manual builds on a local system.
2. Try a design that is in Kubernetes
3. Optimize the design in Kubernetes

For the last, it's not clear if we will want an operator or similar, e.g., something with an init container or even a mutating webhook.
We will likely also need to consider caching or deploy strategies, because we wouldn't want to kick off 1000x of the same build at once!

## Builds

 - [pi](pi): "Half baked pi" 🥧️
 - [rellume](rellume): lift machine code to LLVM IR


## License

HPCIC DevTools is distributed under the terms of the MIT license.
All new contributions must be made under this license.

See [LICENSE](https://github.com/converged-computing/cloud-select/blob/main/LICENSE),
[COPYRIGHT](https://github.com/converged-computing/cloud-select/blob/main/COPYRIGHT), and
[NOTICE](https://github.com/converged-computing/cloud-select/blob/main/NOTICE) for details.

SPDX-License-Identifier: (MIT)

LLNL-CODE- 842614
