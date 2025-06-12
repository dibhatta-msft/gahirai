FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    nasm \
    qemu-system-x86 \
    gdb \
    curl \
    wget \
    bison \
    flex \
    libgmp3-dev \
    libmpc-dev \
    libmpfr-dev \
    texinfo \
    && rm -rf /var/lib/apt/lists/*

# Set up cross-compiler build
WORKDIR /tmp
ENV PREFIX="/opt/cross"
ENV TARGET=i686-elf
ENV PATH="$PREFIX/bin:$PATH"

# Download and build binutils
RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.39.tar.gz && \
    tar -xzf binutils-2.39.tar.gz && \
    mkdir build-binutils && \
    cd build-binutils && \
    ../binutils-2.39/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror && \
    make && \
    make install

# Download and build GCC
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz && \
    tar -xzf gcc-12.2.0.tar.gz && \
    mkdir build-gcc && \
    cd build-gcc && \
    ../gcc-12.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers && \
    make all-gcc && \
    make all-target-libgcc && \
    make install-gcc && \
    make install-target-libgcc

# Clean up
RUN rm -rf /tmp/*

WORKDIR /workspace
CMD ["/bin/bash"]
