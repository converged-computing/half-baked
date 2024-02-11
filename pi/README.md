# Half Baked Pi

## Build Manual

Let's build the half baked image, manually first.

```bash
docker build -t half-baked .
```

This will generate the llvm-ir files in `/code`. We can next try running (and completing them) with a Batch job (to come next).

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
```

## Flux Operator

When the cluster is ready, install the Flux Operator from the development branch.

```bash
kubectl apply -f https://raw.githubusercontent.com/flux-framework/flux-operator/test-refactor-modular/examples/dist/flux-operator-refactor.yaml
```

You can check logs to ensure it is also running, in the `operator-system` namespace.

Now let's build and push the container, and run a job using it.

```bash
docker build -t ghcr.io/converged-computing/half-baked:pi .
docker push ghcr.io/converged-computing/half-baked:pi
```

Now run the minicluster. If you set interactive to true you can shell in to poke around.

```bash
kubectl apply -f minicluster.yaml
```
Wait for it to be running:

```
$ kubectl get pods
NAME                    READY   STATUS     RESTARTS   AGE
half-baked-pi-0-bpp7g   0/1     Init:0/1   0          23s
half-baked-pi-1-9hg4x   0/1     Init:0/1   0          23s
half-baked-pi-2-4glxh   0/1     Init:0/1   0          23s
half-baked-pi-3-wxmd5   0/1     Init:0/1   0          23s
```

Check the logs to see pi! This was built from the llvm IR on the fly.

```console
/usr/bin/ld: half-baked.o: warning: relocation in read-only section `.text'
/usr/bin/ld: warning: creating DT_TEXTREL in a PIE
/usr/bin/ld: half-baked.o: warning: relocation in read-only section `.text'
/usr/bin/ld: warning: creating DT_TEXTREL in a PIE
Time taken: 0.295427
Value for Pi: 3.141131
```
We will likely need/want to understand those errors better, and realistically there will be many more (and worse). If you want to make interactive: true and mess around, here is how to compile the LLVM IR:

```bash
llc -filetype=obj pthreadTimed.ll -o half-baked.o
clang -lm half-baked.o -o half-baked
```

Some comments:

1. The hardest part is getting the initial llvm-ir, and then the follow up command to build, which is going to require:
  a. preserving flags
  b. knowing how to generate the llvm-ir not just across a project, but for libraries of interest.
2. Dinos makes a good point that [some macros are resolved](https://libc.llvm.org/dev/code_style.html) early in compilation. We will want to understand the set that are and what is left to further customize.

### Clean Up

When you are done:

```bash
gcloud container clusters delete test-cluster --region=us-central1-a
```
