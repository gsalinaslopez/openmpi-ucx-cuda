# Introduction 
Docker container that builds OpenMPI with CUDA support. 

# Requirements
As a prerequisite, [install NVIDIA docker](https://github.com/NVIDIA/nvidia-docker)

This container is based on `nvcr.io/nvidia/cuda:11.8.0-base-ubuntu22.04`, verify the cuda container installation by running the `nvidia-smi` command to poll for the installed GPUs:
```
$ sudo docker run --gpus all --rm nvcr.io/nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

# Build and Test
```
$ sudo docker build -t openmpi-ucx-cuda .
```

Verify that OpenMPI has been built with cuda using `ompi_info`

```
$ sudo docker run --gpus all --rm openmpi-ucx-cuda ompi_info --parsable --all | grep mpi_built_with_cuda_support:value
```

Should output:
```
mca:mpi:base:param:mpi_built_with_cuda_support:value:true
```

# References
[UCX Installation](https://openucx.readthedocs.io/en/master/running.html#openmpi-with-ucx)

[OpenMPI Installation](https://docs.open-mpi.org/en/v5.0.0rc7/networking/cuda.html#how-do-i-build-open-mpi-with-cuda-aware-support)

The `setup.packages.sh` script to install dependencies is taken from here: <https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/tf_sig_build_dockerfiles/setup.packages.sh>
