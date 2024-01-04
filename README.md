# cpp-multiarch

Sandbox for building a multiarch Docker image for a C++ application using `docker buildx`

## Sample app details
- Built via CMake using host (x86_64) and [aarch64-linux-gnu](https://copr.fedorainfracloud.org/coprs/lantw44/aarch64-linux-gnu-toolchain/) toolchains on Fedora
- Dependencies: yaml-cpp, spdlog/fmt (statically linked)
- Note: Dockerfile uses Fedora 39 in order for glibc version (2.38) to match the aarch64-linux-gnu toolchain

```bash
$ mkdir build; cd build
$ cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$PWD/.. ..
$ make install
$ cd ..; mkdir build_aarch64; cd build_aarch64
$ cmake -DCMAKE_TOOLCHAIN_FILE=../ArmLinux.cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTAL_PREFIX=$PWD/.. .. 
$ make install
```

## Container images
- x86_64, aarch64

## Building image with Docker buildx

```bash
$ docker login
$ docker buildx create --use
$ docker buildx build --platform linux/amd64,linux/arm64 --push -t cjlove2024/multiarchtest:latest .
```
