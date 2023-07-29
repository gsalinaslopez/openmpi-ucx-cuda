################################################################################
FROM nvcr.io/nvidia/cuda:11.8.0-base-ubuntu22.04 as base
################################################################################

ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"

COPY setup.packages.sh /setup.packages.sh
COPY devel.packages.txt /devel.packages.txt
RUN /setup.packages.sh /devel.packages.txt

ENV UCX_HOME=/opt/ucx \
    OMPI_HOME=/opt/ompi \
    CUDA_HOME=/usr/local/cuda

WORKDIR /tmp

# Install UCX
# https://openucx.readthedocs.io/en/master/running.html#openmpi-with-ucx
RUN cd /tmp/ \
    && git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
    && cd ucx \
    && ./autogen.sh \
    && mkdir build \
    && cd build \
    && ../contrib/configure-release --prefix=$UCX_HOME \
        --with-cuda=$CUDA_HOME \
        --enable-optimizations  \
        --disable-logging \
        --disable-debug \
        --disable-examples \
    && make -j $(nproc)  \
    && make install

# Install OpenMPI
# https://docs.open-mpi.org/en/v5.0.0rc7/networking/cuda.html#how-do-i-build-open-mpi-with-cuda-aware-support
RUN cd /tmp \
    && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
    && cd ompi \
    && ./autogen.pl \
    && mkdir build \
    && cd build \
    && ../configure --prefix=$OMPI_HOME --with-ucx=$UCX_HOME \
        --with-cuda=$CUDA_HOME \
        --disable-man-pages \
        --disable-debug \
    && make -j $(nproc) \
    && make install

# Adding OpenMPI and UCX to Environment
ENV PATH=$OMPI_HOME/bin:$UCX_HOME/bin:$PATH \
    PKG_CONFIG_PATH=$OMPI_HOME/lib/pkgconfig:$UCX_HOME/lib/pkgconfig:$PKG_CONFIG_PATH